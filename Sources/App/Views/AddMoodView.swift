import SwiftUI
import MoodTrackerCore

@available(macOS 13.0, *)
struct AddMoodView: View {
    @ObservedObject var moodStore: MoodStore
    let selectedMood: MoodType
    @State private var comment: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        if #available(macOS 13.0, *) {
            NavigationView {
                Form {
                    Section(header: Text("Настроение")) {
                        HStack {
                            Text(selectedMood.emoji)
                                .font(.system(size: 40))
                            Text(selectedMood.rawValue)
                                .font(.headline)
                        }
                    }
                    
                    Section(header: Text("Комментарий")) {
                        TextEditor(text: $comment)
                            .frame(height: 100)
                    }
                    
                    Section {
                        Button(action: saveMood) {
                            Text("Сохранить")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.blue)
                    }
                }
                .navigationTitle("Добавить настроение")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Отмена") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func saveMood() {
        let newMood = Mood(type: selectedMood, comment: comment.isEmpty ? nil : comment)
        moodStore.addMood(newMood)
        presentationMode.wrappedValue.dismiss()
    }
} 