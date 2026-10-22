//
//  NotificationsView.swift
//  HinKhar Restaurants Directory
//

import Observation
import SwiftUI

@MainActor
@Observable
final class NotificationsViewModel {
    private(set) var notifications: [AppNotification] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var isMarkingAllAsRead = false
    private(set) var canLoadMore = true
    private(set) var errorMessage: String?

    private var nextPage = 1

    func loadInitial() async {
        guard !isLoading else {
            return
        }

        nextPage = 1
        canLoadMore = true
        notifications = []
        await loadPage(replacingItems: true)
    }

    func loadMore(after notification: AppNotification) async {
        guard notification.id == notifications.last?.id,
              canLoadMore,
              !isLoading,
              !isLoadingMore else {
            return
        }

        await loadPage(replacingItems: false)
    }

    func markAsRead(_ notification: AppNotification) async {
        guard !notification.isRead,
              let index = notifications.firstIndex(where: { $0.id == notification.id }) else {
            return
        }

        do {
            try await NotificationApiService.shared.markAsRead(notificationID: notification.id)
            notifications[index].isRead = true
        } catch {
            if !NetworkRequestGuard.handleOfflineError(error) {
                errorMessage = error.localizedDescription
            }
        }
    }

    func markAllAsRead() async {
        guard notifications.contains(where: { !$0.isRead }), !isMarkingAllAsRead else {
            return
        }

        isMarkingAllAsRead = true
        defer { isMarkingAllAsRead = false }

        do {
            try await NotificationApiService.shared.markAllAsRead()
            notifications.indices.forEach { notifications[$0].isRead = true }
        } catch {
            if !NetworkRequestGuard.handleOfflineError(error) {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func loadPage(replacingItems: Bool) async {
        if replacingItems {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        errorMessage = nil

        defer {
            isLoading = false
            isLoadingMore = false
        }

        do {
            let response = try await NotificationApiService.shared.notifications(page: nextPage)

            if replacingItems {
                notifications = response.data
            } else {
                notifications.append(contentsOf: response.data)
            }

            nextPage = response.meta.currentPage + 1
            canLoadMore = response.meta.currentPage < response.meta.lastPage
        } catch {
            if !NetworkRequestGuard.handleOfflineError(error) {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = NotificationsViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NotificationsHeader {
                    dismiss()
                }
                NotificationsHeaderActions(
                    canMarkAllAsRead: viewModel.notifications.contains(where: { !$0.isRead }),
                    isMarkingAllAsRead: viewModel.isMarkingAllAsRead,
                    markAllAsRead: {
                        await viewModel.markAllAsRead()
                    }
                )

                NotificationsContent(
                    notifications: viewModel.notifications,
                    isLoading: viewModel.isLoading,
                    isLoadingMore: viewModel.isLoadingMore,
                    errorMessage: viewModel.errorMessage,
                    loadMore: { notification in
                        await viewModel.loadMore(after: notification)
                    },
                    markAsRead: { notification in
                        await viewModel.markAsRead(notification)
                    }
                )
            }
            .background(Color(.systemBackground))
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadInitial()
        }
    }
}

private struct NotificationsHeader: View {
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text("Notifications")
                .font(.title3.weight(.semibold))

            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color("PrimaryColor"))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Back")

                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct NotificationsHeaderActions: View {
    let canMarkAllAsRead: Bool
    let isMarkingAllAsRead: Bool
    let markAllAsRead: () async -> Void

    var body: some View {
        HStack {
            Spacer()

            Button {
                Task {
                    await markAllAsRead()
                }
            } label: {
                Group {
                    if isMarkingAllAsRead {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Mark all as read")
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white)
                .frame(minWidth: 112, minHeight: 36)
                .padding(.horizontal, 8)
                .background(Color("PrimaryColor"), in: Capsule())
            }
            .disabled(!canMarkAllAsRead || isMarkingAllAsRead)
            .opacity(canMarkAllAsRead ? 1 : 0.5)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
    }
}

private struct NotificationsContent: View {
    let notifications: [AppNotification]
    let isLoading: Bool
    let isLoadingMore: Bool
    let errorMessage: String?
    let loadMore: (AppNotification) async -> Void
    let markAsRead: (AppNotification) async -> Void

    var body: some View {
        Group {
            if isLoading && notifications.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if notifications.isEmpty {
                ContentUnavailableView(
                    "No notifications",
                    systemImage: "bell.slash",
                    description: Text("You’re all caught up.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(notifications) { notification in
                            Button {
                                Task {
                                    await markAsRead(notification)
                                }
                            } label: {
                                NotificationCard(
                                    type: notification.type,
                                    title: notification.title,
                                    message: notification.body,
                                    createdAt: notification.createdAt,
                                    isRead: notification.isRead
                                )
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                Task {
                                    await loadMore(notification)
                                }
                            }
                        }

                        if isLoadingMore {
                            ProgressView()
                                .padding(.vertical, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(12)
                    .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
        }
    }
}

private struct NotificationCard: View {
    let type: String
    let title: String
    let message: String
    let createdAt: Date
    let isRead: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            NotificationTypeIcon(type: type)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("PrimaryColor"))
                    .lineLimit(2)

                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .lineLimit(3)

                Text(createdAt, format: .dateTime.day().month(.abbreviated).year().hour().minute())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isRead ? Color(.systemBackground) : Color("SecondaryColor").opacity(0.16))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    isRead ? Color("PrimaryColor") : Color.yellow,
                    lineWidth: 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 3)
        .accessibilityElement(children: .combine)
    }
}

private struct NotificationTypeIcon: View {
    let type: String

    private var systemName: String {
        switch type.lowercased() {
        case "promotion":
            return "tag.fill"
        case "restaurant":
            return "fork.knife"
        default:
            return "bell.fill"
        }
    }

    var body: some View {
        Image(systemName: systemName)
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(Color("PrimaryColor"), in: Circle())
            .accessibilityHidden(true)
    }
}

#Preview {
    NotificationsView()
}
