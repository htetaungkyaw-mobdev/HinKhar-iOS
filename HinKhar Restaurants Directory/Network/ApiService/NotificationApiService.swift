//
//  NotificationApiService.swift
//  HinKhar Restaurants Directory
//

import Foundation

final class NotificationApiService {
    static let shared = NotificationApiService()

    private init() {}

    func notifications(page: Int, perPage: Int = 20) async throws -> NotificationsResponse {
        try NetworkRequestGuard.requireConnection()

        guard var components = URLComponents(string: APIConfig.baseURL + "notifications") else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = KeychainManager.shared.get(KeychainKeys.userToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(NotificationsResponse.self, from: data)
    }

    func markAsRead(notificationID: Int) async throws {
        try await sendReadRequest(endpoint: "notifications/\(notificationID)/read")
    }

    func markAllAsRead() async throws {
        try await sendReadRequest(endpoint: "notifications/read-all")
    }

    private func sendReadRequest(endpoint: String) async throws {
        try NetworkRequestGuard.requireConnection()

        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = KeychainManager.shared.get(KeychainKeys.userToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
