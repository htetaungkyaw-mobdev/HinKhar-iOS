//
//  ChangePhoneOrEmailModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 16/10/2026.
//

struct ChangePhoneOtpRequest: Encodable {
    let phone: String
}

struct ChangeEmailOtpRequest: Encodable {
    let email: String
}

struct ChangePhoneVerifyOtpRequest: Encodable {
    let phone: String
    let otp: String
}

struct ChangeEmailVerifyOtpRequest: Encodable {
    let email: String
    let otp: String
}

struct ChangePhoneOrEmailVerifyOtpResponse: Decodable {
    let success: Bool
    let message: String
    let user: User
}
