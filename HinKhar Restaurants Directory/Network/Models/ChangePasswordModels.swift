//
//  ChangePasswordModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 06/04/2026.
//
struct ChangePasswordRequest: Encodable {
    let current_password: String
    let new_password: String
    let new_password_confirmation: String
}

struct ChangePasswordResponse: Decodable {
    let message: String
}
