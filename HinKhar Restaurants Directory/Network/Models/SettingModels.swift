//
//  SettingModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 30/12/2025.
//
import Foundation

struct SettingListResponse: Codable {
    let data: [ApiSetting]
}

struct ApiSetting: Codable {
    let id: Int
    let type: String
    let title: String
    let value: String
}

struct SubmitSuggestionRequest: Encodable {
//    let user_id: Int
    let comment: String
}

struct SubmitSuggestionResponse: Codable {
    let data: SubmitSuggestionData
}

struct SubmitSuggestionData: Codable {
    let id: Int
    let comment: String
}

struct DeleteAccountResponse: Codable {
    let message: String
}
