//
//  LoginModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//
struct RegisterRequest: Encodable {
    let identifier: String
    let name: String
    let password: String
    let password_confirmation: String
}

struct RegisterResponse: Decodable {
    let success: Bool
    let message: String
    let user: User
    let access_token: String
}
