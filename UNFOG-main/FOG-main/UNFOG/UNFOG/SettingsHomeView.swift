import SwiftUI

struct SettingsHomeView: View {
    @ObservedObject private var watchSessionManager = WatchSessionManager.shared
    @State private var items: [String] = []
    
    var body: some View {
        List {
            Section {
                ForEach(items, id: \.self) { item in
                    NavigationLink(destination: destination(for: item)) {
                        HStack {
                            Text(LocalizedStringKey(item))
                            Spacer()
                            Image(systemName: icon(for: item))
                                .foregroundColor(Color(red: 103/255, green: 58/255, blue: 183/255))
                        }
                    }
                }
                .onMove(perform: moveItem)
            }
        }
        .navigationTitle(LocalizedStringKey("settings"))
        .toolbar {
            EditButton()
        }
        .onAppear {
            updateItems()
        }
        .onChange(of: watchSessionManager.buttonOrder) { _ in
            updateItems()
        }
    }
    
    private func updateItems() {
        items = watchSessionManager.buttonOrder
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        let newOrder = items.joined(separator: ",")
        watchSessionManager.buttonOrder = newOrder
    }
    
    private func icon(for item: String) -> String {
        switch item {
        case "metronome_settings":
            return "music.quarternote.3"
        case "memoaid_settings":
            return "waveform"
        default:
            return "questionmark"
        }
    }
    
    @ViewBuilder
    private func destination(for item: String) -> some View {
        switch item {
        case "metronome_settings":
            MetronomeSettingsView()
        case "memoaid_settings":
            MemoAidSettingsView()
        default:
            EmptyView()
        }
    }
}
