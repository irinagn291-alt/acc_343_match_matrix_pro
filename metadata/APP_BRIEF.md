<!-- gf-brief source=fcae204e836f90a84b9b5114a9c3a5a3d3549fc11394c2c88e8717a9eb57ab8b written=2026-11-14T01:47:12+03:00 -->
# Match Matrix

## What it is

Match Matrix is a personal football match notebook for people who follow or play for teams. Users enter their own fixtures and results, then compare teams using statistics calculated from those recorded matches.

## Launch and onboarding

There is no onboarding flow. On a fresh install, the app opens directly to the “Sport” tab and the “MATCH MATRIX” screen:

1. The screen shows “Football”, “MATCH CENTRE”, “MY MATCH NOTEBOOK”, “0 records” and “Every match. More insight.”
2. “Results” is selected, with “Upcoming” available and the “Date” filter set to “All dates”.
3. “Add match” is disabled. “Manage teams” opens “Your teams”.
4. The empty match list says “No matches” and “Add your teams, then record a result or plan a fixture. Your statistics grow with every match.”
5. Under “BUILD A COMPARISON”, the screen says “Select any two teams to inspect their form.”

To begin, open “Manage teams”, enter a “Team name” and tap “Add team”. Add at least two teams to enable “Add match”.

## Screens

### “Sport” — “MATCH MATRIX”

- “Upcoming” and “Results” switch between planned fixtures and completed matches. “Date” filters the selected list by “All dates” or a recorded date.
- “Add match” opens the match editor. “Manage teams” opens “Your teams”.
- Match cards are grouped by competition. Tapping a card opens “Match analysis”; the bookmark control, labelled “Save match” or “Unsave match”, adds or removes it from “Saved”.
- Each card shows three selected metrics for the home team. Tapping a metric opens its calculation and qualifying matches.
- Under “BUILD A COMPARISON”, tapping team names selects or deselects up to two teams. The bottom bar shows the number selected; “Compare” opens “Team comparison” with those teams when exactly two are selected.

### “Compare” — “Team comparison”

With fewer than two teams, the screen says “Choose your teams” and “Add at least two teams to start comparing.” “Manage teams” opens “Your teams”.

With two or more teams:

- “First team” and “Second team” choose different teams.
- “Last 5”, “Last 10”, “Last 20” and “All records” choose the sample size. “Venue” offers “All venues”, “Home” and “Away”; “Competition” offers “All competitions” and recorded competitions.
- The table compares “Matches”, “Wins”, “Draws”, “Losses”, “Goals scored”, “Goals conceded”, “Goals / match”, “Conceded / match” and “Clean sheets”. Tapping either team’s value opens the corresponding calculation screen.
- “Save comparison” saves the teams and filters to “Saved” and changes its label to “Comparison saved”.
- The explanation reads “Tap a value to see every match in its calculation. Each team has its own qualifying sample.”

### Metric calculation

The title is the selected metric, such as “Wins”. The screen shows the team, value, number of completed matches and each result in the sample. It explains: “All matches below form the sample. Wins, draws, losses and clean sheets count qualifying results; per-match values divide goals by the sample size.”

### “Match analysis”

This screen shows the competition, teams, score or “VS”, date, and “Full time” or “Planned fixture”.

- “Save match” bookmarks the match; “Saved match” removes the bookmark.
- “Overview” compares “Matches”, “Wins”, “Draws” and “Losses”.
- “Form” lists each team’s qualifying results.
- “Goals” compares goal totals, per-match rates and clean sheets.
- “Head-to-head” lists completed recorded meetings between the two teams.
- “Line-ups” shows the entered line-ups; “Edit line-ups” opens the match editor.
- “Overview”, “Form” and “Goals” provide the same sample-size, “Venue” and “Competition” filters as the comparison screen. Tapping a comparison value opens its calculation screen.
- Entered notes appear under “MATCH NOTES”. “Edit match” opens the editor. “Delete match” opens a confirmation asking “Delete this match and its saved bookmark?”; confirming “Delete match” removes it and returns to the previous screen.

### “Saved” — “Saved workspace”

Saved comparisons appear under “COMPARISONS”. Tapping one restores its teams and filters in “Team comparison”; “Delete comparison” removes it. Bookmarked match cards appear under “MATCHES” and have the same actions as cards on “Sport”.

### “Workspace”

- “Metric 1”, “Metric 2” and “Metric 3” choose the three match-card metrics. The controls labelled “Move [metric] up” change their order. Choosing an already selected metric swaps its position.
- “Show results first” changes whether “Results” or “Upcoming” is initially selected when the sport screen appears.
- “DATA & AVAILABILITY” shows the notebook record count and “Your teams, results, line-ups and notes stay on this device. Every statistic is calculated from the matches you record.”
- “Manage teams” opens “Your teams”. The screen also shows “Last saved:” with a date and time, and “Match Matrix 1.0 · English (UK)”.

### “Your teams”

“Team name” accepts a name; “Add team” adds it. “Rename” fills the field with an existing name and changes the action to “Save team”; “Cancel editing” abandons that edit.

The control labelled “Delete [team name]” asks “Delete [team name] and all its matches and comparisons?” Confirming “Delete team and matches” removes the team, its matches, their bookmarks and its saved comparisons.

### “Add match” and “Edit match”

- Under “Fixture”, “Home team” and “Away team” select teams, “Date” selects the date and “Competition” accepts a competition name.
- Under “Result”, “Completed” switches between a result and a planned fixture. When enabled, “Home goals: [number]” and “Away goals: [number]” adjust scores from 0 to 99.
- “Home line-up” and “Away line-up” are optional fields under “Line-ups · optional”. “Match notes” is optional under “Notes · optional”.
- “Save result” saves the match and closes the editor. “Cancel” closes it without saving.

### “Match notebook” widget

The small and medium widget is described as “Your recorded results and saved matches.” It shows “Your match notebook”, the number of completed results, and “Your own recorded results”; the medium size also shows saved match and comparison counts. Tapping it opens “Saved workspace”.

## Features

- A personal “MY MATCH NOTEBOOK” for football teams, fixtures and completed results.
- Team management, match editing, optional line-ups and match notes.
- “Upcoming” and “Results” lists with date filters.
- Team comparison and match analysis with sample-size, venue and competition filters.
- Metric calculation screens showing the recorded matches behind each value.
- Saved matches and comparisons.
- Configurable match-card metrics and “Show results first”.
- A “Match notebook” widget.

## Behaviours that can look like bugs

- “Add match” is disabled until at least two teams exist. Use “Manage teams” to add them.
- “Compare” is disabled until exactly two teams are selected. A third team cannot be selected until one of the first two is deselected.
- Blank or duplicate team names cannot be saved. The message says “Enter a unique team name and check that your notebook can be saved.”
- “Save result” stays in the editor if the same team is selected twice or the competition is blank, showing “Choose two different teams and enter a competition.”
- A comparison with no qualifying completed results shows “—”. Its calculation screen says “No qualifying matches” and “Try a wider period, another venue or competition.” Record completed results or broaden the filters.
- “Head-to-head” can say “No meetings recorded yet.” Record a completed match between those teams. A missing line-up says “No line-up recorded.” Use “Edit line-ups” to add one.
- Before anything is saved, “Saved workspace” says “Your research starts here” and “Save a match or a team comparison to return to it later.”
- The first metric’s “Move [metric] up” control is disabled because it is already at the top.
- Saving the same comparison with the same teams and filters again does not add a duplicate, even though the button says “Comparison saved”.
- Changing between “Upcoming” and “Results” resets “Date” to “All dates”.
- If saving fails, a “Workspace” alert offers “Retry saving” and “Dismiss” and says “Could not save your notebook. Keep the app open and retry saving.” If the notebook cannot be read, the app asks the user to relaunch before saving.

## Starter content and resume

There are no sample teams or matches on a normal fresh install. Saved teams, matches, bookmarks, comparisons and workspace preferences are available after reopening the app. An unsaved match editor is not a resumable draft.

## Permissions

None.

## Absent

Login or accounts, in-app purchases, ads, analytics, an account deletion flow and an App Tracking Transparency prompt are absent. User-generated content is present: users enter teams, matches, line-ups and notes.

## Data and support

The app states that teams, results, line-ups and notes stay on this device. Its statistics use the matches the user records. There is no on-screen Contact or Support control.

## Scanning and health

None.

## Platform

The app uses English (UK) and UK-formatted match dates. It supports iPhone and iPad, portrait and both landscape orientations, and requires iOS 17.0 or later.

## Category

Sports.
