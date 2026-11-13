import XCTest
import WidgetKit
@testable import MatchMatrix

final class WidgetTests: XCTestCase {
    private var temporaryFolders: [URL] = []
    override func tearDownWithError() throws { for url in temporaryFolders { try? FileManager.default.removeItem(at:url) } }
    func temporaryURL() -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        temporaryFolders.append(directory)
        return directory.appendingPathComponent("state.json")
    }
    func testAtomicStorageDeduplicationAndCorruptFallback() throws {
        let url = temporaryURL(), date = Date(timeIntervalSince1970:100)
        var snapshot = WidgetSnapshot.empty; snapshot.updatedAt = date
        XCTAssertTrue(try WidgetStore.write(snapshot,to:url))
        snapshot.updatedAt = date.addingTimeInterval(500)
        XCTAssertFalse(try WidgetStore.write(snapshot,to:url))
        XCTAssertEqual(WidgetStore.read(from:url)?.updatedAt,date)
        snapshot.value = "3";snapshot.isEmpty = false
        XCTAssertTrue(try WidgetStore.write(snapshot,to:url))
        XCTAssertEqual(ProgressProvider().entry(from:url).snapshot.value,"3")
        try Data("broken".utf8).write(to:url)
        XCTAssertTrue(ProgressProvider().entry(from:url).snapshot.isEmpty)
        snapshot.progress = .nan
        XCTAssertThrowsError(try WidgetStore.write(snapshot,to:url))
    }
    func testOnlyTheWidgetDestinationIsAccepted() {
        XCTAssertTrue(WidgetIdentity.accepts(WidgetIdentity.url))
        XCTAssertFalse(WidgetIdentity.accepts(URL(string:"https://widget/"+WidgetIdentity.route)!))
        XCTAssertFalse(WidgetIdentity.accepts(URL(string:WidgetIdentity.scheme+"://other/"+WidgetIdentity.route)!))
        XCTAssertFalse(WidgetIdentity.accepts(URL(string:WidgetIdentity.scheme+"://widget/delete")!))
    }
    @MainActor func testSnapshotFollowsSavedAppProgress() throws {
        let store = Store(url:temporaryURL())
        XCTAssertEqual(store.widgetSnapshot.value, "0")
        _ = store.saveTeam(name:"Alpha"); _ = store.saveTeam(name:"Beta")
        _ = store.saveMatch(Match(id:1,day:61,home:0,away:1,homeGoals:2,awayGoals:1,league:"Test"))
        store.toggleSave(1)
        XCTAssertEqual(store.widgetSnapshot.value, "1")
        XCTAssertTrue(store.widgetSnapshot.detail.contains("1 saved"))
        store.deleteMatch(1)
        XCTAssertEqual(store.widgetSnapshot.value,"0")
        XCTAssertTrue(store.widgetSnapshot.isValid)
    }
}
