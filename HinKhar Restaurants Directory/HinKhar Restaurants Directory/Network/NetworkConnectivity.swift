//
//  NetworkConnectivity.swift
//  HinKhar Restaurants Directory
//
//  Created by Codex on 25/06/2026.
//

import Foundation
import Network

extension Notification.Name {
    static let networkConnectionUnavailable = Notification.Name("networkConnectionUnavailable")
}

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor.monitorQueue")
    private let stateQueue = DispatchQueue(label: "NetworkMonitor.stateQueue")
    private var _isConnected = true
    private var hasReceivedPathUpdate = false

    var isConnected: Bool {
        stateQueue.sync { _isConnected }
    }

    var hasResolvedStatus: Bool {
        stateQueue.sync { hasReceivedPathUpdate }
    }

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.stateQueue.async {
                self?._isConnected = path.status == .satisfied
                self?.hasReceivedPathUpdate = true
            }
        }

        monitor.start(queue: monitorQueue)
    }
}

enum NetworkConnectivityError: LocalizedError {
    case offline

    var errorDescription: String? {
        NetworkRequestGuard.noInternetMessage
    }
}

enum NetworkRequestGuard {
    static let noInternetMessage = "No internet connection"

    static func requireConnection() throws {
        guard NetworkMonitor.shared.hasResolvedStatus == false || NetworkMonitor.shared.isConnected else {
            postNoInternetToast()
            throw NetworkConnectivityError.offline
        }
    }

    static func isOfflineError(_ error: Error) -> Bool {
        if error is NetworkConnectivityError {
            return true
        }

        if let urlError = error as? URLError {
            return urlError.code == .notConnectedToInternet
        }

        return false
    }

    static func handleOfflineError(_ error: Error) -> Bool {
        if error is NetworkConnectivityError {
            return true
        }

        guard isOfflineError(error) else { return false }
        postNoInternetToast()
        return true
    }

    private static func postNoInternetToast() {
        NotificationCenter.default.post(name: .networkConnectionUnavailable, object: nil)
    }
}
