//
//  NotificationModels.swift
//  HinKhar Restaurants Directory
//

import Foundation

struct NotificationsResponse: Decodable, Equatable {
    let data: [AppNotification]
    let meta: NotificationsMeta
}

struct AppNotification: Decodable, Equatable, Identifiable {
    let id: Int
    let type: String
    let title: String
    let body: String
    let image: String?
    let deepLink: NotificationDeepLink?
    var isRead: Bool
    let readAt: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case body
        case image
        case deepLink = "deep_link"
        case isRead = "is_read"
        case readAt = "read_at"
        case createdAt = "created_at"
    }
}

struct NotificationDeepLink: Decodable, Equatable {
    let type: String
    let entityID: String?
    let app: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case type
        case entityID = "entity_id"
        case app
        case url
    }
}

struct NotificationsMeta: Decodable, Equatable {
    let currentPage: Int
    let lastPage: Int
    let perPage: Int
    let total: Int
    let unreadCount: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
        case total
        case unreadCount = "unread_count"
    }
}
