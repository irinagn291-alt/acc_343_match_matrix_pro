import Foundation
@main struct LogicTests {
 static func main() {
  let rows = [Match(id: 0, day: 0, home: 0, away: 1, homeGoals: 2, awayGoals: 0, league: "A"), Match(id: 1, day: 1, home: 1, away: 0, homeGoals: 1, awayGoals: 1, league: "A"), Match(id: 2, day: 2, home: 0, away: 1, homeGoals: 0, awayGoals: 3, league: "B"), Match(id: 3, day: 3, home: 0, away: 1, homeGoals: nil, awayGoals: nil, league: "A")]
  let all = aggregate(rows, team: 0, filter: Filter())
  precondition(all.count == 3 && all.wins == 1 && all.draws == 1 && all.losses == 1)
  precondition(all.scored == 3 && all.conceded == 4 && all.clean == 1)
  precondition(all.value(.goalsRate) == "1.00")
  precondition(aggregate(rows, team: 0, filter: Filter(limit: 1)).matches.first?.id == 2)
  precondition(aggregate(rows, team: 0, filter: Filter(venue: .away)).count == 1)
  precondition(aggregate(rows, team: 0, filter: Filter(venue: .home)).scored == 2)
  precondition(aggregate(rows, team: 0, filter: Filter(league: "A")).count == 2)
  for metric in Metric.allCases { precondition(aggregate([], team: 0, filter: Filter()).value(metric) == "—") }
  let roundtrip = try! JSONDecoder().decode(Workspace.self, from: JSONEncoder().encode(Workspace(savedMatches: [1], comparisons: [SavedComparison(first: 0, second: 1, filter: Filter(venue: .home))])))
  precondition(roundtrip.savedMatches == [1] && roundtrip.comparisons.first?.filter.venue == .home)
  precondition(aggregate(Array(repeating: rows[0], count: 1001), team: 0, filter: Filter(limit: 999)).count == 1001)
  let notebook = Notebook(teams: [Team(id: 40, name: "Local team", short: "LOC")], matches: rows)
  let restored = try! JSONDecoder().decode(Notebook.self, from: JSONEncoder().encode(notebook))
  precondition(restored.teams.first?.id == 40 && restored.matches.count == 4)
  print("PASS: aggregates, rates, newest-first limit, home/away, competition, empty samples, upcoming exclusion, persistence round-trip, fixture integrity")
 }
}
