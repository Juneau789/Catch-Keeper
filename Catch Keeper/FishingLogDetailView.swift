//
//  FishingLogDetailView.swift
//  Catch Keeper
//
//  Created by Harrison Juneau on 4/25/25.
//

import SwiftUI
import CoreData

struct FishingLogDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let log: FishingLog
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isPresentingEdit = false
    @State private var isPresentingDeleteAlert = false
    @State private var isDeleted = false
    
    var body: some View {
        let _ = print("Detail view for log: \(log), species: \(log.fishSpecies ?? "nil")")
        if isDeleted {
            Color.clear.onAppear { dismiss() }
        } else {
            ZStack {
                (colorScheme == .dark ? Color.black : Color.white)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top bar with close, edit, and delete
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Button(action: { isPresentingEdit = true }) {
                            Image(systemName: "pencil")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.blue.opacity(0.7))
                                .clipShape(Circle())
                        }
                        Button(action: { isPresentingDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.red.opacity(0.7))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            // Photo section
                            if let photoData = log.photoData,
                               let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(16)
                                    .padding(.top, 16)
                                    .padding(.horizontal)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 200)
                                    .cornerRadius(16)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray)
                                    )
                                    .padding(.top, 16)
                                    .padding(.horizontal)
                            }
                            
                            // Details section
                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(log.fishSpecies ?? "Unknown Species")
                                        .font(.system(size: 32, weight: .bold))
                                    Text(log.catchDate ?? Date(), style: .date)
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.top, 20)
                                
                                HStack(spacing: 30) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Weight")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("\(String(format: "%.2f", log.fishWeight)) lbs")
                                            .font(.title2)
                                            .bold()
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Length")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("\(String(format: "%.2f", log.fishLength)) in")
                                            .font(.title2)
                                            .bold()
                                    }
                                }
                                .padding(.vertical, 10)
                                
                                if let location = log.locationName, !location.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Location")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(location)
                                            .font(.title3)
                                    }
                                }
                                if let rod = log.rodUsed, !rod.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Gear Used")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("\(rod) with \(log.reelUsed ?? "")")
                                            .font(.title3)
                                    }
                                }
                                if let bait = log.baitUsed, !bait.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Bait Used")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(bait)
                                            .font(.title3)
                                    }
                                }
                            }
                            .padding()
                        }
                        .padding(.bottom, 32)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .background((colorScheme == .dark ? Color.black : Color.white))
                .cornerRadius(0)
                .sheet(isPresented: $isPresentingEdit) {
                    EditCatchView(log: log) { updatedLog in
                        // No-op, handled in EditCatchView
                    }
                    .environment(\.managedObjectContext, viewContext)
                }
                .alert("Delete Entry?", isPresented: $isPresentingDeleteAlert, actions: {
                    Button("Delete", role: .destructive) { deleteLog() }
                    Button("Cancel", role: .cancel) { }
                }, message: {
                    Text("Are you sure you want to delete this log entry? This action cannot be undone.")
                })
            }
        }
    }
    
    private func deleteLog() {
        viewContext.delete(log)
        do {
            try viewContext.save()
            isDeleted = true
        } catch {
            print("Failed to delete log: \(error)")
        }
    }
}

struct EditCatchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var log: FishingLog
    var onSave: ((FishingLog) -> Void)? = nil
    
    @State private var fishSpecies: String = ""
    @State private var fishWeight: String = ""
    @State private var fishLength: String = ""
    @State private var locationName: String = ""
    @State private var rodUsed: String = ""
    @State private var reelUsed: String = ""
    @State private var baitUsed: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Fish Details")) {
                    TextField("Species", text: $fishSpecies)
                    TextField("Weight (lbs)", text: $fishWeight)
                        .keyboardType(.decimalPad)
                    TextField("Length (inches)", text: $fishLength)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Location")) {
                    TextField("Location Name", text: $locationName)
                }
                Section(header: Text("Gear Used")) {
                    TextField("Rod", text: $rodUsed)
                    TextField("Reel", text: $reelUsed)
                    TextField("Bait/Lure", text: $baitUsed)
                }
            }
            .navigationTitle("Edit Log Entry")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveChanges() }
            )
            .onAppear {
                fishSpecies = log.fishSpecies ?? ""
                fishWeight = log.fishWeight == 0 ? "" : String(log.fishWeight)
                fishLength = log.fishLength == 0 ? "" : String(log.fishLength)
                locationName = log.locationName ?? ""
                rodUsed = log.rodUsed ?? ""
                reelUsed = log.reelUsed ?? ""
                baitUsed = log.baitUsed ?? ""
            }
        }
    }
    
    private func saveChanges() {
        log.fishSpecies = fishSpecies
        log.fishWeight = Double(fishWeight) ?? 0
        log.fishLength = Double(fishLength) ?? 0
        log.locationName = locationName
        log.rodUsed = rodUsed
        log.reelUsed = reelUsed
        log.baitUsed = baitUsed
        do {
            try viewContext.save()
            onSave?(log)
            dismiss()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}

struct FishingLogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let log = FishingLog(context: context)
        log.id = UUID()
        log.timestamp = Date()
        log.catchDate = Date()
        log.fishSpecies = "Bass"
        log.fishWeight = 5.5
        log.fishLength = 18.0
        log.locationName = "Lake Michigan"
        log.rodUsed = "Ugly Stik"
        log.reelUsed = "Shimano"
        log.baitUsed = "Worm"
        
        return FishingLogDetailView(log: log)
            .environment(\.managedObjectContext, context)
    }
}
