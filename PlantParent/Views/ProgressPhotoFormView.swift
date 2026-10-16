import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct ProgressPhotoFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let plant: Plant
    @State private var imageData: Data?
    @State private var capturedOn = Date.now
    @State private var didReadCaptureDate = false
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isShowingCamera = false

    private var cameraIsAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        Form {
            Section {
                Group {
                    if let imageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView(
                            "Add a Progress Photo",
                            systemImage: "camera.fill",
                            description: Text("Capture how \(plant.name) looks today.")
                        )
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .listRowBackground(Color.clear)
            }

            Section("Photo") {
                Button {
                    isShowingCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera")
                }
                .disabled(!cameraIsAvailable)

                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images,
                    preferredItemEncoding: .current
                ) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                }

                if !cameraIsAvailable {
                    Text("The camera is unavailable on this device. You can choose a photo from your library.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Progress Details") {
                DatePicker(
                    "Date",
                    selection: $capturedOn,
                    in: ...Date.now,
                    displayedComponents: .date
                )

                Text(
                    didReadCaptureDate
                        ? "Date read from the photo's metadata."
                        : "This photo has no capture date. Confirm or change the date."
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                TextField("Optional note", text: $notes, axis: .vertical)
                    .lineLimit(2...5)
            }
        }
        .navigationTitle("Progress Photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(imageData == nil)
            }
        }
        .onChange(of: selectedPhoto) {
            loadSelectedPhoto()
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker { image, metadataDate in
                imageData = image.jpegData(compressionQuality: 0.85)
                if let metadataDate {
                    capturedOn = metadataDate
                    didReadCaptureDate = true
                } else {
                    capturedOn = .now
                    didReadCaptureDate = false
                }
            }
            .ignoresSafeArea()
        }
    }

    private func save() {
        guard let imageData else { return }

        let photo = ProgressPhoto(
            imageData: imageData,
            capturedOn: capturedOn,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(photo)
        plant.progressPhotos.append(photo)
        dismiss()
    }

    private func loadSelectedPhoto() {
        guard let selectedPhoto else { return }

        Task {
            if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                let metadataDate = ImageMetadata.captureDate(from: data)
                await MainActor.run {
                    imageData = data
                    if let metadataDate {
                        capturedOn = metadataDate
                        didReadCaptureDate = true
                    } else {
                        capturedOn = .now
                        didReadCaptureDate = false
                    }
                }
            }
        }
    }
}
