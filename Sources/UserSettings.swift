import Foundation
import Combine

class UserSettings: ObservableObject {
    private let succeededDatesKey = "succeededDatesKey"

    @Published var succeededDates: Set<DateComponents> {
        didSet {
            saveSucceededDates()
        }
    }

    @Published var cigarettesPerDay: Int {
        didSet {
            UserDefaults.standard.set(cigarettesPerDay, forKey: "cigarettesPerDayKey")
        }
    }

    @Published var pricePerPack: Double {
        didSet {
            UserDefaults.standard.set(pricePerPack, forKey: "pricePerPackKey")
        }
    }

    @Published var cigarettesPerPack: Int {
        didSet {
            UserDefaults.standard.set(cigarettesPerPack, forKey: "cigarettesPerPackKey")
        }
    }

    init() {
        // Load succeeded dates
        if let data = UserDefaults.standard.data(forKey: succeededDatesKey) {
            let decoder = JSONDecoder()
            if let decodedDates = try? decoder.decode(Set<DateComponents>.self, from: data) {
                self.succeededDates = decodedDates
            } else {
                self.succeededDates = []
            }
        } else {
            self.succeededDates = []
        }

        // Load other settings
        self.cigarettesPerDay = UserDefaults.standard.object(forKey: "cigarettesPerDayKey") as? Int ?? 20
        self.pricePerPack = UserDefaults.standard.object(forKey: "pricePerPackKey") as? Double ?? 600.0
        self.cigarettesPerPack = UserDefaults.standard.object(forKey: "cigarettesPerPackKey") as? Int ?? 20
    }

    private func saveSucceededDates() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(succeededDates) {
            UserDefaults.standard.set(encoded, forKey: succeededDatesKey)
        }
    }
}

// Make DateComponents Codable
extension DateComponents: Codable {
    enum CodingKeys: String, CodingKey {
        case year, month, day
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            year: try container.decodeIfPresent(Int.self, forKey: .year),
            month: try container.decodeIfPresent(Int.self, forKey: .month),
            day: try container.decodeIfPresent(Int.self, forKey: .day)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(year, forKey: .year)
        try container.encodeIfPresent(month, forKey: .month)
        try container.encodeIfPresent(day, forKey: .day)
    }
}

extension DateComponents: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(year)
        hasher.combine(month)
        hasher.combine(day)
    }
}
