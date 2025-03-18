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
                            Text(item)
                            Spacer()
                            Image(systemName: icon(for: item))
                                .foregroundColor(Color(red: 103/255, green: 58/255, blue: 183/255))
                        }
                    }
                }
                .onMove(perform: moveItem)
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            EditButton()
        }
        .onAppear {
            items = watchSessionManager.buttonOrder.components(separatedBy: ",")
        }
    }
    
    // Called when the user reorders items in the list
    func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        let newOrder = items.joined(separator: ",")
        watchSessionManager.buttonOrder = newOrder
    }
    
    private func icon(for item: String) -> String {
        switch item {
        case "Metronome":
            return "music.quarternote.3"
        case "Memo Aid":
            return "waveform"
        default:
            return "questionmark"
        }
    }
    
    @ViewBuilder
    private func destination(for item: String) -> some View {
        switch item {
        case "Metronome":
            MetronomeSettingsView()
        case "Memo Aid":
            MemoAidSettingsView()
        default:
            EmptyView()
        }
    }
}

