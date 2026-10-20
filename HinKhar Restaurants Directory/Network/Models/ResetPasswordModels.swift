//
//  ForgotPasswordModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 09/03/2026.
//

struct ResetPasswordRequest: Encodable {
    let identifier: String
    let reset_token: String
    let password: String
    let password_confirmation: String
}

struct ResetPasswordResponse: Decodable {
    let message: String
}
