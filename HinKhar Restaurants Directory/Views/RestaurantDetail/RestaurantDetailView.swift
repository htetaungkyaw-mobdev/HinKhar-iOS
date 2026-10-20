//
//  RestaurantDetailView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 16/12/2025.
//
import SwiftUI
import MapKit
import UIKit

// Note: To open fb:// URLs, ensure LSApplicationQueriesSchemes includes "fb" in Info.plist.

struct RestaurantDetailView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var navigateToHome: Bool = false
    @State private var navigateToPromotion: Bool = false
    @State private var navigateToRestaurant: Bool = false
    @State private var navigateToNearBy: Bool = false
    @State private var navigateToFavorite: Bool = false
    @State private var navigateToSearch: Bool = false
    @State private var showRatingDialog: Bool = false
    @State private var selectedRating: Int = 0
    @State private var isFavorite: Bool = false
    @State private var favoriteId: Int = 0
    @State private var showFavoriteConfirm: Bool = false
    @State private var showSubmitRatingSuccess: Bool = false
    @State private var navigateToMenu: Bool = false
    
    @Environment(\.openURL) private var openURLAction
    
    let initialRestaurantId: Int
    let initialComeFrom: String
    
    @State private var restaurantId: Int
    @State private var comeFrom: String
    
    private var description: String {
        guard let desc = vm.restaurantDetail?.description else { return "" }
        return desc
    }
    
    private var promotionValue: String {
        guard let promotionLists = vm.restaurantDetail?.promotionLists else { return "" }
        if !promotionLists.isEmpty {
            return PromotionUtils.definePromotionTextToShow(
                discountType: promotionLists[0].discount_type ?? "",
                discountValue: promotionLists[0].discount_value ?? ""
            )
        }
        else {
            return ""
        }
    }
    
    private var couponCode: String {
        guard let promotionLists = vm.restaurantDetail?.promotionLists else { return "" }
        if !promotionLists.isEmpty {
            return promotionLists[0].coupon_code ?? ""
        }
        else {
            return ""
        }
    }
    
    private var promotionText: String {
        guard let promotionLists = vm.restaurantDetail?.promotionLists else { return "" }
        if !promotionLists.isEmpty {
            return promotionLists[0].description ?? ""
        }
        else {
            return ""
        }
    }
    
    @State private var facebookLink: String = ""
    @State private var tiktokLink: String = ""
    @State private var viberNo: String = ""
    @State private var wechatLink: String = ""
    
    @State private var todaysClosingDay: ManualClosingDay? = nil
    
    init(restaurantId: Int, comeFrom: String) {
        self.initialRestaurantId = restaurantId
        _restaurantId = State(initialValue: initialRestaurantId)
        
        self.initialComeFrom = comeFrom
        _comeFrom = State(initialValue: initialComeFrom)
    }
    
    @StateObject var vm = RestaurantViewModel()
    @StateObject var favorite_vm = FavoriteViewModel()

    private var mapCoordinate: CLLocationCoordinate2D? {
        guard
            let latString = vm.restaurantDetail?.latitude,
            let lonString = vm.restaurantDetail?.longitude,
            let lat = Double(latString),
            let lon = Double(lonString)
        else {
            return nil
        }

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    // Helper to resolve a social link by channel using switch
    private func link(for channel: String) -> String? {
        for s in displaySocialMediaLinks {
            switch s.channel.lowercased() {
            case "facebook" where channel.lowercased() == "facebook":
                return s.link
            case "tiktok" where channel.lowercased() == "tiktok":
                return s.link
            case "viber" where channel.lowercased() == "viber":
                return s.link
            case "wechat" where channel.lowercased() == "wechat":
                return s.link
            default:
                continue
            }
        }
        return nil
    }
    
    private func populateSocialLinks() {
        if facebookLink.isEmpty, let link = link(for: "facebook") { facebookLink = link }
        if tiktokLink.isEmpty, let link = link(for: "tiktok") { tiktokLink = link }
        if viberNo.isEmpty, let link = link(for: "viber") { viberNo = link }
        if wechatLink.isEmpty, let link = link(for: "wechat") { wechatLink = link }
    }
    
    private var displayCuisineTypes: [CuisineType] {
        // If API data exists, map it to display model; otherwise return empty list
        guard let cuisineTypes = vm.restaurantDetail?.cuisineTypes else { return [] }
        
        return cuisineTypes.map { (c: LocalizedName) in
            CuisineType(
                name: c.name ?? "",
                nameMM: c.nameMM ?? ""
            )
        }
    }
    
    private var displayContacts: [Contact] {
        // If API data exists, map it to display model; otherwise return empty list
        guard let contacts = vm.restaurantDetail?.contacts else { return [] }
        
        return contacts.map { (c: ApiContact) in
            Contact(
                id: UUID().uuidString,
                phone: c.phone ?? ""
            )
        }
    }
    
    private var displaySocialMediaLinks: [SocialMediaLink] {
        // If API data exists, map it to display model; otherwise return empty list
        guard let social = vm.restaurantDetail?.socialMediaLinks else { return [] }
        
        return social.map { (s: ApiSocialMediaLink) in
            SocialMediaLink(
                id: UUID().uuidString,
                channel: s.channel ?? "",
                link: s.link ?? ""
            )
        }
    }
    
    private var displayOpeningHours: [OpeningHour] {
        // If API data exists, map it to display model; otherwise return empty list
        guard let openingHours = vm.restaurantDetail?.openingHours else { return [] }
        
        var result: [OpeningHour] = []

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        outputFormatter.locale = Locale.current

        func convert(_ time: String?) -> String {
            guard let time,
                  let date = inputFormatter.date(from: time) else {
                return ""
            }
            return outputFormatter.string(from: date)
        }

        for o in openingHours {
            let rawDay = (o.openingDay ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let open = convert(o.openingTime)
            let close = convert(o.closingTime)

            if rawDay == "all" {
//                let daysEN = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
//                let daysMM = ["တင်္နလာ", "အင်္ဂါ", "ဗုဒ္ဒဟူး", "ကြာသပတေး", "သောကြာ", "စနေ", "တနင်္ဂနွေ"]
//                let days = (selectedLanguageCode == "my") ? daysMM : daysEN
//
//                for day in days {
//                    result.append(
//                        OpeningHour(
//                            id: UUID().uuidString,
//                            openingDay: day,
//                            openingTime: open,
//                            closingTime: close
//                        )
//                    )
//                }
                let day = (selectedLanguageCode == "my") ? "နေ့စဉ်" : "Everyday"
                result.append(
                    OpeningHour(
                        id: UUID().uuidString,
                        openingDay: day,
                        openingTime: open,
                        closingTime: close
                    )
                )
            } else {
                var openingDay = o.openingDay?.capitalized ?? ""
                if selectedLanguageCode == "my" {
                    switch openingDay {
                    case "Monday": openingDay = "တင်္နလာ"
                    case "Tuesday": openingDay = "အင်္ဂါ"
                    case "Wednesday": openingDay = "ဗုဒ္ဒဟူး"
                    case "Thursday": openingDay = "ကြာသပတေး"
                    case "Friday": openingDay = "သောကြာ"
                    case "Saturday": openingDay = "စနေ"
                    case "Sunday": openingDay = "တနင်္ဂနွေ"
                    default: break
                    }
                }
                result.append(
                    OpeningHour(
                        id: UUID().uuidString,
                        openingDay: openingDay,
                        openingTime: open,
                        closingTime: close
                    )
                )
            }
        }

        return result
    }
    
    // MARK: - Open/Close status based on displayOpeningHours
    private func isTime(_ now: Date, between start: String, and end: String) -> Bool {
        // start/end are expected in "h:mm a" (already converted by displayOpeningHours)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        // Build Date objects for today with the given times
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        guard let startDateOnly = formatter.date(from: start),
              let endDateOnly = formatter.date(from: end) else {
            return false
        }

        // Extract hour/minute components from parsed times
        let startComps = calendar.dateComponents([.hour, .minute], from: startDateOnly)
        let endComps = calendar.dateComponents([.hour, .minute], from: endDateOnly)

        let startDate = calendar.date(bySettingHour: startComps.hour ?? 0, minute: startComps.minute ?? 0, second: 0, of: today) ?? now
        var endDate = calendar.date(bySettingHour: endComps.hour ?? 0, minute: endComps.minute ?? 0, second: 0, of: today) ?? now

        // Handle overnight ranges (e.g., 8:00 PM - 2:00 AM)
        if endDate <= startDate {
            endDate = calendar.date(byAdding: .day, value: 1, to: endDate) ?? endDate
        }

        return (now >= startDate && now <= endDate)
    }

    private var isOpenNow: Bool {
        // Find today's entries from displayOpeningHours and check if now is within any range
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: Date()) // 1=Sunday ... 7=Saturday

        // Map to localized day strings used in displayOpeningHours
        let daysEN = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let todayNameEN = daysEN[(weekdayIndex - 1) % 7]

        // Depending on selected language, the displayOpeningHours might contain localized names
        let todayNames: [String]
        if selectedLanguageCode == "my" {
            let daysMM = ["တနင်္ဂနွေ", "တင်္နလာ", "အင်္ဂါ", "ဗုဒ္ဒဟူး", "ကြာသပတေး", "သောကြာ", "စနေ"]
            todayNames = [daysMM[(weekdayIndex - 1) % 7]]
        } else {
            todayNames = [todayNameEN]
        }

        let candidates = displayOpeningHours.filter { todayNames.contains($0.openingDay ?? "") }
        print("candidates = \(candidates)")

        // If there are multiple time ranges for today, open if any range matches
        let now = Date()
        for o in candidates {
            let open = o.openingTime ?? ""
            let close = o.closingTime ?? ""
            if !open.isEmpty && !close.isEmpty {
                if isTime(now, between: open, and: close) { return true }
            }
        }
        
        if (candidates.isEmpty) {
            // this is for everyday
            let open = displayOpeningHours[0].openingTime ?? ""
            let close = displayOpeningHours[0].closingTime ?? ""
            if !open.isEmpty && !close.isEmpty {
                if isTime(now, between: open, and: close) { return true }
            }
        }
        
        return false
    }
    
    private var displayManualClosingDays: [ManualClosingDay] {
        // If API data exists, map it to display model; otherwise return empty list
        guard let closingDays = vm.restaurantDetail?.manualClosingDays else { return [] }
        
        return closingDays.map { (c: ApiManualClosingDay) in
            ManualClosingDay(
                id: UUID().uuidString,
                closingDate: c.closingDate ?? "",
                closingInfo: c.closingInfo ?? ""
            )
        }
    }
    
    private func updateTodaysClosingDay() {
        // API provides dates as yyyy-MM-dd; compare against today's date in the same format
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        
        let todayString = formatter.string(from: Date())
        if let match = displayManualClosingDays.first(where: { $0.closingDate == todayString }) {
            todaysClosingDay = match
        } else {
            todaysClosingDay = nil
        }
    }
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        )
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !vm.isLoading {
                    VStack(alignment: .leading, spacing: 0) {
                        //                        Image("DefaultRestaurantImage")
                        //                            .resizable()
                        //                            .scaledToFill()
                        //                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        //                            .clipped()
                        //                            .padding(.bottom, -8)
                        let screenWidth = UIScreen.main.bounds.width
                        
                        RemoteFillImage(url: URL(string: vm.restaurantDetail?.restaurantImageURL ?? ""), height: 300, placeholderImageName: "DefaultRestaurantImage")
                            .frame(maxWidth: screenWidth)
                        
                        // Name & Rating
                        ScrollView {
                            VStack(spacing: 0) {
                                VStack {
                                    HStack(alignment: .top) {
                                        VStack {
                                            VStack(spacing: 8) {
                                                Text((selectedLanguageCode == "my" ? vm.restaurantDetail?.nameMM : vm.restaurantDetail?.name) ?? "")
                                                    .font(.custom("Futura-Medium", size: 18.0))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.top, 8)
                                                Text(displayCuisineTypes.map { selectedLanguageCode == "my" ? $0.nameMM : $0.name }.joined(separator: ", "))
                                                    .font(.custom("Futura-Medium", size: 12.0))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            
                                            HStack(spacing: 8) {
                                                VStack(alignment: .center, spacing: 8) {
                                                    VStack(spacing: 4) {
                                                        VStack(spacing: 4) {
                                                            StarRatingView(rating: vm.restaurantDetail?.overallRating ?? 0, maxRating: 5, size: 16, filledColor: Color("SecondaryColor"))
                                                                .frame(alignment: .leading)
                                                            
                                                            Text(String(format: "%.1f", vm.restaurantDetail?.overallRating ?? 0))
                                                                .font(.custom("Futura-Medium", size: 18.0))
                                                                .frame(alignment: .leading)
                                                                .padding(.top, 4)
                                                            
                                                            Text("\(vm.restaurantDetail?.totalRatings ?? 0) ratings")
                                                                .font(.custom("Futura-Medium", size: 12.0))
                                                                .frame(alignment: .leading)
                                                        }
                                                        .padding(.top, 8)
                                                    }
                                                }
                                                
                                                
                                                Button {
//                                                    selectedRating = max(1, Int(round(vm.restaurantDetail?.overallRating ?? 0)))
                                                    showRatingDialog = true
                                                } label: {
                                                    Text("Rate")
                                                        .font(.custom("Futura-Medium", size: 14.0))
                                                        .foregroundStyle(Color("PrimaryColor"))
                                                        .frame(maxWidth: 80)
                                                        .padding(.vertical, 5)
                                                }
                                                .buttonStyle(.borderedProminent)
                                                .tint(.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 26)
                                                        .stroke(Color("SecondaryColor"), lineWidth: 1)
                                                )
                                                
                                                Spacer()
                                            }
                                            .padding(.bottom, 16)
                                        }
                                        .padding(.leading, 8)
                                        
                                        let badgeIconName: String = {
                                            switch vm.restaurantDetail?.badge {
                                            case "Silver":
                                                return "SilverBadge"
                                            case "Gold":
                                                return "GoldBadge"
                                            case "Platinum":
                                                return "PlatinumBadge"
                                            default:
                                                return ""
                                            }
                                        }()
                                        Image(badgeIconName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 80)
                                            .padding(.top, 10)
                                    }
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                                    
                                }
                                .background(
                                    Color(.white)
                                        .clipShape(RoundedCornerForChoosePhoneOrEmail(radius: 45, corners: [.bottomLeft, .bottomRight]))
                                )
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                // Description
                                if !description.isEmpty {
                                    Text("detail.about")
                                        .font(.custom("Futura-Medium", size: 16.0))
                                        .foregroundColor(Color("PrimaryColor"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 8)
                                        .padding(.leading, 24)
                                    
                                    Text(description)
                                        .font(.custom("Futura-Medium", size: 16.0))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 8)
                                        .padding(.bottom, 8)
                                        .padding(.leading, 24)
                                        .padding(.trailing, 24)
                                }
                                
                                //Promotion
                                if !promotionValue.isEmpty {
                                    VStack {
                                        if !couponCode.isEmpty {
                                            Text("To get \(promotionValue) promotion, please use this coupon code \(couponCode) when you visit our restaurant")
                                                .font(.custom("Futura-Medium", size: 14.0))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.top, 8)
                                        }
                                        
                                        if !promotionText.isEmpty {
                                            Text("detail.promotion.info")
                                                .font(.custom("Futura-Medium", size: 15.0))
                                                .foregroundStyle(Color("SecondaryColor"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.top, 4)
                                            
                                            Text(promotionText)
                                                .font(.custom("Futura-Medium", size: 14.0))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.top, 1)
                                        }
                                        
                                        
                                    }
                                    .padding(.leading, 24)
                                }
                                
                                
                                if !displayContacts.isEmpty {
                                    // Contact
                                    Text("detail.contact")
                                        .font(.custom("Futura-Medium", size: 16.0))
                                        .foregroundColor(Color("PrimaryColor"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 8)
                                        .padding(.leading, 24)
                                }
                                
                                // Contacts
                                LazyVStack(spacing: 0) {
                                    if !displayContacts.isEmpty {
                                        ScrollView {
                                            LazyVStack(spacing: 0) {
                                                ForEach(displayContacts) { contact in
                                                    ContactRow(contact: contact)
                                                        .padding(.horizontal, 24)
                                                        .onTapGesture {
                                                            
                                                        }
                                                }
                                            }
                                        }
                                    }
                                    //                                    else {
                                    //                                        Text("No contacts available")
                                    //                                            .foregroundStyle(.secondary)
                                    //                                            .padding(.horizontal, 24)
                                    //                                            .padding(.top, 8)
                                    //                                    }
                                }
                                
                                if vm.restaurantDetail?.badge != "Free" {
                                    // Social Links (resolved via switch in populateSocialLinks)
                                    HStack(spacing: 16) {
                                        // Facebook
                                        if !facebookLink.isEmpty {
                                            Button(action: {
                                                print("facebookLink:", facebookLink)
                                                // Open facebookLink in Safari (more robust)
                                                let raw = facebookLink.trimmingCharacters(in: .whitespacesAndNewlines)
                                                guard !raw.isEmpty else { return }
                                                
                                                func webURLString(from raw: String) -> String {
                                                    let lower = raw.lowercased()
                                                    
                                                    if lower.hasPrefix("http://") || lower.hasPrefix("https://") {
                                                        return raw
                                                    }
                                                    
                                                    if lower.hasPrefix("fb://") {
                                                        // Try to convert some common fb:// forms to web equivalents
                                                        // fb://profile/123 -> https://www.facebook.com/profile.php?id=123
                                                        // fb://page/123 -> https://www.facebook.com/123
                                                        let remainder = raw.dropFirst("fb://".count)
                                                        
                                                        if remainder.hasPrefix("profile/") {
                                                            let id = remainder.dropFirst("profile/".count)
                                                            return "https://www.facebook.com/profile.php?id=\(id)"
                                                        } else if remainder.hasPrefix("page/") {
                                                            let id = remainder.dropFirst("page/".count)
                                                            return "https://www.facebook.com/\(id)"
                                                        } else {
                                                            // Fallback: just append after www.facebook.com/
                                                            return "https://www.facebook.com/\(remainder)"
                                                        }
                                                    }
                                                    
                                                    // If it looks like a domain or path, prepend https://
                                                    return "https://\(raw)"
                                                }
                                                
                                                let candidate = webURLString(from: raw)
                                                
                                                // Percent-encode if needed (only path/query parts)
                                                let encoded: String = {
                                                    if let url = URL(string: candidate), !url.absoluteString.isEmpty {
                                                        return candidate
                                                    } else if var components = URLComponents(string: candidate) {
                                                        // If path contains spaces etc.
                                                        components.path = components.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? components.path
                                                        components.percentEncodedQuery = components.query // keep as-is
                                                        return components.string ?? candidate
                                                    } else {
                                                        return candidate.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? candidate
                                                    }
                                                }()
                                                
                                                if let url = URL(string: encoded) {
                                                    print("Opening URL:", url.absoluteString)
                                                    openURLAction(url)
                                                } else {
                                                    print("Invalid URL:", encoded)
                                                }
                                            }) {
                                                Image("Facebook")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 30, height: 30)
                                                    .contentShape(Rectangle())
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        
                                        // Tiktok
                                        if !tiktokLink.isEmpty {
                                            Button(action: {
                                                let raw = tiktokLink.trimmingCharacters(in: .whitespacesAndNewlines)
                                                guard !raw.isEmpty else { return }
                                                
                                                func tiktokURLString(from raw: String) -> String {
                                                    let lower = raw.lowercased()
                                                    if lower.hasPrefix("http://") || lower.hasPrefix("https://") || lower.hasPrefix("tiktok://") {
                                                        return raw
                                                    }
                                                    // Assume it's a handle or path
                                                    return "https://www.tiktok.com/\(raw)"
                                                }
                                                
                                                let candidate = tiktokURLString(from: raw)
                                                let encoded: String = {
                                                    if let url = URL(string: candidate), !url.absoluteString.isEmpty {
                                                        return candidate
                                                    } else if var components = URLComponents(string: candidate) {
                                                        components.path = components.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? components.path
                                                        components.percentEncodedQuery = components.query
                                                        return components.string ?? candidate
                                                    } else {
                                                        return candidate.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? candidate
                                                    }
                                                }()
                                                
                                                if let url = URL(string: encoded) {
                                                    print("Opening URL:", url.absoluteString)
                                                    openURLAction(url)
                                                }
                                            }) {
                                                Image("Tiktok")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 30, height: 30)
                                                    .contentShape(Rectangle())
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        
                                        // Viber
                                        if !viberNo.isEmpty {
                                            Button(action: {
                                                // Note: To open viber:// URLs, ensure LSApplicationQueriesSchemes includes "viber" in Info.plist.
                                                let raw = viberNo.trimmingCharacters(in: .whitespacesAndNewlines)
                                                guard !raw.isEmpty else { return }
                                                
                                                // Normalize phone: keep leading '+' and digits
                                                let normalized: String = {
                                                    var result = ""
                                                    for (i, ch) in raw.enumerated() {
                                                        if ch.isNumber { result.append(ch) }
                                                        else if ch == "+", i == 0 { result.append(ch) }
                                                    }
                                                    return result
                                                }()
                                                
                                                let appURLString = "viber://chat?number=\(normalized)"
                                                let fallbackURLString = "https://invite.viber.com/?g2=\(normalized)"
                                                
                                                let tryOpen: (String) -> Bool = { s in
                                                    if let url = URL(string: s) {
                                                        if UIApplication.shared.canOpenURL(url) {
                                                            openURLAction(url)
                                                            return true
                                                        }
                                                        else {
                                                            print("Viber is not installed")
                                                        }
                                                    }
                                                    return false
                                                }
                                                
                                                if !tryOpen(appURLString) {
                                                    _ = tryOpen(fallbackURLString)
                                                }
                                            }) {
                                                Image("Viber")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 30, height: 30)
                                                    .contentShape(Rectangle())
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        
                                        // Wechat
                                        if !wechatLink.isEmpty {
                                            Button(action: {
                                                let raw = wechatLink.trimmingCharacters(in: .whitespacesAndNewlines)
                                                guard !raw.isEmpty else { return }
                                                
                                                func wechatURLString(from raw: String) -> String {
                                                    let lower = raw.lowercased()
                                                    if lower.hasPrefix("http://") || lower.hasPrefix("https://") || lower.hasPrefix("weixin://") || lower.hasPrefix("wechat://") {
                                                        return raw
                                                    }
                                                    // Assume it's a path or id; use WeChat global site as base
                                                    return "https://weixin.qq.com/\(raw)"
                                                }
                                                
                                                let candidate = wechatURLString(from: raw)
                                                let encoded: String = {
                                                    if let url = URL(string: candidate), !url.absoluteString.isEmpty {
                                                        return candidate
                                                    } else if var components = URLComponents(string: candidate) {
                                                        components.path = components.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? components.path
                                                        components.percentEncodedQuery = components.query
                                                        return components.string ?? candidate
                                                    } else {
                                                        return candidate.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? candidate
                                                    }
                                                }()
                                                
                                                if let url = URL(string: encoded) {
                                                    print("Opening URL:", url.absoluteString)
                                                    openURLAction(url)
                                                }
                                            }) {
                                                Image("Wechat")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 30, height: 30)
                                                    .contentShape(Rectangle())
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 4)
                                    .padding(.leading, 24)

                                }
                                                                
                                // About
//                                Text("detail.about")
//                                    .font(.custom("Futura-Medium", size: 18.0))
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.top, 16)
//                                    .padding(.leading, 24)
                                
                                if !displayOpeningHours.isEmpty {
                                    Text("detail.openingHours")
                                        .font(.custom("Futura-Medium", size: 16.0))
                                        .foregroundColor(Color("PrimaryColor"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 8)
                                        .padding(.leading, 24)
                                    
                                    // Open/Close status for today
//                                    HStack(spacing: 8) {
//                                        Circle()
//                                            .fill(isOpenNow ? Color.green : Color.red)
//                                            .frame(width: 8, height: 8)
//                                        Text(isOpenNow ? "Open now" : "Closed now")
//                                            .font(.system(size: 14, weight: .semibold))
//                                            .foregroundStyle(isOpenNow ? Color.green : Color.red)
//                                    }
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 24)
//                                    .padding(.bottom, 6)
                                    
                                    HStack {
                                        // Opening Hours
                                        LazyVStack(spacing: 0) {
                                            if !displayOpeningHours.isEmpty {
                                                ScrollView {
                                                    LazyVStack(spacing: 0) {
                                                        ForEach(displayOpeningHours) { openingHour in
                                                            OpeningHourRow(openingHour: openingHour)
                                                                .padding(.leading, 24)
                                                                .onTapGesture {
                                                                    
                                                                }
                                                        }
                                                    }
                                                }
                                            }
                                            else {
                                                Text("No opening hours available")
                                                    .foregroundStyle(.secondary)
                                                    .padding(.horizontal, 24)
                                            }
                                            
                                            if displayOpeningHours.count == 1 {
                                                Text("") // for the height of open / close icon
                                                
                                                Text("")
                                            }
                                        }
                                        
                                        Image(isOpenNow && todaysClosingDay == nil ? "ShopOpened" : "ShopClosed")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 70, height: 40)
                                            .padding(.trailing, 24)
                                    }
                                }
                                
                                // Closing Reason (only if today matches a manual closing day)
                                if let closing = todaysClosingDay {
                                    Text(closing.closingInfo.isEmpty ? "" : closing.closingInfo)
                                        .font(.custom("Futura-Medium", size: 14.0))
                                        .foregroundStyle(Color("PrimaryColor"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 24)
                                        .padding(.trailing, 100)
                                }
                                
                                Divider()
                                    .background(Color.gray)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                
                                // Address
                                if let address = vm.restaurantDetail?.address?.trimmingCharacters(in: .whitespacesAndNewlines), !address.isEmpty {
                                    Text("detail.address")
                                        .font(.custom("Futura-Medium", size: 16.0))
                                        .foregroundColor(Color("PrimaryColor"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 24)
                                    
                                    
                                    
                                    Text(address)
                                        .font(.custom("Futura-Medium", size: 14.0))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 4)
                                        .padding(.leading, 24)
                                }
                                
                                Map(position: $position) {
                                    if let coordinate = mapCoordinate {
                                        Annotation((selectedLanguageCode == "my" ? vm.restaurantDetail?.nameMM : vm.restaurantDetail?.name) ?? "", coordinate: coordinate) {
                                            Image("Location")
                                                .renderingMode(.template)
                                                .foregroundStyle(Color("PrimaryColor"))
                                                .onTapGesture {
                                                    let restaurantName = (selectedLanguageCode == "my" ? vm.restaurantDetail?.nameMM : vm.restaurantDetail?.name) ?? ""
                                                    let placemark = MKPlacemark(coordinate: coordinate)
                                                    let mapItem = MKMapItem(placemark: placemark)
                                                    mapItem.name = restaurantName
                                                    let zoomSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                                                    mapItem.openInMaps(launchOptions: [
                                                        MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate),
                                                        MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: zoomSpan)
                                                    ])
                                                }
                                        }
                                    }
                                }
                                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                                    .padding(.top, 8)
                                    .padding(.leading, 12)
                                    .padding(.trailing, 12)
                                
                                Button {
                                    navigateToMenu = true
                                } label: {
                                    Text("detail.button.menu")
                                        .font(.custom("Futura-Medium", size: 14.0))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: 250)
                                        .padding(8)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color("PrimaryColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.white, lineWidth: 2)
                                )
                                .padding(20)
                                
                                //                            Spacer()
                            }
                            
                        }
                    }
                    .ignoresSafeArea(edges: .top)
                    .ignoresSafeArea(edges: .bottom)
                }
                
                // Rating dialog overlay
                if showRatingDialog {
                    ZStack {
                        // Dimmed background
                        Color.black.opacity(0.35)
                            .ignoresSafeArea()
                            .onTapGesture { showRatingDialog = false }
                        
                        RatingDialog(title: "rating.title",
                                     ratingFromApi: vm.ratingFromApi,
                                     selectedRating: vm.ratingFromApi != 0 ? $vm.ratingFromApi : $selectedRating,
                                     onCancel: { showRatingDialog = false },
                                     onSubmit: {
                            print("selectedRating = \(selectedRating)")
                            print("restaurantId = \(initialRestaurantId)")
                            let parentId = vm.restaurantDetail?.parent_id ?? 0
                            print("parent_id = \(parentId)")
                            vm.reviewableId = initialRestaurantId
//                            vm.reviewableType = parentId == 0 ? "App\\Models\\Restaurant" : "App\\Models\\Branch"
                            vm.reviewableType = "App\\Models\\Restaurant"
                            vm.rating = selectedRating
                            vm.comment = "Submit Rating"
                            Task { await vm.submitRating() }
                            //                            if vm.errorMessage.isEmpty {
                            //                                showRatingDialog = false
                            //                            }
                        })
                        .padding(24)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: showRatingDialog)
                }
                
                // Centered loading overlay
                if vm.isLoading {
                    CommonLoading()
                }
                
                // Error banner stays above content
                if let message = vm.errorMessage != "" ? vm.errorMessage : nil {
                    VStack {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                            Text(message)
                                .foregroundStyle(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Button("Dismiss") { vm.errorMessage = "" }
                                .font(.footnote)
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .padding(.horizontal, 24)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .allowsHitTesting(true)
                }
                
                if showSubmitRatingSuccess {
                    VStack {
                        Spacer()
                        ToastView(message: "rating.thanks", isSuccess: true, onDismiss: {
                            showSubmitRatingSuccess = false
                        })
                            .onTapGesture { showSubmitRatingSuccess = false }
                            .padding(.bottom, 48)
                    }
                    .animation(.easeInOut, value: showSubmitRatingSuccess)
                }
                
                VStack {
                    HStack {
                        Image("DetailBack")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .onTapGesture {
//                                dismiss()
                                switch comeFrom {
                                case "home": navigateToHome = true
                                case "promotion": navigateToPromotion = true
                                case "restaurant": navigateToRestaurant = true
                                case "nearBy": navigateToNearBy = true
                                case "favorite": navigateToFavorite = true
                                case "search": navigateToSearch = true
                                default: navigateToHome = true
                                }
                                
                            }
                            .padding(.leading, 24)
                        
                        Spacer()
                        
                        if !promotionValue.isEmpty {
                            HStack {
                                Text(promotionValue)
                                    .font(.custom("Futura-Medium", size: 12.0))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                    .background(Color("PrimaryColor"))
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 10)
                            .padding(.trailing, 24)
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Button {
                            showFavoriteConfirm = true
                        } label: {
                            Image(isFavorite ? "FavoriteSelected" : "FavoriteUnselected")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(.plain)
                        .alert(isFavorite ? "Remove from Favorites?" : "Add to Favorites?", isPresented: $showFavoriteConfirm, actions: {
                            
                            if isFavorite {
                                Button("Remove", role: .destructive) {
                                    favorite_vm.favoriteableId = favoriteId
                                    Task {
                                        await favorite_vm.removeFavorite()
                                        withAnimation(.easeInOut) {
                                            isFavorite = false
                                        }
                                    }
                                }
                            } else {
                                Button("Add") {
                                    favorite_vm.favoriteableId = restaurantId
                                    Task {
                                        await favorite_vm.addFavorite()
                                        withAnimation(.easeInOut) {
                                            isFavorite = true
                                        }
                                    }
                                }
                            }
                            Button("Cancel", role: .cancel) { }
                        }, message: {
                            Text(isFavorite ? "This restaurant will be removed from your favorites." : "This restaurant will be added to your favorites.")
                        })
                        .padding(.trailing, 24)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 140)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 60)
                //            .background(.red)
                
            }
            .ignoresSafeArea()
            .navigationDestination(isPresented: $navigateToHome) {
                CustomTabView(selectedTab: .home)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToPromotion) {
                CustomTabView(selectedTab: .promotion)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToRestaurant) {
                CustomTabView(selectedTab: .restaurant)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToNearBy) {
                NearByRestaurantsView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToFavorite) {
                FavoritesView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToSearch) {
                SearchView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToMenu) {
                RestaurantMenuView(
                    restaurantId: restaurantId,
                    restaurantName: (selectedLanguageCode == "my" ? vm.restaurantDetail?.nameMM : vm.restaurantDetail?.name) ?? "",
                    comeFrom: comeFrom)
                    .navigationBarBackButtonHidden(true)
            }
            .task {
                await vm.getRestaurantById(id: initialRestaurantId)
                
                if auth.isAuthenticated {
                    await favorite_vm.getAllFavorites()
                    
                    isFavorite = favorite_vm.favorites.contains {
                        $0.favoritable.id == restaurantId
                    }
                    
                    let favorite = favorite_vm.favorites.first {
                        $0.favoritable.id == restaurantId
                    }

                    favoriteId = favorite?.id ?? 0
                    
                    await vm.getRatingByUserId(reviewableId: restaurantId)
                }
                
                updateMapPositionIfAvailable()
                // Populate social links using switch-based resolver
                populateSocialLinks()
                updateTodaysClosingDay()
            }
            .task {
                guard auth.isAuthenticated else { return }
                // Make sure these functions don’t set isAuthenticated = false on generic errors
                await favorite_vm.getAllFavorites()
                isFavorite = favorite_vm.favorites.contains { $0.favoritable.id == restaurantId }
                await vm.getRatingByUserId(reviewableId: restaurantId)
            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
        .onAppear {
            print("isAuthenticated = \(auth.isAuthenticated)")
        }
        .onChange(of: vm.apiSuccessForSubmitRating) { _, newValue in
            if newValue {
                showRatingDialog = false
                showSubmitRatingSuccess = true
                
                Task {
                    await vm.getRatingByUserId(reviewableId: restaurantId)
                    await vm.getRestaurantById(id: initialRestaurantId)
                }
            }
        }
        .onChange(of: vm.showError) { _, newValue in
            if newValue {
                showRatingDialog = false
            }
        }
    }
    
    private func updateMapPositionIfAvailable() {
        // latitude/longitude are coming from the API as optional Strings; convert safely to Double
        guard
            let latString = vm.restaurantDetail?.latitude,
            let lonString = vm.restaurantDetail?.longitude,
            let lat = Double(latString),
            let lon = Double(lonString)
        else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        )
        position = .region(region)
    }
}

private struct RatingDialog: View {
    let title: String
    let ratingFromApi: Int
    @Binding var selectedRating: Int
    var onCancel: () -> Void
    var onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            
            HStack {
                Spacer()
                
                Image("Close")
                    .onTapGesture {
                        onCancel()
                    }
            }
            
            Text(LocalizedStringKey(title))
                .font(.custom("Futura-Medium", size: 16.0))
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Interactive stars (1..5)
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= selectedRating ? "star.fill" : "star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(star <= selectedRating ? Color("SecondaryColor") : Color.gray.opacity(0.5))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRating = star
                        }
                        .accessibilityLabel("Rate \(star) star\(star == 1 ? "" : "s")")
                }
            }
            .padding(.vertical, 8)
            
            HStack(spacing: 12) {
                if ratingFromApi != 0 {
                    Text("rating.thanks")
                        .font(.custom("Futura-Medium", size: 14.0))
                }
                else {
                    Button { onSubmit() } label: {
                        Text("Submit")
                            .font(.custom("Futura-Medium", size: 14.0))
                            .frame(maxWidth: 140)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("PrimaryColor"))
                }
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(radius: 12)
        .frame(maxWidth: 360)
    }
}

#Preview {
    RestaurantDetailView(restaurantId: 2, comeFrom: "home")
        .environmentObject(AuthViewModel())
}


