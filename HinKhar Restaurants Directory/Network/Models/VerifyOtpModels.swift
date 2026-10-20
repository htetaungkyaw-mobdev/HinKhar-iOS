//
//  VerifyOtpModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 14/10/2026.
//


struct VerifyOtpRequest: Encodable {
    let identifier: String
    let otp: String
    let type: String
}

struct VerifyOtpResponse: Decodable {
    let success: Bool
    let message: String
    let reset_token: String?
}
