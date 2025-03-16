import SwiftUI
import Core

@available(macOS 13.0, *)
public struct MoodListView: View {
    @StateObject private var store = MoodStore()
    @State private var showingAddMood = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(store.moods) { mood in
                    HStack {
                        Text(mood.type.emoji)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text(mood.type.rawValue)
                                .font(.headline)
                            if let comment = mood.comment {
                                Text(comment)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text(mood.date, style: .date)
                                .font(.caption)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        store.deleteMood(store.moods[index])
                    }
                }
            }
            .navigationTitle("Мои настроения")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddMood = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMood) {
                AddMoodView(store: store)
            }
        }
    }
} 