import SwiftUI
import Core

@available(macOS 13.0, *)
public struct AddMoodView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: MoodStore
    @State private var selectedType: MoodType = .happy
    @State private var comment: String = ""
    
    public init(store: MoodStore) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Тип настроения")) {
                    Picker("Тип", selection: $selectedType) {
                        ForEach(MoodType.allCases, id: \.self) { type in
                            HStack {
                                Text(type.emoji)
                                Text(type.rawValue)
                            }.tag(type)
                        }
                    }
                }
                
                Section(header: Text("Комментарий")) {
                    TextEditor(text: $comment)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Добавить настроение")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let mood = Mood(type: selectedType, comment: comment)
                        store.addMood(mood)
                        dismiss()
                    }
                }
            }
        }
    }
} 