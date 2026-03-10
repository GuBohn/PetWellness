# 🐾 PetSaúde — App de Bem-Estar para Pets

App iOS nativo em SwiftUI para acompanhamento diário de saúde de cães e gatos.

## 📁 Arquivos do projeto

| Arquivo | Descrição |
|---|---|
| `PetWellnessApp.swift` | Entry point do app (`@main`) |
| `Models.swift` | Todos os modelos de dados, enums e AppState |
| `ContentView.swift` | TabView raiz com navegação principal |
| `HomeView.swift` | Tela inicial com resumo do dia |
| `LogFormView.swift` | Formulário completo de registro diário |
| `HistoryView.swift` | Grid/lista de histórico + detalhes |
| `InsightsView.swift` | Análises e gráficos de tendências |
| `PetsView.swift` | Gerenciamento de pets |

---

## 🚀 Como abrir no Xcode

### Opção A — Criar projeto e adicionar arquivos
1. Abra o **Xcode** → New Project → iOS → **App**
2. Nome: `PetWellness`
3. Interface: **SwiftUI**, Language: **Swift**
4. Salve o projeto
5. **Delete** o `ContentView.swift` gerado automaticamente
6. Arraste todos os arquivos `.swift` desta pasta para dentro do projeto no Xcode
7. Marque **"Add to target: PetWellness"** para todos

### Opção B — Adicionar manualmente
1. No Xcode, clique com botão direito na pasta do projeto
2. Selecione **"Add Files to..."**
3. Selecione todos os arquivos `.swift` desta pasta

---

## 📱 Funcionalidades

### Tela Hoje
- Score de saúde calculado automaticamente (0–100%)
- Emoji e cor indicando estado geral
- Alertas automáticos para sintomas preocupantes
- Grid de métricas rápidas

### Registro Diário (5 seções)

#### 🚽 Eliminação
- Fez cocô? Quantidade, cor (8 opções) e consistência (5 opções)
- Fez xixi? Quantidade, cor (6 opções) e frequência
- Alertas automáticos para cores fora do padrão

#### 🍽️ Alimentação
- Porção da ração comida (5 níveis)
- Ingestão de água
- Alimento diferente/incomum (com descrição)

#### 🎾 Comportamento
- Nível de energia: escala visual 1–10
- Nível de ansiedade/estresse: 1–5
- Brincou? Duração em minutos
- Horas de sono (slider)
- Vocalização excessiva (latido/miado)
- Interação com pessoas/animais
- Comportamento agressivo/arisco

#### 🏥 Saúde
- Vômito: quantidade, turno (madrugada/manhã/tarde/noite)
- Machucados novos com descrição
- Secreções (localização e cor/aspecto)
- Olhos, orelhas e pelagem
- Espirros ou tosse
- Coçar/lamber excessivo

#### 📝 Extras
- Lista de medicamentos tomados
- Registro de peso
- Notas livres

### 📅 Histórico
- **Grid 3x3** com emoji de saúde + barra de progresso por dia
- **Lista** com detalhes rápidos + chips de alerta
- Filtro por mês
- Detalhes completos de cada dia
- Editar ou excluir registros

### 📊 Análises
- Saúde média, energia média, dias brincando, sono médio
- Vômitos e dias de alerta
- Gráfico de barras de saúde e energia (últimos 14 dias)
- Padrões: cocô anormal, xixi anormal, fome, vômito, agressividade
- Filtros: 7 dias, 30 dias, todos

### 🐾 Pets
- Suporte a múltiplos pets
- Cadastro completo: nome, tipo, raça, cor do pelo, peso, data nascimento
- Card com estatísticas rápidas
- Indicador do pet ativo

---

## 💾 Persistência
- UserDefaults com Codable
- Dados persistem entre sessões
- Dados de exemplo (Thor e Luna) na primeira execução

---

## 🎨 Design
- Paleta verde suave (#66BF8C) como cor principal
- Fundo creme (#F7F7F2) para conforto visual
- Cards brancos com sombras sutis
- SF Symbols para ícones
- Emojis para contexto visual imediato
- Design arredondado e amigável

---

## 🔮 Próximos passos sugeridos
- Notificações locais para lembrar o registro diário
- Exportar relatório para o veterinário (PDF)
- Agenda de vacinas e vermífugos
- Fotos do pet no registro
- CloudKit para sincronização entre dispositivos
- Widget para iOS com status rápido
- Apple Watch companion app
