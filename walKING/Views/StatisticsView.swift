import SwiftUI
import CoreLocation

struct StatisticsView: View {
    @ObservedObject var viewModel: MapViewModel
    @State private var selectedDate: Date = Date()
    @AppStorage("unitSystem") private var unitSystem: String = UnitSystem.metric.rawValue

    // Helper to group cells by day (key: "yyyy-MM-dd")
    private var cellsDiscoveredByDay: [String: Set<GridCell>] {
        var result: [String: Set<GridCell>] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for (cell, visits) in viewModel.cellVisitHistory {
            for date in visits {
                let day = formatter.string(from: date)
                result[day, default: []].insert(cell)
            }
        }
        return result
    }

    // Helper to group visits by day (for distance, steps, calories)
    private var visitsByDay: [String: [GridCell: [Date]]] {
        var result: [String: [GridCell: [Date]]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for (cell, visits) in viewModel.cellVisitHistory {
            for date in visits {
                let day = formatter.string(from: date)
                result[day, default: [:]][cell, default: []].append(date)
            }
        }
        return result
    }

    // Formatter for display
    private var displayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    // Cells for selected day
    private var selectedDayCells: Set<GridCell> {
        let key = dayKey(for: selectedDate)
        return cellsDiscoveredByDay[key] ?? []
    }

    // Visits for selected day
    private var selectedDayVisits: [GridCell: [Date]] {
        let key = dayKey(for: selectedDate)
        return visitsByDay[key] ?? [:]
    }

    // Helper to get key for a date
    private func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // Calculate distance traveled for the selected day (approximate, based on cell centers)
    private var selectedDayDistance: Double {
        let cellSizeDegrees = viewModel.cellSize
        // Get cells and their earliest visit date for the selected day
        let cellDatePairs = selectedDayVisits.map { (cell, dates) in
            (cell, dates.min() ?? Date.distantPast)
        }.sorted { $0.1 < $1.1 }
        let cellCenters = cellDatePairs.map { (cell, _) -> CLLocation in
            guard let center = viewModel.center else { return CLLocation() }
            let lat = center.latitude + (Double(cell.x) * cellSizeDegrees)
            let lon = center.longitude + (Double(cell.y) * cellSizeDegrees)
            return CLLocation(latitude: lat, longitude: lon)
        }
        guard cellCenters.count > 1 else { return 0 }
        var distance: Double = 0
        for i in 1..<cellCenters.count {
            distance += cellCenters[i].distance(from: cellCenters[i-1])
        }
        return distance // in meters
    }

    // Estimate steps (average stride length: 0.78m)
    private var selectedDaySteps: Int {
        Int(selectedDayDistance / 0.78)
    }

    // Estimate calories burned (average walking: 0.05 kcal per meter)
    private var selectedDayCalories: Int {
        Int(selectedDayDistance * 0.05)
    }

    // Display distance in correct units
    private var formattedDistance: String {
        if unitSystem == UnitSystem.imperial.rawValue {
            let miles = selectedDayDistance / 1609.34
            return String(format: "%.2f miles", miles)
        } else {
            return String(format: "%.2f meters", selectedDayDistance)
        }
    }

    // Display steps (same for both units)
    private var formattedSteps: String {
        "\(selectedDaySteps)"
    }

    // Display calories (same for both units)
    private var formattedCalories: String {
        "\(selectedDayCalories)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Area Discovered Per Day")
                .font(.headline)

            // Calendar date picker
            DatePicker(
                "Select Day",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding(.bottom, 8)

            // Selected day stats
            GroupBox(label: Text("Stats for \(displayFormatter.string(from: selectedDate))")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cells discovered: \(selectedDayCells.count)")
                        .font(.subheadline)
                    Text("Distance: \(formattedDistance)")
                        .font(.subheadline)
                    Text("Steps: \(formattedSteps)")
                        .font(.subheadline)
                    Text("Calories: \(formattedCalories)")
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
            }

            // List of all days and their stats
            List {
                ForEach(cellsDiscoveredByDay.keys.sorted(), id: \.self) { day in
                    HStack {
                        Text(day)
                        Spacer()
                        Text("\(cellsDiscoveredByDay[day]?.count ?? 0) cells")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    StatisticsView(viewModel: MapViewModel())
}