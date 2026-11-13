import Foundation

extension Store {
    var widgetSnapshot: WidgetSnapshot {
        let played = matches.filter(\.played)
        let saved = workspace.savedMatches.intersection(Set(matches.map(\.id))).count
        let total = Double(max(1,matches.count))
        return WidgetSnapshot(title: "Your match notebook", value: "\(played.count)", label: played.count == 1 ? "result recorded" : "results recorded",
            detail: "\(saved) saved \(saved == 1 ? "match" : "matches") · \(workspace.comparisons.count) \(workspace.comparisons.count == 1 ? "comparison" : "comparisons")", footnote: "Your own recorded results",
            progress: Double(played.count) / total, values: [Double(played.count)/total,Double(saved)/total,min(1,Double(workspace.comparisons.count)/total)])
    }
    func publishWidget() { WidgetStore.publish(widgetSnapshot) }
}

#if DEBUG && targetEnvironment(simulator)
extension Store {
    /// Only explicit UI-test launches in disposable simulators can mutate this fixture.
    func applyWidgetQA(_ url: URL) {
        guard ProcessInfo.processInfo.arguments.contains("-WidgetQA"),
              URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.contains(where: { $0.name == "qa" && ["1", "2"].contains($0.value ?? "") }) == true else { return }
        let secondUpdate = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.contains(where: { $0.name == "qa" && $0.value == "2" }) == true
        if teams.isEmpty { _ = saveTeam(name: "Harbour United"); _ = saveTeam(name: "Hilltop City") }
        if teams.count >= 2 {
            let recordID = secondUpdate ? 9002 : 9001
            _ = saveMatch(Match(id: recordID, day: 61, home: teams[0].id, away: teams[1].id, homeGoals: 2, awayGoals: 1, league: "Widget QA"))
            if !workspace.savedMatches.contains(recordID) { toggleSave(recordID) }
        }
    }
}
#endif
