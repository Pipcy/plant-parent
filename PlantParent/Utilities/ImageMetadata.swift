import Foundation
import ImageIO

enum ImageMetadata {
    static func captureDate(from data: Data) -> Date? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) else {
            return nil
        }

        return captureDate(from: properties as NSDictionary)
    }

    static func captureDate(from metadata: [String: Any]) -> Date? {
        captureDate(from: metadata as NSDictionary)
    }

    private static func captureDate(from properties: NSDictionary) -> Date? {
        let exif = properties[kCGImagePropertyExifDictionary] as? NSDictionary
        let tiff = properties[kCGImagePropertyTIFFDictionary] as? NSDictionary

        let dateString =
            exif?[kCGImagePropertyExifDateTimeOriginal] as? String
            ?? exif?[kCGImagePropertyExifDateTimeDigitized] as? String
            ?? tiff?[kCGImagePropertyTIFFDateTime] as? String

        guard let dateString else {
            return nil
        }

        let offset = exif?[kCGImagePropertyExifOffsetTimeOriginal] as? String
        return parse(dateString, offset: offset)
    }

    private static func parse(_ dateString: String, offset: String?) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        if let offset {
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ssXXXXX"
            if let date = formatter.date(from: dateString + offset) {
                return date
            }
        }

        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.timeZone = .current
        return formatter.date(from: dateString)
    }
}
