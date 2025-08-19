import Foundation

/// A single bird observation event.
/// Stored as an immutable record with the species (taxonId) and capture timestamp.
/// Named ObservationRecord to avoid conflicting with Apple's Observation module.
public struct ObservationRecord: Identifiable, Codable, Equatable {
    // MARK: Identity & hierarchy
    public let id: UUID
    /// Optional parent record id when this record is a child event.
    public var parentId: UUID? = nil
    /// Nested child observation records. Mutating helpers provided below to maintain hierarchy.
    public var children: [ObservationRecord] = []

    // MARK: Core data
    public let taxonId: String
    // Use a time interval [begin, end]; default behavior is begin == end
    public let begin: Date
    public let end: Date
    public var count: Int


    // MARK: Initializers
    /// Base initializer (no parent). Backward-compatible with existing call sites.
    public init(id: UUID = UUID(), taxonId: String, begin: Date = Date(), end: Date? = nil, count: Int = 1) {
        self.id = id
        self.taxonId = taxonId
        self.begin = begin
        self.end = end ?? begin
    self.count = count
        self.parentId = nil
        self.children = []
    }

    /// Convenience initializer to attach the new record as a child of `parent`.
    /// The child's parentId is set and the child is appended to the parent's children array.
    public init(parent: inout ObservationRecord, id: UUID = UUID(), taxonId: String, begin: Date = Date(), end: Date? = nil, count: Int = 1) {
        self.id = id
        self.taxonId = taxonId
        self.begin = begin
        self.end = end ?? begin
    self.count = count
        self.parentId = parent.id
        self.children = []
        // After initialization, append to parent's children to maintain hierarchy.
        parent.children.append(self)
    }

    // MARK: Mutating helpers
    /// Append a child record and set its parentId to this record's id.
    public mutating func addChild(_ child: ObservationRecord) {
        var adjusted = child
        adjusted.parentId = self.id
        children.append(adjusted)
    }
}
