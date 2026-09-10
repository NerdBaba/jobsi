import SwiftUI

extension View {
    @ViewBuilder
    public func hiddenInMenu() -> some View {
        #if os(macOS)
        self.hidden()
        #else
        self
        #endif
    }
}

extension Text {
    static func parseDate(_ dateString: String) -> Date? {
        let lowercased = dateString.lowercased()
        
        // Handle relative date formats like "1 day ago", "2 days ago", etc.
        if lowercased.contains("day") {
            let components = lowercased.components(separatedBy: " ")
            guard let numberString = components.first,
                  let number = Int(numberString) else { return nil }
            
            let calendar = Calendar.current
            return calendar.date(byAdding: .day, value: -number, to: Date())
        }
        
        // Handle "X hours ago"
        if lowercased.contains("hour") {
            let components = lowercased.components(separatedBy: " ")
            guard let numberString = components.first,
                  let number = Int(numberString) else { return nil }
            
            let calendar = Calendar.current
            return calendar.date(byAdding: .hour, value: -number, to: Date())
        }
        
        // Handle "X minutes ago"
        if lowercased.contains("minute") {
            let components = lowercased.components(separatedBy: " ")
            guard let numberString = components.first,
                  let number = Int(numberString) else { return nil }
            
            let calendar = Calendar.current
            return calendar.date(byAdding: .minute, value: -number, to: Date())
        }
        
        // Try standard date formats as fallback
        let formatters = [
            "yyyy-MM-dd",
            "MM/dd/yyyy",
            "dd/MM/yyyy",
            "MMM dd, yyyy"
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
}

// MARK: - LazyLoader
struct LazyLoader<Value: Equatable>: Equatable {
    let value: Value
}
