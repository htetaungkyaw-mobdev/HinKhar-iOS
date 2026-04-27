//
//  GeneralDataModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 20/02/2026.
//
import Foundation

struct RegionListResponse: Codable {
    let data: [ApiRegion]
}

struct ApiRegion: Codable {
    let id: Int
    let name: String
    let name_mm: String
    let region_code: String
    let description: String
    let is_active: Bool
}

struct DistrictListResponse: Codable {
    let data: [ApiDistrict]
}

struct ApiDistrict: Codable {
    let id: Int
    let name: String
    let name_mm: String
    let district_code: String
    let description: String
    let is_active: Bool
}

struct TownshipListResponse: Codable {
    let data: [ApiTownship]
}

struct ApiTownship: Codable {
    let id: Int
    let name: String
    let name_mm: String
    let township_code: String
    let description: String
    let is_active: Bool
}

struct CuisineTypeListResponse: Codable {
    let data: [ApiCuisineType]
}

struct ApiCuisineType: Codable {
    let id: Int
    let name: String
    let name_mm: String
}
