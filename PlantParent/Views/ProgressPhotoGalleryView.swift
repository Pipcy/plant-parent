import SwiftData
import SwiftUI
import UIKit

struct ProgressPhotoGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    let photos: [ProgressPhoto]

    private var sortedPhotos: [ProgressPhoto] {
        photos.sorted { $0.capturedOn > $1.capturedOn }
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 12) {
                ForEach(sortedPhotos) { photo in
                    NavigationLink {
                        ProgressPhotoDetailView(photo: photo)
                    } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            if let image = UIImage(data: photo.imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 160, height: 160)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            Text(photo.capturedOn, format: .dateTime.month(.abbreviated).day().year())
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary)

                            if !photo.photoNotes.isEmpty {
                                Text(photo.photoNotes)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .frame(width: 160, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Delete Photo", role: .destructive) {
                            modelContext.delete(photo)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
    }
}

private struct ProgressPhotoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let photo: ProgressPhoto
    @State private var isConfirmingDelete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let image = UIImage(data: photo.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .accessibilityLabel("Plant progress photo")
                }

                Label {
                    Text(photo.capturedOn, format: .dateTime.month(.wide).day().year())
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundStyle(.green)
                }
                .font(.headline)

                if !photo.photoNotes.isEmpty {
                    Text(photo.photoNotes)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Delete", role: .destructive) {
                    isConfirmingDelete = true
                }
            }
        }
        .confirmationDialog(
            "Delete this progress photo?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("Delete Photo", role: .destructive) {
                modelContext.delete(photo)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
