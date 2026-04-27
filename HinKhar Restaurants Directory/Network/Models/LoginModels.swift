//
//  LoginModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//
struct LoginRequest: Encodable {
    let login: String
    let password: String
}

struct LoginResponse: Decodable {
    let message: String
    let user: User
    let access_token: String
}

struct User: Decodable, Identifiable {
    let id: Int
    let name: String
    let email: String?
    let phone: String?
    let gender: String?
    let date_of_birth: String?
    let address: String?
    let profile_image: String?
    let township: Township?
    let district: District?
    let region: Region?
    let is_active: Bool
    let created_at: String?
    let updated_at: String
}

struct Township: Decodable, Identifiable {
    let id: Int
    let name: String
    let name_mm: String
}

struct District: Decodable, Identifiable {
    let id: Int
    let name: String
    let name_mm: String
}

struct Region: Decodable, Identifiable {
    let id: Int
    let name: String
    let name_mm: String
}
