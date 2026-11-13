import Foundation

enum WidgetIdentity {
    static let group = "group.com.matchmatrix.analytics"
    static let kind = "com.matchmatrix.analytics.progress"
    static let scheme = "matchmatrix"
    static let route = "saved"
    static let displayName = "Match Matrix"
    static let emptyHint = "Record a result in your notebook."
    static let widgetName = "Match notebook"
    static let widgetDescription = "Your recorded results and saved matches."
    static let icon = "chart.bar.xaxis"
    static let theme = "notebook"
    static let accent: [Double] = [0.96, 0.83, 0.31]
    static let background: [Double] = [0.09, 0.16, 0.13]
    static let serif = false
    static var url: URL { URL(string: "\(scheme)://widget/\(route)")! }
    static func accepts(_ url: URL) -> Bool { url.scheme == scheme && url.host == "widget" && url.path == "/" + route }
}
