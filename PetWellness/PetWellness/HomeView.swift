import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLogForm = false
    @State private var showPetPicker = false

    private let accentGreen = Color(red: 0.4, green: 0.75, blue: 0.55)
    private let softBG = Color(red: 0.97, green: 0.97, blue: 0.95)

    var todayLog: DailyLog? {
        guard let id = appState.selectedPetId else { return nil }
        return appState.logForPetToday(id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Pet selector header
                    petHeaderCard
                    
                    // Today's status
                    if let log = todayLog {
                        todayStatusCard(log: log)
                        alertsCard(log: log)
                        quickStatsGrid(log: log)
                        
                        Button {
                            showLogForm = true
                        } label: {
                            Label("Editar Registro de Hoje", systemImage: "pencil.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(accentGreen)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                    } else {
                        noLogCard
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .background(softBG.ignoresSafeArea())
            .navigationTitle("PetSaúde")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showPetPicker = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(accentGreen)
                    }
                }
            }
            .sheet(isPresented: $showLogForm) {
                if let pet = appState.selectedPet {
                    LogFormView(pet: pet, existingLog: todayLog)
                }
            }
            .sheet(isPresented: $showPetPicker) {
                PetPickerSheet()
            }
        }
    }

    // MARK: - Pet Header Card
    var petHeaderCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accentGreen.opacity(0.18))
                    .frame(width: 62, height: 62)
                Text(appState.selectedPet?.type.icon ?? "🐾")
                    .font(.system(size: 32))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(appState.selectedPet?.name ?? "Nenhum pet")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                HStack(spacing: 6) {
                    Text(appState.selectedPet?.type.rawValue ?? "")
                    if let breed = appState.selectedPet?.breed, !breed.isEmpty {
                        Text("•")
                        Text(breed)
                    }
                }
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text(Date().formatted(.dateTime.day().month(.wide)))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Text(Date().formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
        .padding(.horizontal)
    }

    // MARK: - Today Status Card
    func todayStatusCard(log: DailyLog) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(log.healthColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                Text(log.healthEmoji)
                    .font(.system(size: 30))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Saúde de hoje")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 6) {
                    Text(healthLabel(score: log.healthScore))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("\(Int(log.healthScore * 100))%")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(log.healthColor.opacity(0.15))
                        .foregroundColor(log.healthColor)
                        .cornerRadius(8)
                }
                
                ProgressView(value: log.healthScore)
                    .tint(log.healthColor)
                    .frame(width: 160)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
        .padding(.horizontal)
    }

    // MARK: - Alerts Card
    func alertsCard(log: DailyLog) -> some View {
        let alerts = buildAlerts(log: log)
        if alerts.isEmpty { return AnyView(EmptyView()) }
        
        return AnyView(
            VStack(alignment: .leading, spacing: 10) {
                Label("Alertas", systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
                
                ForEach(alerts, id: \.self) { alert in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.orange.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Text(alert)
                            .font(.system(size: 13))
                            .foregroundColor(.primary.opacity(0.8))
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.07))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.orange.opacity(0.25), lineWidth: 1)
            )
            .padding(.horizontal)
        )
    }

    // MARK: - Quick Stats Grid
    func quickStatsGrid(log: DailyLog) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(icon: "🟤", title: "Cocô", value: log.didPoop ? "\(log.poopCount)x" : "Não", color: log.didPoop ? .brown : .orange)
            StatCard(icon: "💧", title: "Xixi", value: log.didPee ? log.peeAmount.rawValue : "Não", color: log.didPee ? accentGreen : .orange)
            StatCard(icon: "⚡️", title: "Energia", value: "\(log.energyLevel)/10", color: energyColor(log.energyLevel))
            StatCard(icon: "🍽️", title: "Ração", value: log.foodPortionEaten.rawValue, color: log.foodPortionEaten == .full ? accentGreen : .orange)
            StatCard(icon: "🤸", title: "Brincou", value: log.played ? "Sim" : "Não", color: log.played ? accentGreen : .secondary)
            StatCard(icon: "🌙", title: "Sono", value: String(format: "%.1fh", log.sleepHours), color: .indigo)
        }
        .padding(.horizontal)
    }

    // MARK: - No Log Card
    var noLogCard: some View {
        VStack(spacing: 20) {
            Text("🐾")
                .font(.system(size: 60))
            Text("Nenhum registro para hoje")
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Text("Como seu pet está se sentindo hoje?\nRegistre o bem-estar agora!")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showLogForm = true
            } label: {
                Label("Fazer Registro do Dia", systemImage: "plus.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(accentGreen)
                    .cornerRadius(16)
            }
        }
        .padding(28)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
        .padding(.horizontal)
    }

    // MARK: - Helpers
    func buildAlerts(log: DailyLog) -> [String] {
        var alerts: [String] = []
        if log.vomited { alerts.append("Vomitou \(log.vomitCount) vez(es)") }
        if log.hasNewWound { alerts.append("Machucado novo: \(log.woundDescription)") }
        if log.hasDischarge { alerts.append("Secreção em \(log.dischargeLocation)") }
        if log.poopColor.isAlert { alerts.append("Cor do cocô: \(log.poopColor.rawValue)") }
        if log.poopConsistency.isAlert { alerts.append("Consistência: \(log.poopConsistency.rawValue)") }
        if log.peeColor.isAlert { alerts.append("Cor do xixi: \(log.peeColor.rawValue)") }
        if log.energyLevel <= 2 { alerts.append("Energia muito baixa (\(log.energyLevel)/10)") }
        if log.foodPortionEaten == .none { alerts.append("Não comeu nada hoje") }
        if log.sneezedOrCoughed { alerts.append("Espirros ou tosse observados") }
        if log.wasAggressiveOrSkittish { alerts.append("Comportamento agressivo/arisco") }
        return alerts
    }

    func healthLabel(score: Double) -> String {
        if score >= 0.85 { return "Ótimo!" }
        if score >= 0.65 { return "Bom" }
        if score >= 0.4 { return "Atenção" }
        return "Cuidado!"
    }

    func energyColor(_ level: Int) -> Color {
        if level >= 7 { return .green }
        if level >= 4 { return .orange }
        return .red
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 22))
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Pet Picker Sheet
struct PetPickerSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    private let accentGreen = Color(red: 0.4, green: 0.75, blue: 0.55)

    var body: some View {
        NavigationStack {
            List(appState.pets) { pet in
                Button {
                    appState.selectedPetId = pet.id
                    dismiss()
                } label: {
                    HStack(spacing: 14) {
                        Text(pet.type.icon)
                            .font(.system(size: 28))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pet.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("\(pet.type.rawValue) • \(pet.breed)")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if appState.selectedPetId == pet.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(accentGreen)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Selecionar Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }
}
