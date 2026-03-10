import SwiftUI

struct PetsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddPet = false
    @State private var petToEdit: Pet? = nil
    @State private var petToDelete: Pet? = nil
    @State private var showDeleteConfirm = false

    private let accentGreen = Color(red: 0.4, green: 0.75, blue: 0.55)
    private let softBG = Color(red: 0.97, green: 0.97, blue: 0.95)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if appState.pets.isEmpty {
                        VStack(spacing: 16) {
                            Text("🐾").font(.system(size: 60))
                            Text("Nenhum pet cadastrado").font(.system(size: 18, weight: .bold, design: .rounded))
                            Text("Adicione seu primeiro pet para começar!").font(.system(size: 14)).foregroundColor(.secondary)
                        }
                        .padding(40)
                    } else {
                        ForEach(appState.pets) { pet in
                            PetCard(pet: pet, isSelected: appState.selectedPetId == pet.id) {
                                appState.selectedPetId = pet.id
                            } onEdit: {
                                petToEdit = pet
                            } onDelete: {
                                petToDelete = pet
                                showDeleteConfirm = true
                            }
                        }
                    }
                }
                .padding()
            }
            .background(softBG.ignoresSafeArea())
            .navigationTitle("Meus Pets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddPet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(accentGreen)
                    }
                }
            }
            .sheet(isPresented: $showAddPet) {
                AddEditPetView(pet: nil)
            }
            .sheet(item: $petToEdit) { pet in
                AddEditPetView(pet: pet)
            }
            .alert("Excluir \(petToDelete?.name ?? "pet")?", isPresented: $showDeleteConfirm) {
                Button("Excluir", role: .destructive) {
                    if let p = petToDelete { appState.deletePet(p) }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Todos os registros de saúde também serão excluídos.")
            }
        }
    }
}

// MARK: - Pet Card
struct PetCard: View {
    let pet: Pet
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    private let accentGreen = Color(red: 0.4, green: 0.75, blue: 0.55)

    var ageString: String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: pet.birthDate, to: Date())
        let years = comps.year ?? 0
        let months = comps.month ?? 0
        if years == 0 { return "\(months) meses" }
        if months == 0 { return "\(years) ano\(years > 1 ? "s" : "")" }
        return "\(years)a \(months)m"
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                // Pet icon/avatar
                ZStack {
                    Circle()
                        .fill(isSelected ? accentGreen.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 68, height: 68)
                    Text(pet.type.icon)
                        .font(.system(size: 36))
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(pet.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        if isSelected {
                            Text("Ativo")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(accentGreen)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    Text("\(pet.type.rawValue) • \(pet.breed)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    HStack(spacing: 14) {
                        Label(ageString, systemImage: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Label(String(format: "%.1f kg", pet.weight), systemImage: "scalemass")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Menu {
                    Button { onSelect() } label: {
                        Label("Selecionar", systemImage: "checkmark.circle")
                    }
                    Button { onEdit() } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    Divider()
                    Button(role: .destructive) { onDelete() } label: {
                        Label("Excluir", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.secondary.opacity(0.6))
                }
            }

            // Stats strip
            let petLogs = AppState.shared.logsForPet(pet.id)
            if !petLogs.isEmpty {
                Divider()
                HStack {
                    statPill(icon: "📋", label: "Registros", value: "\(petLogs.count)")
                    Divider().frame(height: 30)
                    let avgH = petLogs.map { $0.healthScore }.reduce(0, +) / Double(petLogs.count)
                    statPill(icon: "❤️", label: "Saúde méd.", value: "\(Int(avgH * 100))%")
                    Divider().frame(height: 30)
                    statPill(icon: "📅", label: "Último reg.", value: lastLogDate(petLogs))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(isSelected ? accentGreen.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .onTapGesture { onSelect() }
    }

    func statPill(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(icon).font(.system(size: 14))
            Text(value).font(.system(size: 12, weight: .bold)).foregroundColor(.primary)
            Text(label).font(.system(size: 10)).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    func lastLogDate(_ logs: [DailyLog]) -> String {
        guard let last = logs.first else { return "—" }
        let cal = Calendar.current
        if cal.isDateInToday(last.date) { return "Hoje" }
        if cal.isDateInYesterday(last.date) { return "Ontem" }
        let f = DateFormatter()
        f.dateFormat = "dd/MM"
        return f.string(from: last.date)
    }
}

// MARK: - Add/Edit Pet
struct AddEditPetView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let existingPet: Pet?
    
    @State private var name: String = ""
    @State private var type: Pet.PetType = .dog
    @State private var breed: String = ""
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
    @State private var weight: Double = 5.0
    @State private var color: String = ""

    private let accentGreen = Color(red: 0.4, green: 0.75, blue: 0.55)

    init(pet: Pet?) {
        self.existingPet = pet
        if let p = pet {
            _name = State(initialValue: p.name)
            _type = State(initialValue: p.type)
            _breed = State(initialValue: p.breed)
            _birthDate = State(initialValue: p.birthDate)
            _weight = State(initialValue: p.weight)
            _color = State(initialValue: p.color)
        }
    }

    var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Informações básicas") {
                    HStack {
                        Text("Nome")
                        Spacer()
                        TextField("Nome do pet", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Tipo", selection: $type) {
                        ForEach(Pet.PetType.allCases, id: \.self) { t in
                            Text("\(t.icon) \(t.rawValue)").tag(t)
                        }
                    }
                    HStack {
                        Text("Raça")
                        Spacer()
                        TextField("Ex: Golden Retriever, SRD...", text: $breed)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Cor do pelo")
                        Spacer()
                        TextField("Ex: Dourado, Preto e branco...", text: $color)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Dados físicos") {
                    DatePicker("Data de nascimento", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                    HStack {
                        Text("Peso (kg)")
                        Spacer()
                        Stepper(String(format: "%.1f kg", weight), value: $weight, in: 0.1...150, step: 0.1)
                            .fixedSize()
                    }
                }
            }
            .navigationTitle(existingPet == nil ? "Novo Pet" : "Editar Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        savePet()
                        dismiss()
                    }
                    .disabled(!isValid)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isValid ? accentGreen : .gray)
                }
            }
        }
    }

    func savePet() {
        if var pet = existingPet {
            pet.name = name
            pet.type = type
            pet.breed = breed
            pet.birthDate = birthDate
            pet.weight = weight
            pet.color = color
            appState.updatePet(pet)
        } else {
            let newPet = Pet(name: name, type: type, breed: breed, birthDate: birthDate, weight: weight, color: color)
            appState.addPet(newPet)
        }
    }
}
