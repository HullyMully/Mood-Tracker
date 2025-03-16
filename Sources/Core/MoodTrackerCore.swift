@_exported import CoreData
@_exported import Foundation
@_exported import SwiftUI

public class MoodEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var comment: String?
    @NSManaged public var date: Date?
}

public enum MoodType: String, CaseIterable, Codable {
    case happy = "Счастье"
    case sad = "Грусть"
    case anxious = "Тревога"
    case angry = "Злость"
    case neutral = "Нейтрально"
    case other = "Другое"
    
    public var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .anxious: return "😰"
        case .angry: return "😠"
        case .neutral: return "😐"
        case .other: return "🤔"
        }
    }
}

public struct Mood: Identifiable, Codable {
    public let id: UUID
    public var type: MoodType
    public var comment: String?
    public var date: Date
    
    public init(id: UUID = UUID(), type: MoodType, comment: String? = nil, date: Date = Date()) {
        self.id = id
        self.type = type
        self.comment = comment
        self.date = date
    }
}

@available(macOS 13.0, *)
public class MoodStore: ObservableObject {
    @Published public var moods: [Mood] = []
    private let container: NSPersistentContainer
    
    public init() {
        container = NSPersistentContainer(name: "MoodTracker")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Ошибка загрузки CoreData: \(error.localizedDescription)")
            }
        }
        fetchMoods()
    }
    
    public func fetchMoods() {
        let request = NSFetchRequest<MoodEntity>(entityName: "MoodEntity")
        
        do {
            let results = try container.viewContext.fetch(request)
            moods = results.compactMap { entity in
                guard let typeString = entity.type,
                      let type = MoodType(rawValue: typeString),
                      let id = entity.id,
                      let date = entity.date else {
                    return nil
                }
                return Mood(id: id,
                          type: type,
                          comment: entity.comment,
                          date: date)
            }
        } catch {
            print("Ошибка загрузки настроений: \(error.localizedDescription)")
        }
    }
    
    public func addMood(_ mood: Mood) {
        let entity = MoodEntity(context: container.viewContext)
        entity.id = mood.id
        entity.type = mood.type.rawValue
        entity.comment = mood.comment
        entity.date = mood.date
        
        save()
        fetchMoods()
    }
    
    public func deleteMood(_ mood: Mood) {
        let request = NSFetchRequest<MoodEntity>(entityName: "MoodEntity")
        request.predicate = NSPredicate(format: "id == %@", mood.id as CVarArg)
        
        do {
            let results = try container.viewContext.fetch(request)
            if let entity = results.first {
                container.viewContext.delete(entity)
                save()
                fetchMoods()
            }
        } catch {
            print("Ошибка удаления настроения: \(error.localizedDescription)")
        }
    }
    
    private func save() {
        do {
            try container.viewContext.save()
        } catch {
            print("Ошибка сохранения данных: \(error.localizedDescription)")
        }
    }
} 