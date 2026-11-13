# Match Matrix

Open MatchMatrix.xcodeproj and run the MatchMatrix scheme on iPhone or iPad (iOS 17+). Swift 6, no packages or network dependencies. Entire app: English (UK).

Start with **Manage teams**, add two teams, then **Add match**. Enter a result or planned fixture, competition and date. Line-ups and notes are optional. Compare filters calculate statistics from these records; numeric values open their source sample. All records can be edited or deleted; saved matches/configurations persist locally.

Storage: Documents/notebook-v2.json, written atomically. This revision starts a new empty notebook and does not bring in the former synthetic archive. Existing legacy workspace files are preserved on disk.

Tests: Tests/LogicTests.swift (Domain.swift), Tests/StoreTests.swift (Domain.swift + Store.swift), Tests/UITests.swift (Xcode UI runner). Build and QA scripts are in output/MatchMatrix-implementation. Run all simulator work through gf/genesis/simulator_pool.py as required by the root AGENTS.md.

Factory association retained: acc_343 (343), New app cmwf0kygx00pnfdftrf2n6769, bundle com.matchmatrix.analytics. No shipping.
