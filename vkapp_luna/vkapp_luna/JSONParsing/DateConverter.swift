import UIKit


class DateConverter {
    
    static let get = DateConverter()
    private init() {}
    
    public func convertDate(_ timeStampDate: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timeStampDate))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
}
