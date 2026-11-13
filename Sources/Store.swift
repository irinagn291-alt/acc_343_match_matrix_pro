import SwiftUI
@MainActor @Observable final class Store {
    var matches: [Match] = []
    var teams: [Team] = []
    var storageError: String?
    var workspace = Workspace()
    var selected: [Int] = []
    var filter = Filter()
    var first = -1
    var second = -1
    var tab = 0
    var updated = Date()
    private let url: URL
    private var readable = true
    #if DEBUG && targetEnvironment(simulator)
    private var screenshotMemoryOnly = false

    convenience init(screenshot: ScreenshotRoute) {
        // This URL is never read or written; capture data stays in memory.
        self.init(emptyScreenshotStore: ())
        screenshotMemoryOnly = true
        teams = [Team(id: 0, name: "Harbour United", short: "HAR"),
                 Team(id: 1, name: "Hilltop City", short: "HIL")]
        matches = [
            Match(id: 0, day: 61, home: 0, away: 1, homeGoals: 2, awayGoals: 0, league: "Sunday League", homeLineup: "Alex Morgan, Sam Taylor, Jordan Lee", awayLineup: "Jamie Brown, Casey Green, Robin Cole", notes: "Strong first half and a clean sheet."),
            Match(id: 1, day: 68, home: 1, away: 0, homeGoals: 1, awayGoals: 1, league: "Sunday League"),
            Match(id: 2, day: 70, home: 0, away: 1, homeGoals: 0, awayGoals: 3, league: "Sunday League"),
            Match(id: 3, day: 80, home: 0, away: 1, homeGoals: nil, awayGoals: nil, league: "Sunday League")
        ]
        first = 0; second = 1
        workspace.savedMatches = [0]
        workspace.comparisons = [SavedComparison(first: 0, second: 1, filter: filter)]
        switch screenshot {
        case .teamComparison, .metricEvidence: tab = 1
        case .savedWorkspace: tab = 2
        default: tab = 0
        }
    }

    private init(emptyScreenshotStore: Void) {
        url = URL.temporaryDirectory.appending(path: "match-matrix-screenshot-unused.json")
    }
    #endif
    init(url: URL? = nil) {
        self.url = url ?? URL.documentsDirectory.appending(path: "notebook-v2.json")
        if FileManager.default.fileExists(atPath: self.url.path) {
            do {
                let book = try JSONDecoder().decode(Notebook.self, from: Data(contentsOf: self.url))
                teams = book.teams; matches = book.matches; workspace = book.workspace; updated = book.updated
            } catch { readable = false; storageError = "Your notebook could not be read. The original file has been kept. Please relaunch to try again." }
        }
        repairSelection()
        if readable { publishWidget() }
    }
    var competitions: [String] { Array(Set(matches.map(\.league))).sorted() }
    func team(_ id: Int) -> Team { teams.first { $0.id == id } ?? Team(id: id, name: "Choose team", short: "—") }
    func repairSelection() {
        if !teams.contains(where: { $0.id == first }) { first = teams.first?.id ?? -1 }
        if second == first || !teams.contains(where: { $0.id == second }) { second = teams.first { $0.id != first }?.id ?? -1 }
    }
    @discardableResult func persist() -> Bool {
        #if DEBUG && targetEnvironment(simulator)
        if screenshotMemoryOnly { updated = Date(); storageError = nil; return true }
        #endif
        guard readable else { storageError = "The notebook could not be read. Relaunch before saving to protect your existing file."; return false }
        do {
            updated = Date()
            try JSONEncoder().encode(Notebook(teams: teams, matches: matches, workspace: workspace, updated: updated)).write(to: url, options: .atomic)
            storageError = nil; publishWidget(); return true
        } catch { storageError = "Could not save your notebook. Keep the app open and retry saving."; return false }
    }
    func saveTeam(name: String, editing: Int? = nil) -> Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !teams.contains(where: { $0.id != editing && $0.name.caseInsensitiveCompare(name) == .orderedSame }) else { return false }
        let id = editing ?? ((teams.map(\.id).max() ?? -1) + 1)
        let team = Team(id: id, name: name, short: String(name.prefix(3)).uppercased())
        if let index = teams.firstIndex(where: { $0.id == id }) { teams[index] = team } else { teams.append(team) }
        repairSelection(); return persist()
    }
    func deleteTeam(_ id: Int) {
        let ids = Set(matches.filter { $0.home == id || $0.away == id }.map(\.id))
        matches.removeAll { ids.contains($0.id) }; workspace.savedMatches.subtract(ids)
        workspace.comparisons.removeAll { $0.first == id || $0.second == id }
        teams.removeAll { $0.id == id }; selected.removeAll { $0 == id }; repairSelection(); persist()
    }
    func saveMatch(_ match: Match) -> Bool {
        guard match.home != match.away, teams.contains(where: { $0.id == match.home }), teams.contains(where: { $0.id == match.away }), !match.league.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        if let index = matches.firstIndex(where: { $0.id == match.id }) { matches[index] = match } else { matches.append(match) }
        return persist()
    }
    func deleteMatch(_ id: Int) { matches.removeAll { $0.id == id }; workspace.savedMatches.remove(id); persist() }
    func toggleSave(_ id: Int) { if workspace.savedMatches.contains(id) { workspace.savedMatches.remove(id) } else { workspace.savedMatches.insert(id) }; persist() }
    func select(_ id: Int) { if selected.contains(id) { selected.removeAll { $0 == id } } else if selected.count < 2 { selected.append(id) } }
    func saveComparison() { guard first != second, first >= 0, second >= 0, !workspace.comparisons.contains(where: { $0.first == first && $0.second == second && $0.filter == filter }) else { return }; workspace.comparisons.append(SavedComparison(first: first, second: second, filter: filter)); persist() }
    func summary(_ team: Int) -> Summary { aggregate(matches, team: team, filter: filter) }
}
