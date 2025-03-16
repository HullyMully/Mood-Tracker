import SwiftUI
import MoodTrackerCore

@available(macOS 13.0, *)
struct MainView: View {
    @StateObject private var moodStore = MoodStore()
    @State private var selectedMood: MoodType?
    @State private var comment: String = ""
    @State private var showingAddMood = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        if #available(macOS 13.0, *) {
            NavigationView {
                VStack {
                    Text("Как вы себя чувствуете?")
                        .font(.title)
                        .padding()
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(MoodType.allCases, id: \.self) { mood in
                            Button(action: {
                                selectedMood = mood
                                showingAddMood = true
                            }) {
                                VStack {
                                    Text(mood.emoji)
                                        .font(.system(size: 40))
                                    Text(mood.rawValue)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                            }
                        }
                    }
                    .padding()
                    
                    NavigationLink(destination: MoodHistoryView(moodStore: moodStore)) {
                        Text("История настроений")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    NavigationLink(destination: SettingsView()) {
                        Text("Настройки")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .navigationTitle("MoodTracker")
                .sheet(isPresented: $showingAddMood) {
                    AddMoodView(moodStore: moodStore, selectedMood: selectedMood ?? .neutral)
                }
            }
        }
    }
} 