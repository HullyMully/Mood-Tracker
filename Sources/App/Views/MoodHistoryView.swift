import SwiftUI
import Charts
import MoodTrackerCore

@available(macOS 13.0, *)
struct MoodHistoryView: View {
    @ObservedObject var moodStore: MoodStore
    @State private var timeRange: TimeRange = .week
    
    enum TimeRange {
        case day, week, month
        
        var title: String {
            switch self {
            case .day: return "День"
            case .week: return "Неделя"
            case .month: return "Месяц"
            }
        }
    }
    
    var filteredMoods: [Mood] {
        let calendar = Calendar.current
        let now = Date()
        
        return moodStore.moods.filter { mood in
            switch timeRange {
            case .day:
                return calendar.isDate(mood.date, inSameDayAs: now)
            case .week:
                let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
                return mood.date >= weekAgo
            case .month:
                let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
                return mood.date >= monthAgo
            }
        }
    }
    
    var body: some View {
        VStack {
            Picker("Временной период", selection: $timeRange) {
                Text("День").tag(TimeRange.day)
                Text("Неделя").tag(TimeRange.week)
                Text("Месяц").tag(TimeRange.month)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if !filteredMoods.isEmpty {
                Chart(filteredMoods) { mood in
                    BarMark(
                        x: .value("Время", mood.date),
                        y: .value("Настроение", moodValue(for: mood.type))
                    )
                    .foregroundStyle(by: .value("Тип", mood.type.rawValue))
                }
                .frame(height: 200)
                .padding()
            } else {
                Text("Нет данных за выбранный период")
                    .foregroundColor(.gray)
                    .padding()
            }
            
            List {
                ForEach(filteredMoods.sorted(by: { $0.date > $1.date })) { mood in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(mood.type.emoji)
                                .font(.title2)
                            Text(mood.type.rawValue)
                                .font(.headline)
                            Spacer()
                            Text(formatDate(mood.date))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        if let comment = mood.comment {
                            Text(comment)
                                .font(.body)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteMoods)
            }
        }
        .navigationTitle("История настроений")
    }
    
    private func moodValue(for type: MoodType) -> Double {
        switch type {
        case .happy: return 5
        case .neutral: return 3
        case .sad: return 2
        case .anxious: return 2
        case .angry: return 1
        case .other: return 3
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func deleteMoods(at offsets: IndexSet) {
        let sortedMoods = filteredMoods.sorted(by: { $0.date > $1.date })
        offsets.forEach { index in
            moodStore.deleteMood(sortedMoods[index])
        }
    }
} 