import SwiftUI
import Foundation
import UIKit

private final class RemoteImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

struct RemoteFillImage: View {
    let url: URL?
    var width: CGFloat? = .infinity
    var height: CGFloat? = 90
    var placeholderImageName: String = "DefaultRestaurantImage"

    @State private var phase: LoadPhase = .idle

    private var resolvedURL: URL? {
        guard let url else { return nil }
        return Self.normalizedImageURL(from: url)
    }

    var body: some View {
        Group {
            if url == nil {
                placeholderView
            } else {
                switch phase {
                case .idle, .loading:
//                    ProgressView()
//                        .frame(maxWidth: width ?? .infinity)
//                        .frame(height: height ?? 90)
                    placeholderView
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: width ?? .infinity)
                        .frame(height: height ?? 90)
                        .clipped()
                case .failure:
                    placeholderView
                }
            }
        }
        .task(id: resolvedURL?.absoluteString) {
            await loadImage(from: resolvedURL)
        }
        .onAppear {
#if DEBUG
            print("RemoteFillImage raw URL:", url?.absoluteString ?? "nil")
            print("RemoteFillImage resolved URL:", resolvedURL?.absoluteString ?? "nil")
#endif
        }
    }

    private var placeholderView: some View {
        Image(placeholderImageName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: width ?? .infinity)
            .frame(height: height ?? 90)
            .clipped()
    }

    @MainActor
    private func loadImage(from url: URL?) async {
        guard let url else {
            phase = .failure
            return
        }

        if let cachedImage = RemoteImageCache.shared.object(forKey: url as NSURL) {
            phase = .success(Image(uiImage: cachedImage))
            return
        }

        phase = .loading

        do {
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad
            request.timeoutInterval = 30

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode),
                  let uiImage = UIImage(data: data) else {
                phase = .failure
                print("RemoteFillImage failed to load image URL:", url.absoluteString, "error: invalid image response")
                return
            }

            RemoteImageCache.shared.setObject(uiImage, forKey: url as NSURL)
            phase = .success(Image(uiImage: uiImage))
        } catch {
            phase = .failure
            print("RemoteFillImage failed to load image URL:", url.absoluteString, "error:", error.localizedDescription)
        }
    }

    private static func normalizedImageURL(from inputURL: URL) -> URL? {
        let raw = inputURL.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }

        if let directURL = URL(string: raw), directURL.scheme != nil {
            return directURL
        }

        if raw.hasPrefix("//"), let httpsURL = URL(string: "https:\(raw)") {
            return httpsURL
        }

        if let encodedURLString = raw.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
           let encodedURL = URL(string: encodedURLString), encodedURL.scheme != nil {
            return encodedURL
        }

        if let baseURL = backendRootURL(),
           let joinedURL = URL(string: raw, relativeTo: baseURL)?.absoluteURL {
            return joinedURL
        }

        return URL(string: raw)
    }

    private static func backendRootURL() -> URL? {
        guard let apiURL = URL(string: APIConfig.baseURL) else { return nil }

        var components = URLComponents(url: apiURL, resolvingAgainstBaseURL: false)
        components?.path = ""
        components?.query = nil
        components?.fragment = nil
        return components?.url
    }
}

private enum LoadPhase {
    case idle
    case loading
    case success(Image)
    case failure
}

#Preview {
    RemoteFillImage(url: nil)
        .padding()
}
