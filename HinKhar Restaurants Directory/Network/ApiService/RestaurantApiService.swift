//
//  RestaurantApiService.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 14/12/2025.
//
import Foundation

class RestaurantApiService {
    static let apiService = RestaurantApiService()

    private let baseURL = APIConfig.baseURL

    func shared<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        query: [String: String?] = [:],
        requiresToken: Bool = false,
        responseType: T.Type
    ) async throws -> T {
        try NetworkRequestGuard.requireConnection()
        
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
            if let token = KeychainManager.shared.get(KeychainKeys.userToken) {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

//        let (data, _) = try await URLSession.shared.data(for: request)
//        return try JSONDecoder().decode(responseType, from: data)
        
        let (data, response) = try await URLSession.shared.data(for: request)

        // ✅ Print raw JSON (VERY IMPORTANT)
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 RAW JSON:\n\(jsonString)")
        }

        do {
            let decoded = try JSONDecoder().decode(responseType, from: data)
            return decoded
        } catch let DecodingError.dataCorrupted(context) {
            print("❌ Data corrupted:", context.debugDescription)
            print("Path:", context.codingPath)
            throw DecodingError.dataCorrupted(context)
            
        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ Missing key:", key.stringValue)
            print("Path:", context.codingPath)
            print("Debug:", context.debugDescription)
            throw DecodingError.keyNotFound(key, context)
            
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ Type mismatch:", type)
            print("Path:", context.codingPath)
            print("Debug:", context.debugDescription)
            throw DecodingError.typeMismatch(type, context)
            
        } catch let DecodingError.valueNotFound(value, context) {
            print("❌ Value not found:", value)
            print("Path:", context.codingPath)
            print("Debug:", context.debugDescription)
            throw DecodingError.valueNotFound(value, context)
            
        } catch {
            print("❌ Unknown decode error:", error)
            throw error
        }
    }
}
