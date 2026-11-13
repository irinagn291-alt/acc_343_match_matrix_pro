import Foundation

struct Team: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let name: String
    let short: String

}
struct Match: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let day: Int
    let home: Int
    let away: Int
    let homeGoals: Int?
    let awayGoals: Int?
    let league: String
    var homeLineup: String = ""
    var awayLineup: String = ""
    var notes: String = ""
    var played: Bool { homeGoals != nil && awayGoals != nil }
    var dateLabel: String { Calendar(identifier: .gregorian).date(byAdding: .day, value: day, to: Date(timeIntervalSince1970: 1788220800))!.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, locale: Locale(identifier: "en_GB"), timeZone: TimeZone(secondsFromGMT: 0)!)) }
    func goals(_ team: Int) -> Int? { team == home ? homeGoals : awayGoals }
    func conceded(_ team: Int) -> Int? { team == home ? awayGoals : homeGoals }
}
enum Venue: String, CaseIterable, Codable, Sendable { case all = "All venues", home = "Home", away = "Away" }
struct Filter: Codable, Equatable, Sendable {
    var limit = 10
    var venue = Venue.all
    var league = "All competitions"
}
struct Summary {
    let matches: [Match]
    let team: Int
    var count: Int { matches.count }
    var wins: Int { matches.filter { $0.goals(team)! > $0.conceded(team)! }.count }
    var draws: Int { matches.filter { $0.goals(team) == $0.conceded(team) }.count }
    var losses: Int { count - wins - draws }
    var scored: Int { matches.reduce(0) { $0 + $1.goals(team)! } }
    var conceded: Int { matches.reduce(0) { $0 + $1.conceded(team)! } }
    var clean: Int { matches.filter { $0.conceded(team) == 0 }.count }
    func value(_ metric: Metric) -> String {
        guard count > 0 else { return "—" }
        switch metric {
        case .matches: return "\(count)"
        case .wins: return "\(wins)"
        case .draws: return "\(draws)"
        case .losses: return "\(losses)"
        case .scored: return "\(scored)"
        case .conceded: return "\(conceded)"
        case .goalsRate: return String(format: "%.2f", Double(scored) / Double(count))
        case .againstRate: return String(format: "%.2f", Double(conceded) / Double(count))
        case .clean: return "\(clean)"
        }
    }
}
enum Metric: String, CaseIterable, Identifiable, Codable { case matches = "Matches", wins = "Wins", draws = "Draws", losses = "Losses", scored = "Goals scored", conceded = "Goals conceded", goalsRate = "Goals / match", againstRate = "Conceded / match", clean = "Clean sheets"; var id: String { rawValue } }
func aggregate(_ matches: [Match], team: Int, filter: Filter) -> Summary {
    let selected = matches.filter { m in
        m.played && (m.home == team || m.away == team) && (filter.venue == .all || (filter.venue == .home ? m.home == team : m.away == team)) && (filter.league == "All competitions" || m.league == filter.league)
    }.sorted { $0.day == $1.day ? $0.id > $1.id : $0.day > $1.day }
    return Summary(matches: Array(selected.prefix(filter.limit == 999 ? selected.count : max(0, filter.limit))), team: team)
}
struct SavedComparison: Codable, Identifiable { var id = UUID(); let first: Int; let second: Int; let filter: Filter }
struct Workspace: Codable { var savedMatches: Set<Int> = []; var comparisons: [SavedComparison] = []; var metrics: [Metric] = [.goalsRate, .againstRate, .clean]; var resultsFirst = true }

struct Notebook: Codable { var teams: [Team] = []; var matches: [Match] = []; var workspace = Workspace(); var updated: Date = Date() }
