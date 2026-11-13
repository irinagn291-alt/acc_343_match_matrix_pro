# Match Matrix — personal football notebook

A fully local iOS 17+ SwiftUI app in Swift 6. All interface copy is English (UK).

The user owns the data: the app starts empty. Add teams, then enter results or planned fixtures, competition, date, optional line-ups and notes. No bundled matches, network client, accounts, API keys, server or sports-feed integration.

## Screens
- Sport: personal fixtures/results grouped by competition; date filter; add match; team management; selection tray for two-team comparison.
- Match analysis: Overview / Form / Goals / Head-to-head / Line-ups. Edit results, notes and line-ups; delete with confirmation.
- Compare: any two user teams; last 5/10/20 or all records, home/away and competition filtering. Matches, wins, draws, losses, goals scored/conceded, averages and clean sheets. Tap metrics for contributing records.
- Saved: bookmarked matches and saved comparison configurations.
- Workspace: select and reorder three main metrics, starting section preference, team management and last saved time.

## Persistence and integrity
Teams, matches, settings and saved comparisons are atomically stored in Documents/notebook-v2.json. Existing legacy workspace.json is left untouched and its old synthetic bookmarks are not imported. Blank/duplicate team names and identical match opponents are rejected. Team deletion explicitly confirms cascading removal of related matches/bookmarks/comparisons. Match editing recalculates aggregates. Corrupt files are preserved and writes blocked until successful reload. Save errors are surfaced with retry.

## Presentation
Green #087B59 navigation, charcoal #202725 background, #2B3431 panels, #35403B cells, yellow #F4D34F selection. 16pt margins, tabular figures, small radii, labelled statistics, adaptive width. Native accessibility and navigation; custom selection transitions respect Reduce Motion.

## Calculations
Use completed records only, selected competition and venue, descending date then ID. Count wins/draws/losses from team-relative scores; averages divide by actual sample size. Missing/empty samples show —. Upcoming fixtures have no invented score or kick-off time. Head-to-head uses all recorded meetings.

## Validation
Domain tests cover aggregation/filtering/missing values and notebook serialisation. Store tests cover an empty start, creating/editing/deleting records, recalculation, relaunch persistence, cascading deletion, line-ups and corrupt-file preservation. UI automation enters real records through forms and checks persistence and editing. Simulator QA runs through the factory pool and shared compiler slot.
