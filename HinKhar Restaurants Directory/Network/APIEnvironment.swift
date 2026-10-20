//
//  APIEnvironment.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 05/12/2025.
//


import Foundation

enum APIEnvironment {
    case local
    case dev
    case uat
    case prod

    var baseURL: String {
        switch self {
        case .local:
            return "http://127.0.0.1:8000/api/v1/"
        case .dev:
            return "https://staging.hinkhar.com/api/v1/"
        case .uat:
            return "https://testing.hinkhar.com/api/v1/"
        case .prod:
            return "https://admin.hinkhar.com/api/v1/"
        }
    }
}

struct APIConfig {
    static var environment: APIEnvironment = .uat
    static var baseURL: String { environment.baseURL }
}
