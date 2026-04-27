//
//  SubmitRatingModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 20/03/2026.
//

struct ReviewRequest: Encodable {
    let reviewable_id: Int
    let reviewable_type: String
    let rating: Int
    let comment: String
}

struct ReviewListResponse: Decodable {
    let data: [ApiReview]
}

struct ReviewResponse: Decodable {
    let data: ApiReview
}

struct ApiReview: Decodable {
    let id: Int
    let user_id: Int
    let rating: Int
//    let comment: String
//    let reviewable_id: Int
//    let reviewable_type: String
}
