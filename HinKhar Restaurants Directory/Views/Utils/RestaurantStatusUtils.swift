import Foundation

enum RestaurantStatusUtils {
    static func isRestaurantClosed(
        openingHours: [ApiOpeningHour]?,
        manualClosingDays: [ApiManualClosingDay]?
    ) -> Bool {
        if isManuallyClosedToday(manualClosingDays) {
            return true
        }
        return !isOpenNow(openingHours)
    }

    static func isManuallyClosedToday(_ manualClosingDays: [ApiManualClosingDay]?) -> Bool {
        guard let manualClosingDays else { return false }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        let todayString = formatter.string(from: Date())
        return manualClosingDays.contains { $0.closingDate == todayString }
    }

    static func isOpenNow(_ openingHours: [ApiOpeningHour]?) -> Bool {
        guard let openingHours, !openingHours.isEmpty else { return false }

        let weekdayIndex = Calendar.current.component(.weekday, from: Date())
        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let todayName = dayNames[(weekdayIndex - 1) % 7]
        let now = Date()

        for hour in openingHours {
            let openingDay = (hour.openingDay ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            let isTodayMatch = openingDay == "all" || openingDay == todayName.lowercased()

            if isTodayMatch,
               let openingTime = hour.openingTime,
               let closingTime = hour.closingTime,
               isTime(now, between: openingTime, and: closingTime) {
                return true
            }
        }

        return false
    }

    static func isTime(_ now: Date, between start24h: String, and end24h: String) -> Bool {
        let parser = DateFormatter()
        parser.dateFormat = "HH:mm"
        parser.locale = Locale(identifier: "en_US_POSIX")

        guard let startTime = parser.date(from: start24h),
              let endTime = parser.date(from: end24h) else {
            return false
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        let startComps = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComps = calendar.dateComponents([.hour, .minute], from: endTime)

        let startDate = calendar.date(
            bySettingHour: startComps.hour ?? 0,
            minute: startComps.minute ?? 0,
            second: 0,
            of: today
        ) ?? now

        var endDate = calendar.date(
            bySettingHour: endComps.hour ?? 0,
            minute: endComps.minute ?? 0,
            second: 0,
            of: today
        ) ?? now

        if endDate <= startDate {
            endDate = calendar.date(byAdding: .day, value: 1, to: endDate) ?? endDate
        }

        return now >= startDate && now <= endDate
    }
}
