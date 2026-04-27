//
//  ProfileModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 03/03/2026.
//

struct ProfileResponse: Decodable {
    let user: User
}

struct UpdateProfileRequest: Encodable {
    let name: String?
    let email: String?
    let phone: String?
    let gender: String?
    let date_of_birth: String?
    let township_id: Int?
    let address: String?
}

struct UpdateProfileResponse: Decodable {
    let message: String
    let user: User
}
