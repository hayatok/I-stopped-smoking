import Foundation
import Combine

class UserSettings: ObservableObject {
    @Published var quitDate: Date {
        didSet {
            UserDefaults.standard.set(quitDate, forKey: "quitDateKey")
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
        self.quitDate = UserDefaults.standard.object(forKey: "quitDateKey") as? Date ?? Date()

        if let cigarettesPerDay = UserDefaults.standard.object(forKey: "cigarettesPerDayKey") as? Int {
            self.cigarettesPerDay = cigarettesPerDay
        } else {
            self.cigarettesPerDay = 20
        }

        if let pricePerPack = UserDefaults.standard.object(forKey: "pricePerPackKey") as? Double {
            self.pricePerPack = pricePerPack
        } else {
            self.pricePerPack = 600.0
        }

        if let cigarettesPerPack = UserDefaults.standard.object(forKey: "cigarettesPerPackKey") as? Int {
            self.cigarettesPerPack = cigarettesPerPack
        } else {
            self.cigarettesPerPack = 20
        }
    }
}
