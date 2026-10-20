//
//  UplodImageApiService.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 18/06/2026.
//

//
//  ApiService.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 20/02/2026.
//
import Foundation

class UploadImageApiService {
    static let apiService = UploadImageApiService()

    private let baseURL = APIConfig.baseURL

    func shared<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Any? = nil,                // 1. Changed from Encodable? to Any? to accept Data payloads
        contentType: String? = nil,      // 2. Added optional dynamic content type override
        requiresToken: Bool = false,
        responseType: T.Type
    ) async throws -> T {
        try NetworkRequestGuard.requireConnection()

        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // 3. Conditionally apply Content-Type header based on override parameter
        if let contentType = contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        } else {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresToken {
            if let token = KeychainManager.shared.get(KeychainKeys.userToken) {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        // 4. Handle body type evaluation (JSON encoding vs Raw Data forwarding)
        if let body {
            if let rawData = body as? Data {
                // If it is raw Multi-part data, pass it straight through
                request.httpBody = rawData
            } else if let encodableBody = body as? Encodable {
                // Wrap the Encodable object in an existential container to force encode it
                request.httpBody = try encodingHelper(encodableBody)
            }
        }

//        let (data, _) = try await URLSession.shared.data(for: request)
//        return try JSONDecoder().decode(responseType, from: data)
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
    
    // Type-erasure helper function to allow JSONEncoder to encode an 'Encodable' passed via 'Any'
    private func encodingHelper(_ value: Encodable) throws -> Data {
        return try JSONEncoder().encode(value)
    }
}
