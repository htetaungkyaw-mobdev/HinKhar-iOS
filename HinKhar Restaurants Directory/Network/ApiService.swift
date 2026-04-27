//
//  ApiService.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 20/02/2026.
//
import Foundation

class ApiService {
    static let apiService = ApiService()

    private let baseURL = APIConfig.baseURL

    func shared<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresToken: Bool = false,
        responseType: T.Type
    ) async throws -> T {

        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresToken {
            if let token = KeychainManager.shared.get("userToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(responseType, from: data)
    }
}
