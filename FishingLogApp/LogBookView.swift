//
//  LogBookView.swift
//  FishingLogApp
//
//  Created by Harrison Juneau on 8/15/24.
//

import SwiftUI

struct LogBookView: View {
    @State private var searchText = ""
    @State private var sortOption = "Date"
    
    // Sample data for testing, replace with actual data
    @State private var logEntries = [
        LogEntry(id: 1, species: "Trout", dateCaught: "May 5, 2023"),
        LogEntry(id: 2, species: "Bass", dateCaught: "June 10, 2023"),
        LogEntry(id: 3, species: "Catfish", dateCaught: "July 1, 2023")
    ]
    
    var body: some View {
        VStack {
            // Search Bar at the top
            SearchBar(text: $searchText)

            // Sort options in the top-right corner
            HStack {
                Spacer()
                Menu {
                    Button("Sort by Date") { sortOption = "Date" }
                    Button("Sort by Species") { sortOption = "Species" }
                } label: {
                    Text("Sort")
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            
            // Paging view for the logbook
            TabView {
                ForEach(filteredLogEntries(), id: \.id) { entry in
                    VStack {
                        Text(entry.species)
                            .font(.title)
                            .padding()
                        Text(entry.dateCaught)
                            .font(.subheadline)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                }
            }
            .tabViewStyle(PageTabViewStyle())  // Enables the page-flipping style
            .padding()
        }
        .navigationTitle("Fishing Log")
    }
    
    // Filter log entries based on search input
    func filteredLogEntries() -> [LogEntry] {
        let filtered = logEntries.filter { entry in
            entry.species.lowercased().contains(searchText.lowercased()) ||
            entry.dateCaught.lowercased().contains(searchText.lowercased())
        }
        
        if sortOption == "Species" {
            return filtered.sorted { $0.species < $1.species }
        } else {
            return filtered.sorted { $0.dateCaught < $1.dateCaught }
        }
    }
}

// Sample data model for log entry
struct LogEntry: Identifiable {
    let id: Int
    let species: String
    let dateCaught: String
}

#Preview {
    LogBookView()
}

