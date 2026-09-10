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
        // TODO: Implement proper date parsing
        return nil
    }
}

// MARK: - LazyLoader
struct LazyLoader<Value: Equatable>: Equatable {
    let value: Value
}
