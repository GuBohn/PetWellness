import SwiftUI

struct LogFormView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    let pet: Pet
    let existingLog: DailyLog?

    @State private var log: DailyLog
    @State private var currentSection: Int = 0
    @State private var showSaveAlert = false

    private let accentGreen = Color(red: 0.4, green: 0.75, blue: 0.55)
    private let softBG = Color(red: 0.97, green: 0.97, blue: 0.95)

    private let sections = ["Eliminação", "Alimentação", "Comportamento", "Saúde", "Extras"]
    private let sectionIcons = ["toilet.fill", "fork.knife", "figure.run", "heart.text.square.fill", "note.text"]
    private let sectionEmojis = ["🚽", "🍽️", "🎾", "🏥", "📝"]

    init(pet: Pet, existingLog: DailyLog?) {
        self.pet = pet
        self.existingLog = existingLog
        if let existing = existingLog {
            _log = State(initialValue: existing)
        } else {
            _log = State(initialValue: DailyLog(petId: pet.id))
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Section Tabs
                sectionTabs
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)

                // Form Content
                ScrollView {
                    VStack(spacing: 18) {
                        switch currentSection {
                        case 0: eliminacaoSection
                        case 1: alimentacaoSection
                        case 2: comportamentoSection
                        case 3: saudeSection
                        default: extrasSection
                        }
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 16)
                    .padding(.horizontal)
                }
                .background(softBG)

                // Bottom Navigation
                bottomNav
            }
            .navigationTitle("Registro de \(pet.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        appState.saveLog(log)
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(accentGreen)
                }
            }
        }
    }

    // MARK: - Section Tabs
    var sectionTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<sections.count, id: \.self) { i in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentSection = i
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Text(sectionEmojis[i])
                                .font(.system(size: 14))
                            Text(sections[i])
                                .font(.system(size: 13, weight: currentSection == i ? .bold : .regular))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(currentSection == i ? accentGreen : Color.gray.opacity(0.1))
                        .foregroundColor(currentSection == i ? .white : .primary)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Bottom Navigation
    var bottomNav: some View {
        HStack(spacing: 16) {
            if currentSection > 0 {
                Button {
                    withAnimation { currentSection -= 1 }
                } label: {
                    HStack { Image(systemName: "chevron.left"); Text("Anterior") }
                        .font(.system(size: 15, weight: .medium))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 13)
                        .background(Color.gray.opacity(0.12))
                        .foregroundColor(.primary)
                        .cornerRadius(14)
                }
            }
            
            Spacer()
            
            if currentSection < sections.count - 1 {
                Button {
                    withAnimation { currentSection += 1 }
                } label: {
                    HStack { Text("Próximo"); Image(systemName: "chevron.right") }
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 13)
                        .background(accentGreen)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            } else {
                Button {
                    appState.saveLog(log)
                    dismiss()
                } label: {
                    HStack { Image(systemName: "checkmark"); Text("Salvar Registro") }
                        .font(.system(size: 15, weight: .bold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 13)
                        .background(accentGreen)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 6, y: -2)
    }

    // MARK: - Seção 1: Eliminação
    var eliminacaoSection: some View {
        VStack(spacing: 16) {
            FormSectionHeader(emoji: "💩", title: "Cocô")
            
            FormCard {
                VStack(spacing: 14) {
                    ToggleRow(icon: "checkmark.circle.fill", label: "Fez cocô hoje?", isOn: $log.didPoop, accentColor: accentGreen)
                    
                    if log.didPoop {
                        Divider()
                        StepperRow(label: "Quantas vezes?", value: $log.poopCount, range: 1...15)
                        Divider()
                        PickerRow(label: "Cor", selection: $log.poopColor)
                        Divider()
                        PickerRow(label: "Consistência", selection: $log.poopConsistency)
                        
                        if log.poopColor.isAlert || log.poopConsistency.isAlert {
                            AlertBanner(message: "Cor ou consistência fora do padrão. Consulte um veterinário se persistir.")
                        }
                        
                        Divider()
                        TextFieldRow(label: "Observações", text: $log.poopNote, placeholder: "Ex: tinha muco, com fragmentos...")
                    }
                }
            }
            
            FormSectionHeader(emoji: "💧", title: "Xixi")
            
            FormCard {
                VStack(spacing: 14) {
                    ToggleRow(icon: "checkmark.circle.fill", label: "Fez xixi hoje?", isOn: $log.didPee, accentColor: accentGreen)
                    
                    if log.didPee {
                        Divider()
                        StepperRow(label: "Quantas vezes?", value: $log.peeCount, range: 1...20)
                        Divider()
                        PickerRow(label: "Quantidade", selection: $log.peeAmount)
                        Divider()
                        PickerRow(label: "Cor", selection: $log.peeColor)
                        
                        if log.peeColor.isAlert {
                            AlertBanner(message: "Xixi em cor incomum. Pode indicar desidratação ou problema renal.")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Seção 2: Alimentação
    var alimentacaoSection: some View {
        VStack(spacing: 16) {
            FormSectionHeader(emoji: "🍽️", title: "Alimentação & Água")
            
            FormCard {
                VStack(spacing: 14) {
                    PickerRow(label: "Comeu a ração?", selection: $log.foodPortionEaten)
                    Divider()
                    ToggleRow(icon: "drop.fill", label: "Bebeu água normalmente?", isOn: $log.waterIntakeNormal, accentColor: .blue)
                    Divider()
                    ToggleRow(icon: "fork.knife.circle.fill", label: "Comeu alimento diferente?", isOn: $log.ateUnusualFood, accentColor: .orange)
                    
                    if log.ateUnusualFood {
                        Divider()
                        TextFieldRow(label: "O que comeu?", text: $log.unusualFoodDescription, placeholder: "Ex: frango, fruta, resto da mesa...")
                    }
                }
            }
        }
    }

    // MARK: - Seção 3: Comportamento
    var comportamentoSection: some View {
        VStack(spacing: 16) {
            FormSectionHeader(emoji: "🎾", title: "Comportamento & Humor")
            
            FormCard {
                VStack(spacing: 14) {
                    EnergySlider(value: $log.energyLevel)
                    Divider()
                    AnxietySelector(value: $log.anxietyLevel)
                    Divider()
                    ToggleRow(icon: "gamecontroller.fill", label: "Brincou?", isOn: $log.played, accentColor: accentGreen)
                    if log.played {
                        Divider()
                        StepperRow(label: "Tempo brincando (min)", value: $log.playDurationMinutes, range: 0...300, step: 5)
                    }
                    Divider()
                    SliderRow(label: "Horas de sono", value: $log.sleepHours, range: 0...24, step: 0.5, unit: "h")
                }
            }
            
            FormSectionHeader(emoji: "🔊", title: "Sons & Interação")
            
            FormCard {
                VStack(spacing: 14) {
                    ToggleRow(icon: "speaker.wave.2.fill",
                              label: pet.type == .dog ? "Latiu mais que o normal?" : "Miou mais que o normal?",
                              isOn: $log.vocalizedMoreThanNormal, accentColor: .orange)
                    if log.vocalizedMoreThanNormal {
                        Divider()
                        TextFieldRow(label: "Observações", text: $log.vocalNotes, placeholder: "Quando? O que aconteceu?")
                    }
                    Divider()
                    ToggleRow(icon: "person.2.fill", label: "Interagiu bem com pessoas/animais?", isOn: $log.interactedWithOthers, accentColor: accentGreen)
                    Divider()
                    ToggleRow(icon: "exclamationmark.triangle.fill", label: "Estava agressivo ou arisco?", isOn: $log.wasAggressiveOrSkittish, accentColor: .red)
                    if log.wasAggressiveOrSkittish {
                        Divider()
                        TextFieldRow(label: "Contexto", text: $log.aggressiveNote, placeholder: "Com quem? Em qual situação?")
                    }
                }
            }
        }
    }

    // MARK: - Seção 4: Saúde
    var saudeSection: some View {
        VStack(spacing: 16) {
            FormSectionHeader(emoji: "🤢", title: "Vômito")
            
            FormCard {
                VStack(spacing: 14) {
                    ToggleRow(icon: "exclamationmark.triangle.fill", label: "Vomitou?", isOn: $log.vomited, accentColor: .red)
                    if log.vomited {
                        Divider()
                        StepperRow(label: "Quantas vezes?", value: $log.vomitCount, range: 1...20)
                        Divider()
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Turno(s)").font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
                            HStack(spacing: 8) {
                                ForEach(DayTurn.allCases, id: \.self) { turn in
                                    TurnToggle(turn: turn, selected: $log.vomitTurns)
                                }
                            }
                        }
                        Divider()
                        TextFieldRow(label: "Observações", text: $log.vomitNote, placeholder: "Cor, consistência, após comer...")
                    }
                }
            }
            
            FormSectionHeader(emoji: "🩹", title: "Machucados & Secreções")
            
            FormCard {
                VStack(spacing: 14) {
                    ToggleRow(icon: "bandage.fill", label: "Algum machucado novo?", isOn: $log.hasNewWound, accentColor: .red)
                    if log.hasNewWound {
                        Divider()
                        TextFieldRow(label: "Onde e como?", text: $log.woundDescription, placeholder: "Localização, aparência...")
                    }
                    Divider()
                    ToggleRow(icon: "drop.triangle.fill", label: "Alguma secreção?", isOn: $log.hasDischarge, accentColor: .orange)
                    if log.hasDischarge {
                        Divider()
                        TextFieldRow(label: "Localização", text: $log.dischargeLocation, placeholder: "Olhos, nariz, ouvidos...")
                        Divider()
                        TextFieldRow(label: "Cor/aspecto", text: $log.dischargeColor, placeholder: "Transparente, amarelo, verde...")
                    }
                }
            }
            
            FormSectionHeader(emoji: "👁️", title: "Aparência & Sintomas")
            
            FormCard {
                VStack(spacing: 14) {
                    ToggleRow(icon: "eye.fill", label: "Olhos normais?", isOn: $log.eyesNormal, accentColor: accentGreen)
                    if !log.eyesNormal {
                        Divider()
                        TextFieldRow(label: "O que observou?", text: $log.eyeNote, placeholder: "Vermelhidão, secreção, fechado...")
                    }
                    Divider()
                    ToggleRow(icon: "ear.fill", label: "Orelhas normais?", isOn: $log.earsNormal, accentColor: accentGreen)
                    if !log.earsNormal {
                        Divider()
                        TextFieldRow(label: "O que observou?", text: $log.earNote, placeholder: "Coçando, cheiro, secreção...")
                    }
                    Divider()
                    ToggleRow(icon: "allergens", label: "Pelo/pelagem normal?", isOn: $log.coatNormal, accentColor: accentGreen)
                    if !log.coatNormal {
                        Divider()
                        TextFieldRow(label: "O que observou?", text: $log.coatNote, placeholder: "Queda excessiva, ressecado...")
                    }
                    Divider()
                    ToggleRow(icon: "wind", label: "Espirrou ou tossiu?", isOn: $log.sneezedOrCoughed, accentColor: .orange)
                    if log.sneezedOrCoughed {
                        Divider()
                        TextFieldRow(label: "Observações", text: $log.sneezeCoughNote, placeholder: "Frequência, com o que parece...")
                    }
                    Divider()
                    ToggleRow(icon: "hand.raised.fill", label: "Coçou ou lambeu excessivamente?", isOn: $log.scratchedOrLickedExcessively, accentColor: .orange)
                    if log.scratchedOrLickedExcessively {
                        Divider()
                        TextFieldRow(label: "Onde?", text: $log.scratchNote, placeholder: "Pata, barriga, focinho...")
                    }
                }
            }
        }
    }

    // MARK: - Seção 5: Extras
    var extrasSection: some View {
        VStack(spacing: 16) {
            FormSectionHeader(emoji: "💊", title: "Medicamentos")
            
            FormCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Medicamentos tomados hoje")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    MedicationList(medications: $log.medicationsTaken)
                }
            }
            
            FormSectionHeader(emoji: "⚖️", title: "Peso")
            
            FormCard {
                VStack(spacing: 14) {
                    HStack {
                        Text("Peso registrado hoje")
                            .font(.system(size: 15))
                        Spacer()
                        if log.weightRecorded == nil {
                            Button("+ Registrar") {
                                log.weightRecorded = pet.weight
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(accentGreen)
                        } else {
                            HStack {
                                Button(action: { log.weightRecorded = max(0.1, (log.weightRecorded ?? 1) - 0.1) }) {
                                    Image(systemName: "minus.circle")
                                }
                                Text(String(format: "%.1f kg", log.weightRecorded ?? 0))
                                    .font(.system(size: 15, weight: .semibold))
                                    .frame(width: 70)
                                Button(action: { log.weightRecorded = (log.weightRecorded ?? 0) + 0.1 }) {
                                    Image(systemName: "plus.circle")
                                }
                            }
                            .foregroundColor(accentGreen)
                        }
                    }
                }
            }
            
            FormSectionHeader(emoji: "📝", title: "Notas Gerais")
            
            FormCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Observações livres do dia")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    TextEditor(text: $log.generalNotes)
                        .frame(minHeight: 90)
                        .font(.system(size: 14))
                }
            }
        }
    }
}

// MARK: - Reusable Form Components

struct FormCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}

struct FormSectionHeader: View {
    let emoji: String
    let title: String
    var body: some View {
        HStack(spacing: 8) {
            Text(emoji).font(.system(size: 18))
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }
}

struct ToggleRow: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool
    let accentColor: Color
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 15))
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(accentColor)
        }
    }
}

struct StepperRow: View {
    let label: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 0...99
    var step: Int = 1
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
            Spacer()
            Stepper("\(value)", value: $value, in: range, step: step)
                .fixedSize()
        }
    }
}

struct SliderRow: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label).font(.system(size: 15))
                Spacer()
                Text(String(format: "%.1f\(unit)", value))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            Slider(value: $value, in: range, step: step)
                .tint(Color(red: 0.4, green: 0.75, blue: 0.55))
        }
    }
}

struct PickerRow<T: RawRepresentable & CaseIterable & Hashable & Codable>: View where T.RawValue == String {
    let label: String
    @Binding var selection: T
    var body: some View {
        HStack {
            Text(label).font(.system(size: 15))
            Spacer()
            Picker(label, selection: $selection) {
                ForEach(Array(T.allCases) as! [T], id: \.self) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }
}

struct TextFieldRow: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct AlertBanner: View {
    let message: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 13))
            Text(message)
                .font(.system(size: 12))
                .foregroundColor(.orange)
        }
        .padding(10)
        .background(Color.orange.opacity(0.08))
        .cornerRadius(10)
    }
}

struct EnergySlider: View {
    @Binding var value: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Nível de energia")
                    .font(.system(size: 15))
                Spacer()
                Text("\(value)/10")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(energyColor)
            }
            HStack(spacing: 6) {
                ForEach(1...10, id: \.self) { i in
                    Button {
                        value = i
                    } label: {
                        Circle()
                            .fill(i <= value ? energyColor : Color.gray.opacity(0.2))
                            .frame(height: 28)
                    }
                }
            }
            HStack {
                Text("😴 Sem energia").font(.system(size: 10)).foregroundColor(.secondary)
                Spacer()
                Text("Energia total ⚡️").font(.system(size: 10)).foregroundColor(.secondary)
            }
        }
    }
    var energyColor: Color {
        if value >= 7 { return .green }
        if value >= 4 { return .orange }
        return .red
    }
}

struct AnxietySelector: View {
    @Binding var value: Int
    private let labels = ["", "Calmo 😌", "Leve 😊", "Moderado 😐", "Alto 😟", "Muito alto 😰"]
    private let colors: [Color] = [.clear, .green, .yellow, .orange, .red, .purple]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nível de ansiedade/estresse")
                .font(.system(size: 15))
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Button {
                        value = i
                    } label: {
                        Text("\(i)")
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(i == value ? colors[i] : colors[i].opacity(0.15))
                            .foregroundColor(i == value ? .white : colors[i])
                            .cornerRadius(10)
                    }
                }
            }
            if value > 0 {
                Text(labels[value])
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TurnToggle: View {
    let turn: DayTurn
    @Binding var selected: [DayTurn]
    var isSelected: Bool { selected.contains(turn) }
    var body: some View {
        Button {
            if isSelected { selected.removeAll { $0 == turn } }
            else { selected.append(turn) }
        } label: {
            VStack(spacing: 2) {
                Text(turn.icon).font(.system(size: 16))
                Text(turn.rawValue).font(.system(size: 10))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.orange.opacity(0.2) : Color.gray.opacity(0.08))
            .foregroundColor(isSelected ? .orange : .secondary)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(isSelected ? Color.orange : Color.clear, lineWidth: 1.5))
        }
    }
}

struct MedicationList: View {
    @Binding var medications: [String]
    @State private var newMed = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(medications.indices, id: \.self) { i in
                HStack {
                    Image(systemName: "pill.fill").foregroundColor(.blue).font(.system(size: 12))
                    Text(medications[i]).font(.system(size: 14))
                    Spacer()
                    Button { medications.remove(at: i) } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.red.opacity(0.6))
                    }
                }
            }
            HStack {
                TextField("Adicionar medicamento...", text: $newMed)
                    .font(.system(size: 14))
                    .textFieldStyle(.roundedBorder)
                Button {
                    if !newMed.isEmpty {
                        medications.append(newMed)
                        newMed = ""
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(red: 0.4, green: 0.75, blue: 0.55))
                        .font(.system(size: 22))
                }
            }
        }
    }
}
