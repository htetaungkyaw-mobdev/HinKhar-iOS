//
//  DeviceTokenRegistrationService.swift
//  HinKhar Restaurants Directory
//

import Foundation

private struct DeviceTokenRequest: Encodable {
    let token: String
    let platform: String
    let appVersion: String

    enum CodingKeys: String, CodingKey {
        case token
        case platform
        case appVersion = "app_version"
    }
}

private struct DeviceTokenResponse: Decodable {
    let registered: Bool
    let isSignedIn: Bool

    enum CodingKeys: String, CodingKey {
        case registered
        case isSignedIn = "is_signed_in"
    }
}

@MainActor
final class DeviceTokenRegistrationService {
    static let shared = DeviceTokenRegistrationService()

    private var lastRegisteredIdentity: String?

    func registerStoredToken(isSignedIn: Bool) async {
        guard let fcmToken = KeychainManager.shared.get(KeychainKeys.fcmToken) else {
            return
        }

        await register(fcmToken: fcmToken, isSignedIn: isSignedIn)
    }

    func register(fcmToken: String, isSignedIn: Bool) async {
        let authenticationToken = isSignedIn
            ? KeychainManager.shared.get(KeychainKeys.userToken)
            : nil
        let registrationIdentity = "\(fcmToken)|\(authenticationToken ?? "anonymous")"

        guard lastRegisteredIdentity != registrationIdentity else {
            return
        }

        let request = DeviceTokenRequest(
            token: fcmToken,
            platform: "ios",
            appVersion: Bundle.main.object(
                forInfoDictionaryKey: "CFBundleShortVersionString"
            ) as? String ?? "1.0.0"
        )

        do {
            let _: DeviceTokenResponse = try await ApiService.apiService.shared(
                endpoint: "device-tokens",
                method: "POST",
                body: request,
                requiresToken: isSignedIn,
                responseType: DeviceTokenResponse.self
            )
            lastRegisteredIdentity = registrationIdentity
        } catch {
            // Registration is retried on the next token refresh, launch, or sign-in.
        }
    }
}
