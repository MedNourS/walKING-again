//
//  ContentView.swift
//  walKING
//
//  Created by Chariot 4 - Ordinateur19 - User3 on 2025-06-11.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            StatisticsView(viewModel: MapViewModel())
                .tabItem {			
                    Image(systemName: "chart.bar")
                    Text("Statistics")
                }
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView()
}
