//
//  ForgotPasswordModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 09/03/2026.
//

struct ForgotPasswordRequest: Encodable {
    let identifier: String
}

struct ForgotPasswordResponse: Decodable {
    let success: Bool
    let message: String?
    let channel: String
    let expires_in: Int
}
