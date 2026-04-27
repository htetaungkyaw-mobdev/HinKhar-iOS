//
//  SettingApiService.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 30/12/2025.
//
import Foundation

class SettingApiService {
    static let apiService = SettingApiService()

    private let baseURL = APIConfig.baseURL

    func shared<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        query: [String: String?] = [:],
        requiresToken: Bool = false,
        responseType: T.Type
    ) async throws -> T {
        
        guard var components = URLComponents(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        if !query.isEmpty {
            components.queryItems = query.compactMap { key, value in
                guard let value else { return nil }
                return URLQueryItem(name: key, value: value)
            }
        }

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresToken {
            if let token = KeychainManager.shared.get("userToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(responseType, from: data)
    }
}
