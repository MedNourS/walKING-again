import SwiftUI

enum UnitSystem: String, CaseIterable, Identifiable {
    case metric = "Metric"
    case imperial = "Imperial"
    var id: String { self.rawValue }
}

struct SettingsView: View {
    @AppStorage("unitSystem") private var unitSystem: String = UnitSystem.metric.rawValue

    var body: some View {
        Form {
            Section(header: Text("Units")) {
                Picker("Unit System", selection: $unitSystem) {
                    ForEach(UnitSystem.allCases) { unit in
                        Text(unit.rawValue).tag(unit.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}