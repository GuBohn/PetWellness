import Foundation
import SwiftUI

// MARK: - Pet Model
struct Pet: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var type: PetType
    var breed: String
    var birthDate: Date
    var weight: Double // kg
    var photoData: Data?
    var color: String // fur color description

    enum PetType: String, Codable, CaseIterable {
        case dog = "Cachorro"
        case cat = "Gato"

        var icon: String {
            switch self {
            case .dog: return "🐕"
            case .cat: return "🐈"
            }
        }
        var sfSymbol: String {
            return "pawprint.fill"
        }
    }
}

// MARK: - DailyLog Model
struct DailyLog: Identifiable, Codable {
    var id: UUID = UUID()
    var petId: UUID
    var date: Date = Date()

    // Eliminação
    var didPoop: Bool = false
    var poopCount: Int = 0
    var poopColor: PoopColor = .brown
    var poopConsistency: PoopConsistency = .normal
    var poopNote: String = ""

    var didPee: Bool = false
    var peeAmount: PeeAmount = .normal
    var peeColor: PeeColor = .yellow
    var peeCount: Int = 0

    // Alimentação
    var ateFoodCompletely: Bool = true
    var foodPortionEaten: FoodPortion = .full
    var ateUnusualFood: Bool = false
    var unusualFoodDescription: String = ""
    var waterIntakeNormal: Bool = true

    // Comportamento
    var energyLevel: Int = 5 // 1–10
    var vocalizedMoreThanNormal: Bool = false
    var vocalNotes: String = ""
    var wasAggressiveOrSkittish: Bool = false
    var aggressiveNote: String = ""
    var played: Bool = true
    var playDurationMinutes: Int = 0
    var sleepHours: Double = 8
    var anxietyLevel: Int = 1 // 1–5
    var interactedWithOthers: Bool = true

    // Saúde
    var vomited: Bool = false
    var vomitCount: Int = 0
    var vomitTurns: [DayTurn] = []
    var vomitNote: String = ""
    var hasNewWound: Bool = false
    var woundDescription: String = ""
    var hasDischarge: Bool = false
    var dischargeLocation: String = ""
    var dischargeColor: String = ""
    var sneezedOrCoughed: Bool = false
    var sneezeCoughNote: String = ""
    var scratchedOrLickedExcessively: Bool = false
    var scratchNote: String = ""
    var eyesNormal: Bool = true
    var eyeNote: String = ""
    var earsNormal: Bool = true
    var earNote: String = ""
    var coatNormal: Bool = true
    var coatNote: String = ""

    // Medicação e peso
    var medicationsTaken: [String] = []
    var weightRecorded: Double? = nil

    // Nota geral
    var generalNotes: String = ""

    // MARK: - Health Score (0.0 to 1.0)
    var healthScore: Double {
        var score = 1.0
        var penalties = 0.0

        if !didPoop && poopCount == 0 { penalties += 0.05 }
        if poopColor != .brown { penalties += 0.05 }
        if poopConsistency == .liquid || poopConsistency == .veryHard { penalties += 0.1 }
        if !didPee { penalties += 0.05 }
        if peeColor == .orange || peeColor == .red { penalties += 0.1 }
        if foodPortionEaten == .none { penalties += 0.1 }
        if energyLevel <= 3 { penalties += 0.1 }
        if vomited { penalties += 0.1 * Double(min(vomitCount, 3)) / 3.0 }
        if hasNewWound { penalties += 0.1 }
        if hasDischarge { penalties += 0.1 }
        if wasAggressiveOrSkittish { penalties += 0.05 }
        if !eyesNormal { penalties += 0.05 }
        if !earsNormal { penalties += 0.05 }
        if sneezedOrCoughed { penalties += 0.05 }
        if scratchedOrLickedExcessively { penalties += 0.05 }

        return max(0, score - penalties)
    }

    var healthColor: Color {
        let s = healthScore
        if s >= 0.8 { return .green }
        if s >= 0.5 { return .orange }
        return .red
    }

    var healthEmoji: String {
        let s = healthScore
        if s >= 0.8 { return "😊" }
        if s >= 0.5 { return "😐" }
        return "😟"
    }
}

// MARK: - Enums

enum PoopColor: String, Codable, CaseIterable {
    case brown = "Marrom"
    case lightBrown = "Marrom claro"
    case darkBrown = "Marrom escuro"
    case black = "Preto"
    case red = "Vermelho/Sangue"
    case green = "Verde"
    case yellow = "Amarelo"
    case gray = "Cinza/Branco"

    var icon: String {
        switch self {
        case .brown: return "🟤"
        case .lightBrown: return "🟫"
        case .darkBrown: return "🫚"
        case .black: return "⚫️"
        case .red: return "🔴"
        case .green: return "🟢"
        case .yellow: return "🟡"
        case .gray: return "⚪️"
        }
    }

    var isAlert: Bool {
        return self == .black || self == .red || self == .gray
    }
}

enum PoopConsistency: String, Codable, CaseIterable {
    case liquid = "Líquido (diarreia)"
    case soft = "Mole"
    case normal = "Normal"
    case firm = "Firme"
    case veryHard = "Muito duro"

    var icon: String {
        switch self {
        case .liquid: return "💧"
        case .soft: return "🌊"
        case .normal: return "✅"
        case .firm: return "🔹"
        case .veryHard: return "🪨"
        }
    }

    var isAlert: Bool {
        return self == .liquid || self == .veryHard
    }
}

enum PeeAmount: String, Codable, CaseIterable {
    case little = "Pouco"
    case normal = "Normal"
    case alot = "Muito"

    var icon: String {
        switch self {
        case .little: return "💧"
        case .normal: return "💦"
        case .alot: return "🌊"
        }
    }
}

enum PeeColor: String, Codable, CaseIterable {
    case clear = "Clara/Incolor"
    case yellow = "Amarela (normal)"
    case darkYellow = "Amarela escura"
    case orange = "Laranja"
    case red = "Vermelha/Sangue"
    case brown = "Marrom"

    var icon: String {
        switch self {
        case .clear: return "⚪️"
        case .yellow: return "🟡"
        case .darkYellow: return "🟠"
        case .orange: return "🔶"
        case .red: return "🔴"
        case .brown: return "🟤"
        }
    }

    var isAlert: Bool {
        return self == .red || self == .orange || self == .brown
    }
}

enum FoodPortion: String, Codable, CaseIterable {
    case none = "Nada"
    case little = "Menos da metade"
    case half = "Metade"
    case most = "Quase tudo"
    case full = "Tudo"

    var icon: String {
        switch self {
        case .none: return "❌"
        case .little: return "🍽️¼"
        case .half: return "🍽️½"
        case .most: return "🍽️¾"
        case .full: return "✅"
        }
    }
}

enum DayTurn: String, Codable, CaseIterable {
    case earlyMorning = "Madrugada"
    case morning = "Manhã"
    case afternoon = "Tarde"
    case evening = "Noite"

    var icon: String {
        switch self {
        case .earlyMorning: return "🌙"
        case .morning: return "🌅"
        case .afternoon: return "☀️"
        case .evening: return "🌆"
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    static let shared = AppState()

    @Published var pets: [Pet] = []
    @Published var logs: [DailyLog] = []
    @Published var selectedPetId: UUID?

    private let petsKey = "saved_pets"
    private let logsKey = "saved_logs"

    init() {
        loadData()
        if pets.isEmpty {
            // Sample data
            let sampleDog = Pet(name: "Thor", type: .dog, breed: "Golden Retriever", birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!, weight: 28.5, color: "Dourado")
            let sampleCat = Pet(name: "Luna", type: .cat, breed: "SRD", birthDate: Calendar.current.date(byAdding: .year, value: -2, to: Date())!, weight: 4.2, color: "Preto e branco")
            pets = [sampleDog, sampleCat]
            selectedPetId = sampleDog.id
            saveData()
        } else {
            selectedPetId = pets.first?.id
        }
    }

    var selectedPet: Pet? {
        pets.first { $0.id == selectedPetId }
    }

    func logsForPet(_ petId: UUID) -> [DailyLog] {
        logs.filter { $0.petId == petId }
            .sorted { $0.date > $1.date }
    }

    func logForPetToday(_ petId: UUID) -> DailyLog? {
        let cal = Calendar.current
        return logs.first { log in
            log.petId == petId && cal.isDateInToday(log.date)
        }
    }

    func saveLog(_ log: DailyLog) {
        if let idx = logs.firstIndex(where: { $0.id == log.id }) {
            logs[idx] = log
        } else {
            logs.append(log)
        }
        saveData()
    }

    func deleteLog(_ log: DailyLog) {
        logs.removeAll { $0.id == log.id }
        saveData()
    }

    func addPet(_ pet: Pet) {
        pets.append(pet)
        if selectedPetId == nil { selectedPetId = pet.id }
        saveData()
    }

    func updatePet(_ pet: Pet) {
        if let idx = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[idx] = pet
        }
        saveData()
    }

    func deletePet(_ pet: Pet) {
        pets.removeAll { $0.id == pet.id }
        logs.removeAll { $0.petId == pet.id }
        if selectedPetId == pet.id { selectedPetId = pets.first?.id }
        saveData()
    }

    private func saveData() {
        if let d = try? JSONEncoder().encode(pets) { UserDefaults.standard.set(d, forKey: petsKey) }
        if let d = try? JSONEncoder().encode(logs) { UserDefaults.standard.set(d, forKey: logsKey) }
    }

    private func loadData() {
        if let d = UserDefaults.standard.data(forKey: petsKey),
           let p = try? JSONDecoder().decode([Pet].self, from: d) {
            pets = p
        }
        if let d = UserDefaults.standard.data(forKey: logsKey),
           let l = try? JSONDecoder().decode([DailyLog].self, from: d) {
            logs = l
        }
    }
}
