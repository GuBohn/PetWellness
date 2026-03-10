import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedPeriod: Period = .week

    private let accentGreen = Color(red: 0.4, green: 0.75, blue: 0.55)
    private let softBG = Color(red: 0.97, green: 0.97, blue: 0.95)

    enum Period: String, CaseIterable {
        case week = "7 dias"
        case month = "30 dias"
        case all = "Tudo"
    }

    var filteredLogs: [DailyLog] {
        guard let id = appState.selectedPetId else { return [] }
        let allLogs = appState.logsForPet(id)
        let cal = Calendar.current
        switch selectedPeriod {
        case .week:
            let cutoff = cal.date(byAdding: .day, value: -7, to: Date())!
            return allLogs.filter { $0.date >= cutoff }
        case .month:
            let cutoff = cal.date(byAdding: .day, value: -30, to: Date())!
            return allLogs.filter { $0.date >= cutoff }
        case .all:
            return allLogs
        }
    }

    var avgHealth: Double {
        guard !filteredLogs.isEmpty else { return 0 }
        return filteredLogs.map { $0.healthScore }.reduce(0, +) / Double(filteredLogs.count)
    }
    var avgEnergy: Double {
        guard !filteredLogs.isEmpty else { return 0 }
        return Double(filteredLogs.map { $0.energyLevel }.reduce(0, +)) / Double(filteredLogs.count)
    }
    var vomitDays: Int { filteredLogs.filter { $0.vomited }.count }
    var playDays: Int { filteredLogs.filter { $0.played }.count }
    var avgSleep: Double {
        guard !filteredLogs.isEmpty else { return 0 }
        return filteredLogs.map { $0.sleepHours }.reduce(0, +) / Double(filteredLogs.count)
    }
    var alertCount: Int {
        filteredLogs.filter { $0.healthScore < 0.6 }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Pet info
                    if let pet = appState.selectedPet {
                        HStack {
                            Text("\(pet.type.icon) \(pet.name)")
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                            Text("\(filteredLogs.count) registros")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Period picker
                    Picker("Período", selection: $selectedPeriod) {
                        ForEach(Period.allCases, id: \.self) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if filteredLogs.isEmpty {
                        VStack(spacing: 12) {
                            Text("📊").font(.system(size: 50))
                            Text("Sem dados para o período")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Faça registros diários para ver análises aqui!")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(40)
                    } else {
                        // Summary cards
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            InsightCard(title: "Saúde Média", value: "\(Int(avgHealth * 100))%", icon: "❤️", color: healthColor(avgHealth), subtitle: healthLabel(avgHealth))
                            InsightCard(title: "Energia Média", value: String(format: "%.1f/10", avgEnergy), icon: "⚡️", color: energyColor(avgEnergy), subtitle: energyLabel(avgEnergy))
                            InsightCard(title: "Dias Brincando", value: "\(playDays)/\(filteredLogs.count)", icon: "🎾", color: accentGreen, subtitle: "\(playDays > 0 ? Int(Double(playDays)/Double(filteredLogs.count)*100) : 0)% dos dias")
                            InsightCard(title: "Sono Médio", value: String(format: "%.1fh", avgSleep), icon: "🌙", color: .indigo, subtitle: sleepLabel(avgSleep))
                            InsightCard(title: "Dias c/ Vômito", value: "\(vomitDays)", icon: "🤢", color: vomitDays > 2 ? .red : vomitDays > 0 ? .orange : .green, subtitle: vomitDays == 0 ? "Ótimo! 🎉" : "Atenção")
                            InsightCard(title: "Dias de Alerta", value: "\(alertCount)", icon: "⚠️", color: alertCount > 3 ? .red : alertCount > 0 ? .orange : .green, subtitle: alertCount == 0 ? "Tudo bem!" : "Verifique")
                        }
                        .padding(.horizontal)

                        // Health trend chart (simple bar chart)
                        healthTrendSection

                        // Energy trend
                        energyTrendSection

                        // Patterns section
                        patternsSection
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 12)
            }
            .background(softBG.ignoresSafeArea())
            .navigationTitle("Análises")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Health Trend
    var healthTrendSection: some View {
        let recent = Array(filteredLogs.prefix(14).reversed())
        return VStack(alignment: .leading, spacing: 12) {
            Text("Tendência de Saúde")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(recent) { log in
                        VStack(spacing: 4) {
                            Rectangle()
                                .fill(log.healthColor)
                                .frame(width: 28, height: max(12, CGFloat(log.healthScore) * 80))
                                .cornerRadius(6)
                            Text(dayShort(log.date))
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
            .padding(.horizontal)
        }
    }

    // MARK: - Energy Trend
    var energyTrendSection: some View {
        let recent = Array(filteredLogs.prefix(14).reversed())
        return VStack(alignment: .leading, spacing: 12) {
            Text("Níveis de Energia")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(recent) { log in
                        VStack(spacing: 4) {
                            ZStack(alignment: .bottom) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 28, height: 80)
                                    .cornerRadius(6)
                                Rectangle()
                                    .fill(energyColor(Double(log.energyLevel)))
                                    .frame(width: 28, height: CGFloat(log.energyLevel) * 8)
                                    .cornerRadius(6)
                            }
                            Text("\(log.energyLevel)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text(dayShort(log.date))
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
            .padding(.horizontal)
        }
    }

    // MARK: - Patterns
    var patternsSection: some View {
        let poopAbnormal = filteredLogs.filter { $0.poopColor.isAlert || $0.poopConsistency.isAlert }.count
        let peeAbnormal = filteredLogs.filter { $0.peeColor.isAlert }.count
        let notEatingDays = filteredLogs.filter { $0.foodPortionEaten == .none || $0.foodPortionEaten == .little }.count
        let aggDays = filteredLogs.filter { $0.wasAggressiveOrSkittish }.count
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Padrões observados")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                PatternRow(label: "Cocô fora do padrão", count: poopAbnormal, total: filteredLogs.count, icon: "💩")
                PatternRow(label: "Xixi com cor anormal", count: peeAbnormal, total: filteredLogs.count, icon: "💧")
                PatternRow(label: "Pouco ou nada comeu", count: notEatingDays, total: filteredLogs.count, icon: "🍽️")
                PatternRow(label: "Dias com vômito", count: vomitDays, total: filteredLogs.count, icon: "🤢")
                PatternRow(label: "Comportamento agressivo", count: aggDays, total: filteredLogs.count, icon: "⚠️")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
            .padding(.horizontal)
        }
    }

    // MARK: - Helpers
    func dayShort(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM"
        return f.string(from: date)
    }

    func healthColor(_ score: Double) -> Color {
        if score >= 0.8 { return .green }
        if score >= 0.5 { return .orange }
        return .red
    }
    func healthLabel(_ score: Double) -> String {
        if score >= 0.85 { return "Excelente!" }
        if score >= 0.65 { return "Boa" }
        if score >= 0.4 { return "Atenção" }
        return "Preocupante"
    }
    func energyColor(_ e: Double) -> Color {
        if e >= 7 { return .green }
        if e >= 4 { return .orange }
        return .red
    }
    func energyLabel(_ e: Double) -> String {
        if e >= 7 { return "Muito ativo" }
        if e >= 4 { return "Moderado" }
        return "Baixo"
    }
    func sleepLabel(_ h: Double) -> String {
        if h >= 12 { return "Dormiu muito" }
        if h >= 8 { return "Normal" }
        return "Dormiu pouco"
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(icon).font(.system(size: 20))
                Spacer()
                Circle().fill(color.opacity(0.15)).frame(width: 8, height: 8)
            }
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}

struct PatternRow: View {
    let label: String
    let count: Int
    let total: Int
    let icon: String

    var percent: Double { total > 0 ? Double(count) / Double(total) : 0 }
    var color: Color {
        if percent == 0 { return .green }
        if percent <= 0.2 { return .orange }
        return .red
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(icon).font(.system(size: 14))
                Text(label).font(.system(size: 13))
                Spacer()
                Text("\(count) dias")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(count == 0 ? .green : .orange)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.1)).frame(height: 5)
                    RoundedRectangle(cornerRadius: 4).fill(color).frame(width: geo.size.width * percent, height: 5)
                }
            }
            .frame(height: 5)
        }
    }
}
