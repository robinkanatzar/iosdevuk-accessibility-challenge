//
//  NetworkMonitor.swift
//  IOSDevuk26
//

import Foundation
import Network

/// Observable wrapper around `NWPathMonitor` so SwiftUI views can react when
/// the device gains or loses network connectivity.
@Observable
final class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    /// `true` while the device has a usable network path. Initialised to
    /// `true` so the UI does not flash "offline" before the first path
    /// update arrives.
    private(set) var isOnline: Bool = true

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let online = path.status == .satisfied
            DispatchQueue.main.async {
                self?.isOnline = online
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
