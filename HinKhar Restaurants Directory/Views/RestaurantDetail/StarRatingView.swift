import SwiftUI

public struct StarRatingView: View {
    public let rating: Double
    public let maxRating: Int
    public let size: CGFloat
    public let filledColor: Color
    public let emptyColor: Color

    public init(rating: Double, maxRating: Int = 5, size: CGFloat = 12, filledColor: Color = Color("PrimaryColor"), emptyColor: Color = .gray.opacity(0.3)) {
        self.rating = Swift.max(0, Swift.min(rating, Double(maxRating)))
        self.maxRating = maxRating
        self.size = size
        self.filledColor = filledColor
        self.emptyColor = emptyColor
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxRating, id: \.self) { index in
                starView(for: index)
                    .frame(width: size, height: size)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating")
        .accessibilityValue(String(format: "%.1f out of %d", rating, maxRating))
    }

    private func starView(for index: Int) -> some View {
        let threshold = Double(index) + 1
        let fill: Double
        if rating >= threshold {
            fill = 1.0
        } else if rating > Double(index) {
            fill = rating - Double(index)
        } else {
            fill = 0.0
        }

        return ZStack {
            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(emptyColor)

            if fill > 0 {
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(filledColor)
                    .mask(alignment: .leading) {
                        Rectangle()
                            .frame(width: size * fill)
                    }
            }
        }
    }
}

//#Preview {
//    VStack(alignment: .leading, spacing: 12) {
//        StarRatingView(rating: 0)
//        StarRatingView(rating: 1.0)
//        StarRatingView(rating: 2.5)
//        StarRatingView(rating: 3.7, size: 16)
//        StarRatingView(rating: 5.0, size: 20)
//    }
//    .padding()
//}
