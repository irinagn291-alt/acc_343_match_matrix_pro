import SwiftUI

enum Palette {
    static let green = Color(red: 8/255, green: 123/255, blue: 89/255)
    static let background = Color(red: 32/255, green: 39/255, blue: 37/255)
    static let panel = Color(red: 43/255, green: 52/255, blue: 49/255)
    static let cell = Color(red: 53/255, green: 64/255, blue: 59/255)
    static let yellow = Color(red: 244/255, green: 211/255, blue: 79/255)
    static let muted = Color(red: 165/255, green: 179/255, blue: 172/255)
}
#if DEBUG && targetEnvironment(simulator)
// The factory supplies either a named review route or a zero-based screenshot index.
enum ScreenshotRoute: String, CaseIterable {
    case sportResults = "sport-results", teamComparison = "team-comparison"
    case matchAnalysis = "match-analysis", metricEvidence = "metric-evidence"
    case savedWorkspace = "saved-workspace", matchEditor = "match-editor", teams

    static var current: ScreenshotRoute? {
        let process = ProcessInfo.processInfo
        let args = process.arguments
        func value(after flag: String) -> String? {
            guard let index = args.firstIndex(of: flag), args.indices.contains(index + 1) else { return nil }
            return args[index + 1]
        }
        if let key = value(after: "-ReviewScreen") { return ScreenshotRoute(rawValue: key) }
        let environmentFlag = process.environment["APPSTORE_SCREENSHOTS"]?.lowercased()
        let enabled = args.contains("-AppStoreScreenshots") || ["1", "true", "yes"].contains(environmentFlag ?? "")
        guard enabled else { return nil }
        let rawIndex = value(after: "-AppStoreScreenshotScreen") ?? process.environment["APPSTORE_SCREENSHOT_SCREEN"] ?? "0"
        guard let index = Int(rawIndex), allCases.indices.contains(index) else { return nil }
        return allCases[index]
    }
}

enum ScreenshotDestination: Hashable { case matchAnalysis, metricEvidence, teams }
#endif

@main struct MatchMatrixApp: App {
    #if DEBUG && targetEnvironment(simulator)
    @State private var store: Store = {
        if let route = ScreenshotRoute.current { return Store(screenshot: route) }
        return Store()
    }()
    #else
    @State private var store = Store()
    #endif
    var body: some Scene { WindowGroup { RootView().environment(store).environment(\.locale, Locale(identifier: "en_GB")).preferredColorScheme(.dark).tint(Palette.yellow) } }
}
struct RootView: View {
    @Environment(Store.self) private var store
    #if DEBUG && targetEnvironment(simulator)
    @State private var sportPath: [ScreenshotDestination] = {
        switch ScreenshotRoute.current {
        case .matchAnalysis: return [.matchAnalysis]
        case .teams: return [.teams]
        default: return []
        }
    }()
    @State private var comparePath: [ScreenshotDestination] = ScreenshotRoute.current == .metricEvidence ? [.metricEvidence] : []
    #endif
    var body: some View {
        @Bindable var store = store
        TabView(selection: $store.tab) {
            sportNavigation.tabItem { Label("Sport", systemImage: "sportscourt") }.tag(0)
            compareNavigation.tabItem { Label("Compare", systemImage: "chart.bar.xaxis") }.tag(1)
            NavigationStack { SavedView() }.tabItem { Label("Saved", systemImage: "bookmark") }.tag(2)
            NavigationStack { SettingsView() }.tabItem { Label("Workspace", systemImage: "slider.horizontal.3") }.tag(3)
        }
            #if DEBUG && targetEnvironment(simulator)
            .transaction { transaction in
                if ScreenshotRoute.current != nil { transaction.animation = nil; transaction.disablesAnimations = true }
            }
            .task {
                if let route = ScreenshotRoute.current {
                    await Task.yield()
                    store.tab = [.teamComparison, .metricEvidence].contains(route) ? 1 : route == .savedWorkspace ? 2 : 0
                }
            }
            #endif
            .onOpenURL { url in
                if WidgetIdentity.accepts(url) {
                #if DEBUG && targetEnvironment(simulator)
                store.applyWidgetQA(url)
                #endif
                    store.tab = 2
                }
            }
            .alert("Workspace", isPresented: Binding(get: { store.storageError != nil }, set: { if !$0 { store.storageError = nil } })) { Button("Retry saving") { store.persist() }; Button("Dismiss", role: .cancel) {} } message: { Text(store.storageError ?? "") }
    }
    @ViewBuilder private var sportNavigation: some View {
        #if DEBUG && targetEnvironment(simulator)
        if ScreenshotRoute.current != nil {
            NavigationStack(path: $sportPath) {
                SportView().navigationDestination(for: ScreenshotDestination.self) { destination in
                    switch destination {
                    case .matchAnalysis:
                        if let match = store.matches.first(where: { $0.id == 0 }) { DetailView(match: match) }
                    case .teams: TeamsView()
                    case .metricEvidence: EvidenceView(summary: store.summary(store.first), metric: .wins)
                    }
                }
            }
        } else { NavigationStack { SportView() } }
        #else
        NavigationStack { SportView() }
        #endif
    }
    @ViewBuilder private var compareNavigation: some View {
        #if DEBUG && targetEnvironment(simulator)
        if ScreenshotRoute.current != nil {
            NavigationStack(path: $comparePath) {
                CompareView().navigationDestination(for: ScreenshotDestination.self) { destination in
                    switch destination {
                    case .metricEvidence: EvidenceView(summary: store.summary(store.first), metric: .wins)
                    case .matchAnalysis:
                        if let match = store.matches.first(where: { $0.id == 0 }) { DetailView(match: match) }
                    case .teams: TeamsView()
                    }
                }
            }
        } else { NavigationStack { CompareView() } }
        #else
        NavigationStack { CompareView() }
        #endif
    }
}
struct Canvas<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 16) { content }.padding(16).frame(maxWidth: 900).frame(maxWidth: .infinity) }.background(Palette.background).navigationTitle(title).navigationBarTitleDisplayMode(.inline).toolbarBackground(Palette.green, for: .navigationBar).toolbarBackground(.visible, for: .navigationBar) }
}
struct SourceNote: View {
    @Environment(Store.self) private var store
    var body: some View { HStack { Label("MY MATCH NOTEBOOK", systemImage: "book.closed").font(.caption.bold()).foregroundStyle(Palette.yellow); Spacer(); Text("\(store.matches.count) records").font(.caption).foregroundStyle(Palette.muted) }.accessibilityElement(children: .combine) }
}
struct SectionTitle: View { let text: String; var body: some View { Text(text.uppercased()).font(.caption.bold()).tracking(1.5).foregroundStyle(Palette.muted).padding(.top, 8) } }
struct SportView: View {
    @Environment(Store.self) private var store
    @State private var segment = "Results"
    #if DEBUG && targetEnvironment(simulator)
    @State private var adding = ScreenshotRoute.current == .matchEditor
    #else
    @State private var adding = false
    #endif
    @State private var initialised = false
    @State private var date = "All dates"
    var rows: [Match] { store.matches.filter { (segment == "Results" ? $0.played : !$0.played) && (date == "All dates" || $0.dateLabel == date) }.sorted { segment == "Results" ? $0.day > $1.day : $0.day < $1.day } }
    var body: some View {
        Canvas(title: "MATCH MATRIX") {
            HStack { Label("Football", systemImage: "soccerball").font(.headline); Spacer(); Text("MATCH CENTRE").font(.caption.bold()).foregroundStyle(Palette.yellow) }.padding(16).background(Palette.green, in: RoundedRectangle(cornerRadius: 6))
            SourceNote()
            HStack(alignment: .firstTextBaseline) { Text("Every match. More insight.").font(.system(size: 22, weight: .bold)); Spacer(); Image(systemName: "square.grid.3x3.fill").font(.system(size: 36)).foregroundStyle(Palette.yellow).accessibilityHidden(true) }
            ChipPicker(selection: $segment, choices: ["Upcoming", "Results"], label: { $0 }).onChange(of: segment) { date = "All dates" }
            Picker("Date", selection: $date) { Text("All dates").tag("All dates"); ForEach(Array(Set(store.matches.filter { segment == "Results" ? $0.played : !$0.played }.map(\.dateLabel))).sorted(), id: \.self) { Text($0).tag($0) } }.accessibilityIdentifier("dateFilter")
            HStack { Button { adding = true } label: { Label("Add match", systemImage: "plus.circle.fill") }.disabled(store.teams.count < 2); Spacer(); NavigationLink("Manage teams") { TeamsView() } }.frame(minHeight: 44)
            ForEach(store.competitions, id: \.self) { league in
                let matches = rows.filter { $0.league == league }
                if !matches.isEmpty { SectionTitle(text: league); ForEach(matches) { MatchCard(match: $0) } }
            }
            if rows.isEmpty { ContentUnavailableView("No matches", systemImage: "calendar", description: Text("Add your teams, then record a result or plan a fixture. Your statistics grow with every match.")) }
            SectionTitle(text: "Build a comparison")
            Text("Select any two teams to inspect their form.").font(.subheadline).foregroundStyle(Palette.muted)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 8) { ForEach(store.teams) { team in
                Button { store.select(team.id) } label: { HStack { Text(team.name); Spacer(); Image(systemName: store.selected.contains(team.id) ? "checkmark.circle.fill" : "plus.circle") }.font(.subheadline.bold()).frame(minHeight: 44).padding(.horizontal, 12).background(store.selected.contains(team.id) ? Palette.yellow : Palette.cell, in: RoundedRectangle(cornerRadius: 5)).foregroundStyle(store.selected.contains(team.id) ? Palette.background : .white) }.accessibilityIdentifier("team-\(team.id)")
            } }
        }.safeAreaInset(edge: .bottom) {
            if !store.selected.isEmpty { HStack { VStack(alignment: .leading) { Text("\(store.selected.count) teams selected").bold(); Text(store.selected.map { store.team($0).short }.joined(separator: " / ")).font(.caption) }; Spacer(); Button("Compare") { store.first = store.selected[0]; store.second = store.selected[1]; store.tab = 1 }.buttonStyle(.borderedProminent).foregroundStyle(Palette.background).buttonBorderShape(.roundedRectangle(radius: 6)).disabled(store.selected.count != 2) }.padding(16).background(Palette.panel) }
        }.sheet(isPresented: $adding) { MatchEditor() }.onAppear { if !initialised { segment = store.workspace.resultsFirst ? "Results" : "Upcoming"; initialised = true } }
    }
}
struct MatchCard: View {
    @Environment(Store.self) private var store
    let match: Match
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                NavigationLink { DetailView(match: match) } label: {
                    HStack { VStack(alignment: .leading, spacing: 8) { Text(store.team(match.home).name); Text(store.team(match.away).name) }.font(.system(size: 16, weight: .semibold)); Spacer(); VStack(spacing: 6) { Text(match.played ? "\(match.homeGoals!) – \(match.awayGoals!)" : "Planned").font(.title3.bold()).monospacedDigit(); Text(match.played ? "FT · \(match.dateLabel)" : match.dateLabel).font(.caption).foregroundStyle(Palette.muted) }; Image(systemName: "chevron.right").font(.caption) }.contentShape(Rectangle())
                }.buttonStyle(.plain).accessibilityIdentifier("match-\(match.id)")
                Button { store.toggleSave(match.id) } label: { Image(systemName: store.workspace.savedMatches.contains(match.id) ? "bookmark.fill" : "bookmark").frame(width: 44, height: 44) }.accessibilityLabel(store.workspace.savedMatches.contains(match.id) ? "Unsave match" : "Save match")
            }.padding(12)
            HStack(spacing: 1) { ForEach(store.workspace.metrics, id: \.self) { metric in
                let summary = store.summary(match.home)
                NavigationLink { EvidenceView(summary: summary, metric: metric) } label: { VStack(spacing: 6) { Text(metric.rawValue).font(.system(size: 12)).foregroundStyle(Palette.muted); Text(summary.value(metric)).font(.system(size: 20, weight: .bold)).monospacedDigit() }.frame(maxWidth: .infinity, minHeight: 64).background(Palette.cell) }.buttonStyle(.plain)
            } }
            Text("\(store.team(match.home).short) · \(store.summary(match.home).count) matches · \(store.filter.venue.rawValue)").font(.caption2).foregroundStyle(Palette.muted).frame(maxWidth: .infinity, alignment: .leading).padding(8)
        }.background(Palette.panel, in: RoundedRectangle(cornerRadius: 6)).clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
struct FiltersView: View {
    @Environment(Store.self) private var store
    var body: some View {
        @Bindable var store = store
        VStack(spacing: 8) {
            ChipPicker(selection: $store.filter.limit, choices: [5, 10, 20, 999], label: { $0 == 999 ? "All records" : "Last \($0)" })
            HStack { Picker("Venue", selection: $store.filter.venue) { ForEach(Venue.allCases, id: \.self) { Text($0.rawValue).tag($0) } }; Spacer(); Picker("Competition", selection: $store.filter.league) { ForEach(["All competitions"] + store.competitions, id: \.self) { Text($0).tag($0) } } }.font(.subheadline)
        }
    }
}
struct CompareView: View {
    @Environment(Store.self) private var store
    @State private var saved = false
    var body: some View {
        @Bindable var store = store
        Canvas(title: "Team comparison") {
            SourceNote()
            if store.teams.count < 2 { ContentUnavailableView("Choose your teams", systemImage: "person.2", description: Text("Add at least two teams to start comparing.")); NavigationLink("Manage teams") { TeamsView() } } else {
            HStack { teamPicker("First team", selection: $store.first, excluding: store.second); Text("VS").font(.caption.bold()).foregroundStyle(Palette.yellow); teamPicker("Second team", selection: $store.second, excluding: store.first) }.padding(8).background(Palette.panel)
            FiltersView()
            ComparisonTable(first: store.summary(store.first), second: store.summary(store.second), metrics: Metric.allCases)
            Button { store.saveComparison(); saved = true } label: { Label(saved ? "Comparison saved" : "Save comparison", systemImage: saved ? "checkmark" : "bookmark").frame(maxWidth: .infinity, minHeight: 44) }.buttonStyle(.borderedProminent).foregroundStyle(Palette.background).buttonBorderShape(.roundedRectangle(radius: 6)).onChange(of: store.filter) { saved = false }.onChange(of: store.first) { saved = false }.onChange(of: store.second) { saved = false }
            Text("Tap a value to see every match in its calculation. Each team has its own qualifying sample.").font(.caption).foregroundStyle(Palette.muted)
            }
        }
    }
    func teamPicker(_ title: String, selection: Binding<Int>, excluding: Int) -> some View { Picker(title, selection: selection) { ForEach(store.teams.filter { $0.id != excluding }) { Text($0.name).tag($0.id) } }.frame(maxWidth: .infinity) }
}
struct ComparisonTable: View {
    @Environment(Store.self) private var store
    let first: Summary
    let second: Summary
    let metrics: [Metric]
    var body: some View {
        VStack(spacing: 1) {
            HStack { Text(store.team(first.team).short); Spacer(); Text("\(first.count) / \(second.count) matches").foregroundStyle(Palette.muted); Spacer(); Text(store.team(second.team).short) }.font(.caption.bold()).padding(12)
            ForEach(metrics) { metric in
                HStack {
                    NavigationLink { EvidenceView(summary: first, metric: metric) } label: { Text(first.value(metric)).frame(width: 64, height: 48).background(Palette.cell) }
                    VStack(spacing: 6) { Text(metric.rawValue).font(.subheadline); GeometryReader { geo in let a = Double(first.value(metric)) ?? 0; let b = Double(second.value(metric)) ?? 0; HStack(spacing: 3) { Rectangle().fill(Palette.yellow).frame(width: max(0, (geo.size.width - 3) * (a + b > 0 ? a / (a + b) : 0.5))); Rectangle().fill(Palette.green) } }.frame(height: 4).accessibilityHidden(true) }.frame(maxWidth: .infinity)
                    NavigationLink { EvidenceView(summary: second, metric: metric) } label: { Text(second.value(metric)).frame(width: 64, height: 48).background(Palette.cell) }
                }.font(.title3.bold()).monospacedDigit().padding(.horizontal, 8).padding(.vertical, 4).background(Palette.panel)
            }
        }
    }
}
struct EvidenceView: View {
    @Environment(Store.self) private var store
    let summary: Summary
    let metric: Metric
    var body: some View { Canvas(title: metric.rawValue) {
        Text(store.team(summary.team).name).font(.title2.bold())
        HStack(alignment: .firstTextBaseline) { Text(summary.value(metric)).font(.system(size: 40, weight: .bold)).monospacedDigit().foregroundStyle(Palette.yellow); Text("from \(summary.count) completed matches").font(.subheadline) }
        Text("All matches below form the sample. Wins, draws, losses and clean sheets count qualifying results; per-match values divide goals by the sample size.").font(.subheadline).foregroundStyle(Palette.muted)
        SourceNote()
        if summary.matches.isEmpty { ContentUnavailableView("No qualifying matches", systemImage: "line.3.horizontal.decrease.circle", description: Text("Try a wider period, another venue or competition.")) }
        ForEach(summary.matches) { m in ResultRow(match: m) }
    } }
}
struct ResultRow: View {
    @Environment(Store.self) private var store
    let match: Match
    var body: some View { VStack(alignment: .leading, spacing: 8) { HStack { Text("\(store.team(match.home).name) – \(store.team(match.away).name)"); Spacer(); Text(match.played ? "\(match.homeGoals!) : \(match.awayGoals!)" : "—").bold().monospacedDigit() }; Text("\(match.dateLabel) · \(match.league)").font(.caption).foregroundStyle(Palette.muted) }.font(.subheadline).padding(12).background(Palette.panel, in: RoundedRectangle(cornerRadius: 5)) }
}
struct DetailView: View {
    @Environment(Store.self) private var store
    let match: Match
    @Environment(\.dismiss) private var dismiss
    @State private var editing = false
    @State private var deleting = false
    private var current: Match { store.matches.first { $0.id == match.id } ?? match }
    @State private var section = "Overview"
    var body: some View { Canvas(title: "Match analysis") {
        Text(current.league.uppercased()).font(.caption.bold()).foregroundStyle(Palette.yellow)
        HStack { Text(store.team(current.home).name); Spacer(); Text(current.played ? "\(current.homeGoals!) : \(current.awayGoals!)" : "VS").font(.system(size: 32, weight: .bold)).monospacedDigit(); Spacer(); Text(store.team(current.away).name) }.font(.headline)
        Text("\(current.dateLabel) · \(current.played ? "Full time" : "Planned fixture")").foregroundStyle(Palette.muted).font(.caption)
        Button { store.toggleSave(current.id) } label: { Label(store.workspace.savedMatches.contains(current.id) ? "Saved match" : "Save match", systemImage: "bookmark").frame(minHeight: 44) }
        ScrollView(.horizontal, showsIndicators: false) { HStack { ForEach(["Overview", "Form", "Goals", "Head-to-head", "Line-ups"], id: \.self) { name in Button { section = name } label: { Text(name).font(.subheadline.bold()).padding(.horizontal, 14).frame(height: 44).background(section == name ? Palette.yellow : Palette.cell, in: RoundedRectangle(cornerRadius: 5)).foregroundStyle(section == name ? Palette.background : .white) } } } }
        SourceNote()
        if section == "Line-ups" {
            SectionTitle(text: store.team(current.home).name)
            Text(current.homeLineup.isEmpty ? "No line-up recorded." : current.homeLineup)
            SectionTitle(text: store.team(current.away).name)
            Text(current.awayLineup.isEmpty ? "No line-up recorded." : current.awayLineup)
            Button("Edit line-ups") { editing = true }.frame(minHeight: 44)
        }
        else if section == "Head-to-head" {
            let rows = store.matches.filter { $0.played && Set([$0.home, $0.away]) == Set([current.home, current.away]) }.sorted { $0.day > $1.day }
            Text("\(rows.count) recorded meetings").font(.headline)
            ForEach(rows) { ResultRow(match: $0) }
            if rows.isEmpty { Text("No meetings recorded yet.") }
        } else {
            FiltersView()
            if section == "Form" { ForEach([current.home, current.away], id: \.self) { team in SectionTitle(text: store.team(team).name); ForEach(store.summary(team).matches) { ResultRow(match: $0) } } }
            else { ComparisonTable(first: store.summary(current.home), second: store.summary(current.away), metrics: section == "Goals" ? [.scored, .conceded, .goalsRate, .againstRate, .clean] : [.matches, .wins, .draws, .losses]) }
        }
        if !current.notes.isEmpty { SectionTitle(text: "Match notes"); Text(current.notes) }
        HStack { Button("Edit match") { editing = true }; Spacer(); Button("Delete match", role: .destructive) { deleting = true } }.frame(minHeight: 44)
    }.sheet(isPresented: $editing) { MatchEditor(existing: current) }
     .confirmationDialog("Delete this match and its saved bookmark?", isPresented: $deleting, titleVisibility: .visible) { Button("Delete match", role: .destructive) { store.deleteMatch(current.id); dismiss() } }
    }
}
struct SavedView: View {
    @Environment(Store.self) private var store
    var body: some View { Canvas(title: "Saved workspace") {
        if store.workspace.savedMatches.isEmpty && store.workspace.comparisons.isEmpty { ContentUnavailableView("Your research starts here", systemImage: "bookmark", description: Text("Save a match or a team comparison to return to it later.")) }
        SectionTitle(text: "Comparisons")
        ForEach(store.workspace.comparisons) { item in HStack { Button { store.first = item.first; store.second = item.second; store.filter = item.filter; store.tab = 1 } label: { VStack(alignment: .leading, spacing: 8) { Text("\(store.team(item.first).name) / \(store.team(item.second).name)").bold(); Text("\(item.filter.limit == 999 ? "All records" : "Last \(item.filter.limit)") · \(item.filter.venue.rawValue)\n\(item.filter.league)").font(.caption).foregroundStyle(Palette.muted) }.frame(maxWidth: .infinity, alignment: .leading) }; Button(role: .destructive) { store.workspace.comparisons.removeAll { $0.id == item.id }; store.persist() } label: { Image(systemName: "trash").frame(width: 44, height: 44) }.accessibilityLabel("Delete comparison") }.padding(12).background(Palette.panel) }
        SectionTitle(text: "Matches")
        ForEach(store.matches.filter { store.workspace.savedMatches.contains($0.id) }) { MatchCard(match: $0) }
    } }
}
struct SettingsView: View {
    @Environment(Store.self) private var store
    var body: some View {
        @Bindable var store = store
        Canvas(title: "Workspace") {
            Text("Make room for your metrics.").font(.title.bold())
            Text("Choose three match-card metrics. Use the arrows to change their order.").foregroundStyle(Palette.muted)
            ForEach(Array(store.workspace.metrics.enumerated()), id: \.offset) { index, metric in
                HStack { Text("\(index + 1)").foregroundStyle(Palette.yellow); Picker("Metric \(index + 1)", selection: Binding(get: { store.workspace.metrics[index] }, set: { new in if let other = store.workspace.metrics.firstIndex(of: new) { store.workspace.metrics.swapAt(index, other) } else { store.workspace.metrics[index] = new }; store.persist() })) { ForEach(Metric.allCases) { Text($0.rawValue).tag($0) } }; Spacer(); Button { store.workspace.metrics.swapAt(index, index - 1); store.persist() } label: { Image(systemName: "arrow.up").frame(width: 44, height: 44) }.disabled(index == 0).accessibilityLabel("Move \(metric.rawValue) up") }.padding(8).background(Palette.panel)
            }
            Toggle("Show results first", isOn: $store.workspace.resultsFirst).onChange(of: store.workspace.resultsFirst) { store.persist() }.padding(12).background(Palette.panel)
            SectionTitle(text: "Data & availability")
            SourceNote()
            Text("Your teams, results, line-ups and notes stay on this device. Every statistic is calculated from the matches you record.").font(.subheadline).foregroundStyle(Palette.muted)
            NavigationLink("Manage teams") { TeamsView() }.frame(minHeight: 44)
            Text("Last saved: \(store.updated.formatted(date: .abbreviated, time: .shortened))").font(.caption).foregroundStyle(Palette.muted)
            Text("Match Matrix 1.0 · English (UK)").font(.caption).foregroundStyle(Palette.muted)
        }
    }
}

struct ChipPicker<Value: Hashable>: View {
    @Binding var selection: Value
    let choices: [Value]
    let label: (Value) -> String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        HStack(spacing: 4) {
            ForEach(choices, id: \.self) { choice in
                Button { selection = choice } label: {
                    Text(label(choice)).font(.subheadline.bold()).frame(maxWidth: .infinity, minHeight: 44)
                        .background(selection == choice ? Palette.yellow : Palette.cell, in: RoundedRectangle(cornerRadius: 5))
                        .foregroundStyle(selection == choice ? Palette.background : .white)
                }.accessibilityAddTraits(selection == choice ? .isSelected : [])
            }
        }.animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: selection)
    }
}

struct TeamsView: View {
    @Environment(Store.self) private var store
    @State private var name = ""
    @State private var editing: Int?
    @State private var deleting: Team?
    @State private var invalid = false
    var body: some View {
        Canvas(title: "Your teams") {
            Text("Add the teams you follow or play for.").foregroundStyle(Palette.muted)
            TextField("Team name", text: $name).textFieldStyle(.roundedBorder).accessibilityIdentifier("teamName")
            Button(editing == nil ? "Add team" : "Save team") {
                if store.saveTeam(name: name, editing: editing) { name = ""; editing = nil; invalid = false } else { invalid = true }
            }.buttonStyle(.borderedProminent).foregroundStyle(Palette.background).frame(minHeight: 44)
            if editing != nil { Button("Cancel editing") { editing = nil; name = "" } }
            if invalid { Text("Enter a unique team name and check that your notebook can be saved.").foregroundStyle(Palette.yellow) }
            if store.teams.isEmpty { ContentUnavailableView("Your first team", systemImage: "person.2", description: Text("Add two teams to record your first match.")) }
            ForEach(store.teams) { team in
                HStack { Text(team.name).bold(); Spacer(); Button("Rename") { editing = team.id; name = team.name }.frame(minHeight: 44); Button(role: .destructive) { deleting = team } label: { Image(systemName: "trash").frame(width: 44, height: 44) }.accessibilityLabel("Delete \(team.name)") }.padding(12).background(Palette.panel)
            }
        }.confirmationDialog("Delete \(deleting?.name ?? "team") and all its matches and comparisons?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }), titleVisibility: .visible) {
            Button("Delete team and matches", role: .destructive) { if let team = deleting { store.deleteTeam(team.id) }; deleting = nil }
        }
    }
}
struct MatchEditor: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss
    var existing: Match?
    @State private var home = -1
    @State private var away = -1
    @State private var date = Date()
    @State private var competition = ""
    @State private var completed = true
    @State private var homeGoals = 0
    @State private var awayGoals = 0
    @State private var homeLineup = ""
    @State private var awayLineup = ""
    @State private var notes = ""
    @State private var invalid = false
    var body: some View {
        NavigationStack {
            Form {
                Section("Fixture") {
                    Picker("Home team", selection: $home) { ForEach(store.teams) { Text($0.name).tag($0.id) } }
                    Picker("Away team", selection: $away) { ForEach(store.teams) { Text($0.name).tag($0.id) } }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Competition", text: $competition).accessibilityIdentifier("competition")
                }
                Section("Result") {
                    Toggle("Completed", isOn: $completed)
                    if completed {
                        Stepper("Home goals: \(homeGoals)", value: $homeGoals, in: 0...99).accessibilityIdentifier("homeGoals")
                        Stepper("Away goals: \(awayGoals)", value: $awayGoals, in: 0...99).accessibilityIdentifier("awayGoals")
                    }
                }
                Section("Line-ups · optional") {
                    TextField("Home line-up", text: $homeLineup, axis: .vertical).lineLimit(3...8)
                    TextField("Away line-up", text: $awayLineup, axis: .vertical).lineLimit(3...8)
                }
                Section("Notes · optional") { TextField("Match notes", text: $notes, axis: .vertical).lineLimit(3...8) }
                if invalid { Text("Choose two different teams and enter a competition.").foregroundStyle(Palette.yellow) }
                if let error = store.storageError { Text(error).foregroundStyle(Palette.yellow) }
            }.scrollContentBackground(.hidden).background(Palette.background).navigationTitle(existing == nil ? "Add match" : "Edit match").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button("Save result") { save() }.accessibilityIdentifier("saveResult") }
                }
                .onAppear {
                    home = existing?.home ?? store.teams.first?.id ?? -1
                    away = existing?.away ?? store.teams.first { $0.id != home }?.id ?? -1
                    #if DEBUG && targetEnvironment(simulator)
                    if existing == nil && ScreenshotRoute.current == .matchEditor {
                        home = 0; away = 1; competition = "Sunday League"
                        completed = true; homeGoals = 2; awayGoals = 0
                    }
                    #endif
                    if let m = existing {
                        var utc = Calendar(identifier: .gregorian); utc.timeZone = TimeZone(secondsFromGMT: 0)!
                        let stored = utc.date(byAdding: .day, value: m.day, to: Date(timeIntervalSince1970: 1788220800))!
                        date = Calendar.current.date(from: utc.dateComponents([.year, .month, .day], from: stored))!
                        competition = m.league; completed = m.played; homeGoals = m.homeGoals ?? 0; awayGoals = m.awayGoals ?? 0
                        homeLineup = m.homeLineup; awayLineup = m.awayLineup; notes = m.notes
                    }
                }
        }
    }
    private func save() {
        guard home != away, home >= 0, away >= 0, !competition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { invalid = true; return }
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let normalised = calendar.date(from: components)!
        let day = calendar.dateComponents([.day], from: Date(timeIntervalSince1970: 1788220800), to: normalised).day!
        let match = Match(id: existing?.id ?? ((store.matches.map(\.id).max() ?? -1) + 1), day: day, home: home, away: away, homeGoals: completed ? homeGoals : nil, awayGoals: completed ? awayGoals : nil, league: competition.trimmingCharacters(in: .whitespacesAndNewlines), homeLineup: homeLineup, awayLineup: awayLineup, notes: notes)
        if store.saveMatch(match) { dismiss() }
    }
}
