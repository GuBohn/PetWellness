import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var viewMode: ViewMode = .grid
    @State private var selectedLog: DailyLog? = nil

    private let accentGreen = Color(red: 0.4, green: 0.75, blue: 0.55)
    private let softBG = Color(red: 0.97, green: 0.97, blue: 0.95)

    enum ViewMode { case grid, list }

    var logs: [DailyLog] {
        guard let id = appState.selectedPetId else { return [] }
        return appState.logsForPet(id)
    }

    var groupedLogs: [(String, [DailyLog])] {
        let cal = Calendar.current
        var groups: [String: [DailyLog]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "pt_BR")
        for log in logs {
            let key = formatter.string(from: log.date)
            groups[key, default: []].append(log)
        }
        return groups.sorted { a, b in
            let f = DateFormatter()
            f.dateFormat = "MMMM yyyy"
            f.locale = Locale(identifier: "pt_BR")
            let da = f.date(from: a.0) ?? Date.distantPast
            let db = f.date(from: b.0) ?? Date.distantPast
            return da > db
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Pet name + view toggle
                HStack {
                    if let pet = appState.selectedPet {
                        Label("\(pet.type.icon) \(pet.name)", systemImage: "")
                            .labelStyle(.titleOnly)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Picker("Modo", selection: $viewMode) {
                        Image(systemName: "square.grid.2x2.fill").tag(ViewMode.grid)
                        Image(systemName: "list.bullet").tag(ViewMode.list)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 90)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 3, y: 2)

                if logs.isEmpty {
                    Spacer()
                    VStack(spacing: 14) {
                        Text("📅").font(.system(size: 60))
                        Text("Sem registros ainda")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text("Faça o primeiro registro diário\nna aba Hoje!")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(groupedLogs, id: \.0) { month, monthLogs in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(month.capitalized)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                    
                                    if viewMode == .grid {
                                        gridView(logs: monthLogs)
                                    } else {
                                        listView(logs: monthLogs)
                                    }
                                }
                            }
                            Spacer(minLength: 20)
                        }
                        .padding(.top, 12)
                    }
                    .background(softBG)
                }
            }
            .background(softBG.ignoresSafeArea())
            .navigationTitle("Histórico")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedLog) { log in
                LogDetailView(log: log)
            }
        }
    }

    // MARK: - Grid View
    func gridView(logs: [DailyLog]) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(logs) { log in
                HistoryGridCell(log: log)
                    .onTapGesture { selectedLog = log }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - List View
    func listView(logs: [DailyLog]) -> some View {
        VStack(spacing: 10) {
            ForEach(logs) { log in
                HistoryListRow(log: log)
                    .onTapGesture { selectedLog = log }
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - Grid Cell
struct HistoryGridCell: View {
    let log: DailyLog
    private let cal = Calendar.current
    
    var dayNumber: String {
        String(cal.component(.day, from: log.date))
    }
    var dayName: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "EEE"
        return f.string(from: log.date).uppercased()
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Health color dot + day
            ZStack {
                Circle()
                    .fill(log.healthColor.opacity(0.18))
                    .frame(width: 44, height: 44)
                Text(log.healthEmoji)
                    .font(.system(size: 22))
            }
            
            Text(dayNumber)
                .font(.system(size: 17, weight: .bold, design: .rounded))
            Text(dayName)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
            
            // Quick indicators
            HStack(spacing: 4) {
                if log.vomited { Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red) }
                if log.hasNewWound { Image(systemName: "bandage.fill").foregroundColor(.orange) }
                if log.energyLevel <= 3 { Image(systemName: "battery.25percent").foregroundColor(.red) }
                if !log.vomited && !log.hasNewWound && log.energyLevel > 3 {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green.opacity(0.6))
                }
            }
            .font(.system(size: 10))
            
            // Health bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.gray.opacity(0.15)).frame(height: 4)
                    RoundedRectangle(cornerRadius: 3).fill(log.healthColor).frame(width: geo.size.width * log.healthScore, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 5, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(log.healthColor.opacity(0.3), lineWidth: 1.5)
        )
    }
}

// MARK: - List Row
struct HistoryListRow: View {
    let log: DailyLog
    
    var formattedDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "EEEE, dd 'de' MMMM"
        return f.string(from: log.date).capitalized
    }
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(log.healthColor.opacity(0.18)).frame(width: 50, height: 50)
                Text(log.healthEmoji).font(.system(size: 24))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.system(size: 14, weight: .semibold))
                
                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Text("💩").font(.system(size: 11))
                        Text(log.didPoop ? "\(log.poopCount)x" : "—")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 3) {
                        Text("⚡️").font(.system(size: 11))
                        Text("\(log.energyLevel)/10")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 3) {
                        Text("🍽️").font(.system(size: 11))
                        Text(log.foodPortionEaten.rawValue)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // Alert chips
                if !buildAlerts().isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach(buildAlerts(), id: \.self) { alert in
                                Text(alert)
                                    .font(.system(size: 10, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundColor(.orange)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(log.healthScore * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(log.healthColor)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
    
    func buildAlerts() -> [String] {
        var a: [String] = []
        if log.vomited { a.append("🤢 Vomitou") }
        if log.hasNewWound { a.append("🩹 Machucado") }
        if log.hasDischarge { a.append("⚠️ Secreção") }
        if log.peeColor.isAlert { a.append("💧 Xixi") }
        if log.poopColor.isAlert { a.append("💩 Cocô") }
        return a
    }
}

// MARK: - Log Detail View
struct LogDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let log: DailyLog
    @State private var showEditForm = false
    @State private var showDeleteConfirm = false
    
    private let accentGreen = Color(red: 0.4, green: 0.75, blue: 0.55)

    var pet: Pet? { appState.pets.first { $0.id == log.petId } }
    
    var formattedDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "EEEE, dd 'de' MMMM 'de' yyyy"
        return f.string(from: log.date).capitalized
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(log.healthColor.opacity(0.18)).frame(width: 60, height: 60)
                            Text(log.healthEmoji).font(.system(size: 32))
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(formattedDate)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                            HStack {
                                Text("Saúde: \(Int(log.healthScore * 100))%")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(log.healthColor)
                                if let pet = pet {
                                    Text("• \(pet.name)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                    
                    // Detail sections
                    DetailSection(title: "🚽 Eliminação") {
                        DetailRow(label: "Cocô", value: log.didPoop ? "\(log.poopCount)x — \(log.poopColor.icon) \(log.poopColor.rawValue), \(log.poopConsistency.rawValue)" : "Não fez")
                        DetailRow(label: "Xixi", value: log.didPee ? "\(log.peeCount)x — \(log.peeAmount.rawValue), \(log.peeColor.icon) \(log.peeColor.rawValue)" : "Não fez")
                    }
                    
                    DetailSection(title: "🍽️ Alimentação") {
                        DetailRow(label: "Ração", value: "\(log.foodPortionEaten.icon) \(log.foodPortionEaten.rawValue)")
                        DetailRow(label: "Água", value: log.waterIntakeNormal ? "Normal ✅" : "Incomum ⚠️")
                        if log.ateUnusualFood {
                            DetailRow(label: "Alimento diferente", value: log.unusualFoodDescription, isAlert: true)
                        }
                    }
                    
                    DetailSection(title: "🎾 Comportamento") {
                        DetailRow(label: "Energia", value: "\(log.energyLevel)/10")
                        DetailRow(label: "Ansiedade", value: "\(log.anxietyLevel)/5")
                        DetailRow(label: "Brincou", value: log.played ? "Sim (\(log.playDurationMinutes) min)" : "Não")
                        DetailRow(label: "Sono", value: String(format: "%.1f horas", log.sleepHours))
                        if log.vocalizedMoreThanNormal {
                            DetailRow(label: "Vocal. excessiva", value: log.vocalNotes.isEmpty ? "Sim" : log.vocalNotes, isAlert: true)
                        }
                        if log.wasAggressiveOrSkittish {
                            DetailRow(label: "Agressivo/arisco", value: log.aggressiveNote.isEmpty ? "Sim" : log.aggressiveNote, isAlert: true)
                        }
                    }
                    
                    DetailSection(title: "🏥 Saúde") {
                        if log.vomited {
                            DetailRow(label: "Vômito", value: "\(log.vomitCount)x — \(log.vomitTurns.map { $0.rawValue }.joined(separator: ", "))", isAlert: true)
                        }
                        if log.hasNewWound {
                            DetailRow(label: "Machucado", value: log.woundDescription, isAlert: true)
                        }
                        if log.hasDischarge {
                            DetailRow(label: "Secreção", value: "\(log.dischargeLocation) — \(log.dischargeColor)", isAlert: true)
                        }
                        DetailRow(label: "Olhos", value: log.eyesNormal ? "Normal ✅" : log.eyeNote, isAlert: !log.eyesNormal)
                        DetailRow(label: "Orelhas", value: log.earsNormal ? "Normal ✅" : log.earNote, isAlert: !log.earsNormal)
                        DetailRow(label: "Pelagem", value: log.coatNormal ? "Normal ✅" : log.coatNote, isAlert: !log.coatNormal)
                        if log.sneezedOrCoughed {
                            DetailRow(label: "Espirros/Tosse", value: log.sneezeCoughNote.isEmpty ? "Sim" : log.sneezeCoughNote, isAlert: true)
                        }
                        if log.scratchedOrLickedExcessively {
                            DetailRow(label: "Coçou/lambeu", value: log.scratchNote.isEmpty ? "Excessivamente" : log.scratchNote, isAlert: true)
                        }
                    }
                    
                    if !log.medicationsTaken.isEmpty || log.weightRecorded != nil {
                        DetailSection(title: "💊 Extras") {
                            if !log.medicationsTaken.isEmpty {
                                DetailRow(label: "Medicamentos", value: log.medicationsTaken.joined(separator: ", "))
                            }
                            if let w = log.weightRecorded {
                                DetailRow(label: "Peso", value: String(format: "%.1f kg", w))
                            }
                        }
                    }
                    
                    if !log.generalNotes.isEmpty {
                        DetailSection(title: "📝 Notas") {
                            Text(log.generalNotes)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.95).ignoresSafeArea())
            .navigationTitle("Detalhes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fechar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showEditForm = true
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Excluir", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(accentGreen)
                    }
                }
            }
            .sheet(isPresented: $showEditForm) {
                if let pet = pet {
                    LogFormView(pet: pet, existingLog: log)
                }
            }
            .alert("Excluir registro?", isPresented: $showDeleteConfirm) {
                Button("Excluir", role: .destructive) {
                    appState.deleteLog(log)
                    dismiss()
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    let content: Content
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            VStack(spacing: 8) { content }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var isAlert: Bool = false
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(isAlert ? .orange : .primary)
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
}
