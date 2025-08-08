import Foundation

public struct ToDoItem: Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var notes: String
    public var dueDate: Date?
    public var isCompleted: Bool
    public var reminderDate: Date?
    public var sharedWith: [String]

    public init(id: UUID = UUID(), title: String, notes: String = "", dueDate: Date? = nil, isCompleted: Bool = false, reminderDate: Date? = nil, sharedWith: [String] = []) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.reminderDate = reminderDate
        self.sharedWith = sharedWith
    }
}

public protocol ToDoRepository {
    func allItems() -> [ToDoItem]
    func item(withId id: UUID) -> ToDoItem?
    func add(_ item: ToDoItem)
    func update(_ item: ToDoItem)
    func markCompleted(id: UUID, completed: Bool)
    func setReminder(id: UUID, date: Date?)
    func share(id: UUID, members: [String])
}

public final class InMemoryToDoRepository: ToDoRepository {
    private var items: [ToDoItem] = []
    private let lock = NSLock()

    public init(seed: [ToDoItem] = [
        ToDoItem(title: "Grocery shopping", notes: "Milk, eggs, bread", dueDate: Date().addingTimeInterval(3600*24)),
        ToDoItem(title: "Dentist appointment", notes: "For Alex", dueDate: Date().addingTimeInterval(3600*48)),
        ToDoItem(title: "Plan weekend trip", notes: "Look at cabins")
    ]) {
        self.items = seed
    }

    public func allItems() -> [ToDoItem] {
        lock.lock(); defer { lock.unlock() }
        return items
    }

    public func item(withId id: UUID) -> ToDoItem? {
        lock.lock(); defer { lock.unlock() }
        return items.first(where: { $0.id == id })
    }

    public func add(_ item: ToDoItem) {
        lock.lock(); defer { lock.unlock() }
        items.append(item)
    }

    public func update(_ item: ToDoItem) {
        lock.lock(); defer { lock.unlock() }
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
    }

    public func markCompleted(id: UUID, completed: Bool) {
        lock.lock(); defer { lock.unlock() }
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].isCompleted = completed
    }

    public func setReminder(id: UUID, date: Date?) {
        lock.lock(); defer { lock.unlock() }
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].reminderDate = date
    }

    public func share(id: UUID, members: [String]) {
        lock.lock(); defer { lock.unlock() }
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].sharedWith = members
    }
}


