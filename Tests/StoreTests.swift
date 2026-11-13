import Foundation
@main struct StoreTests {
 @MainActor static func main() {
  let folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
  try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
  defer { try? FileManager.default.removeItem(at: folder) }
  let url = folder.appending(path: "notebook.json")
  let store = Store(url: url)
  precondition(store.teams.isEmpty && store.matches.isEmpty)
  precondition(store.saveTeam(name: "Alpha")); precondition(store.saveTeam(name: "Beta"))
  precondition(!store.saveTeam(name: " alpha "))
  precondition(store.saveMatch(Match(id: 0, day: 0, home: 0, away: 1, homeGoals: 3, awayGoals: 1, league: "Local")))
  store.toggleSave(0); store.saveComparison()
  let restored = Store(url: url)
  precondition(restored.teams.count == 2 && restored.matches.count == 1)
  precondition(restored.workspace.savedMatches == [0] && restored.workspace.comparisons.count == 1)
  precondition(restored.summary(0).scored == 3)
  precondition(restored.saveMatch(Match(id: 0, day: 0, home: 0, away: 1, homeGoals: 1, awayGoals: 1, league: "Local", homeLineup: "Alex", notes: "Wet pitch")))
  precondition(restored.summary(0).draws == 1 && restored.summary(0).scored == 1)
  precondition(Store(url: url).matches.first?.homeLineup == "Alex")
  restored.deleteTeam(0)
  let deleted = Store(url: url)
  precondition(deleted.matches.isEmpty && deleted.workspace.savedMatches.isEmpty && deleted.workspace.comparisons.isEmpty)
  try! Data("invalid".utf8).write(to: url)
  let broken = Store(url: url)
  precondition(broken.storageError != nil && !broken.persist())
  precondition(try! String(contentsOf: url, encoding: .utf8) == "invalid")
  print("PASS: empty start, team validation, local CRUD, recalculation, persistence, line-ups, cascading deletion, corrupt-file preservation")
 }
}
