//
//  ApiServices.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//
import Foundation

enum LoginApiError: LocalizedError {
    case serverMessage(String)

    var errorDescription: String? {
        switch self {
        case .serverMessage(let message):
            return message
        }
    }
}

class LoginApiService {
    static let apiService = LoginApiService()

    private let baseURL = APIConfig.baseURL

    func login<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresToken: Bool = false,
        responseType: T.Type
    ) async throws -> T {
        try NetworkRequestGuard.requireConnection()

        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresToken {
            if let token = KeychainManager.shared.get(KeychainKeys.userToken) {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        let isSuccessfulStatus = (response as? HTTPURLResponse).map { (200...299).contains($0.statusCode) } ?? true

        do {
            if isSuccessfulStatus {
                return try JSONDecoder().decode(responseType, from: data)
            }

            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Non-2xx response"))
        } catch {
            if let apiError = try? JSONDecoder().decode(LoginErrorResponse.self, from: data) {
                let message = apiError.errors?["login"]?.first
                    ?? apiError.message
                    ?? "Login failed."
                throw LoginApiError.serverMessage(message)
            }

            if let responseText = String(data: data, encoding: .utf8), !responseText.isEmpty {
                throw LoginApiError.serverMessage(responseText)
            }

            if isSuccessfulStatus == false {
                throw LoginApiError.serverMessage("Login failed.")
            }

            throw error
        }
    }
}
