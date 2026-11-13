# Offline revision validation

This revision replaces the former synthetic-data product with a personal, fully local football notebook. Historical QA bundles without `offline` in their name describe the superseded implementation.

- Final build: Xcode 27.2, Swift 6, deployment target iOS 17; BUILD SUCCEEDED in output/MatchMatrix-implementation/build.log.
- Domain checks: PASS, including filters, score aggregates, empty samples, full-record selection beyond 999 matches and notebook serialisation.
- Store checks: PASS for empty initial state, duplicate team rejection, record creation/editing, recalculation, line-ups, saved state across reload, cascading deletion and corrupt-file preservation.
- Source scan: no DemoProvider, RemoteProvider, URLSession, URLRequest, HTTP endpoints or synthetic fixtures remain in Sources.
- UI test: PASS, 1 test / 0 failures in QA-offline-v3.xcresult. Creates two teams through forms, enters a 2–0 result, verifies a one-match comparison, bookmarks the record, saves a comparison, restarts and verifies persistence, edits to 2–1, deletes the record and verifies deletion after another restart. Four screenshot attachments exported to screenshots-offline. The first two attempts exposed test-only compiler/selector issues; these were corrected before the successful run.
- Final app and test runner compile successfully in Swift 6. The local-result screenshot was visually inspected.

No network or external service is required. Data stays in Documents/notebook-v2.json. Legacy workspace.json is preserved but not loaded into the new notebook. All product copy remains English (UK). No shipping or production deployment.
