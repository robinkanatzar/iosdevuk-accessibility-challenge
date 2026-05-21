//
//  LocationMapSnapshotCache.swift
//  IOSDevuk26
//

import UIKit
import MapKit

/// Persists `MKMapSnapshotter` output to Application Support so location maps
/// remain visible without network connectivity once they have been generated.
final class LocationMapSnapshotCache {
    static let shared = LocationMapSnapshotCache()

    private let directory: URL
    private let snapshotSize = CGSize(width: 1024, height: 768)
    private let snapshotScale: CGFloat = 2.0
    private let regionMeters: CLLocationDistance = 500

    private init() {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        directory = baseURL.appending(path: "MapSnapshots", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func cachedImage(locationID: String, isDark: Bool) -> UIImage? {
        let url = fileURL(locationID: locationID, isDark: isDark)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func generateAndCache(
        locationID: String,
        coordinate: CLLocationCoordinate2D,
        isDark: Bool
    ) async -> UIImage? {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: regionMeters,
            longitudinalMeters: regionMeters
        )
        options.size = snapshotSize
        options.scale = snapshotScale
        options.traitCollection = UITraitCollection { mutableTraits in
            mutableTraits.userInterfaceStyle = isDark ? .dark : .light
            mutableTraits.displayScale = snapshotScale
        }

        let snapshotter = MKMapSnapshotter(options: options)
        do {
            let snapshot = try await snapshotter.start()
            if let data = snapshot.image.pngData() {
                try? data.write(to: fileURL(locationID: locationID, isDark: isDark))
            }
            return snapshot.image
        } catch {
            return nil
        }
    }

    /// Generates snapshots for any locations that do not yet have a cached
    /// image on disk, for both light and dark variants. Intended to be called
    /// once at app launch so the maps are usable offline afterwards.
    func prefetchMissing(locations: [Location]) async {
        for location in locations {
            let coordinate = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
            for isDark in [false, true] {
                let url = fileURL(locationID: location.id, isDark: isDark)
                if FileManager.default.fileExists(atPath: url.path()) { continue }
                _ = await generateAndCache(
                    locationID: location.id,
                    coordinate: coordinate,
                    isDark: isDark
                )
            }
        }
    }

    private func fileURL(locationID: String, isDark: Bool) -> URL {
        directory.appending(path: "\(locationID)_\(isDark ? "dark" : "light").png")
    }
}
