import SwiftUI

struct RemoteFillImage: View {
    let url: URL?
    var width: CGFloat? = .infinity
    var height: CGFloat? = 90
//    var aspectRatio: CGFloat? = nil
    var placeholderImageName: String = "DefaultRestaurantImage"
    
    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: width ?? .infinity)
                            .frame(height: height ?? 90)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: width ?? .infinity)
                            .frame(height: height ?? 90)
//                            .modifier(Sizing(aspectRatio: aspectRatio, height: height))
                            .clipped()
                    case .failure:
                        Image(placeholderImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: width ?? .infinity)
                            .frame(height: height ?? 90)
//                            .modifier(Sizing(aspectRatio: aspectRatio, height: height))
                            .clipped()
                    @unknown default:
                        Image(placeholderImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: width ?? .infinity)
                            .frame(height: height ?? 90)
//                            .modifier(Sizing(aspectRatio: aspectRatio, height: height))
                            .clipped()
                    }
                }
            } else {
                Image(placeholderImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: width ?? .infinity)
                    .frame(height: height ?? 90)
//                    .modifier(Sizing(aspectRatio: aspectRatio, height: height))
                    .clipped()
            }
        }
    }
}

private struct Sizing: ViewModifier {
    let aspectRatio: CGFloat?
    let height: CGFloat?

    func body(content: Content) -> some View {
        if let aspect = aspectRatio {
            content
                .aspectRatio(aspect, contentMode: .fill)
        } else if let h = height {
            content
                .frame(height: h)
        } else {
            content
        }
    }
}

#Preview {
    RemoteFillImage(url: nil)
        .padding()
}
