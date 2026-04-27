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
    let message: String
}
