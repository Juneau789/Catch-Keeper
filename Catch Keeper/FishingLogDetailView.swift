//
//  FishingLogDetailView.swift
//  Catch Keeper
//
//  Created by Harrison Juneau on 4/25/25.
//

import SwiftUI
import CoreData

struct FishingLogDetailView: View {
    let log: FishingLog
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background color based on system appearance
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Photo section
                    if let photoData = log.photoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.black.opacity(0.3),
                                        Color.clear
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    } else {
                        // Placeholder image when no photo is available
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    // Details section
                    VStack(alignment: .leading, spacing: 20) {
                        // Species and Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text(log.fishSpecies ?? "Unknown Species")
                                .font(.system(size: 32, weight: .bold))
                            
                            Text(log.catchDate ?? Date(), style: .date)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Measurements
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
                        
                        // Location
                        if let location = log.locationName, !location.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Location")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(location)
                                    .font(.title3)
                            }
                        }
                        
                        // Gear
                        if let rod = log.rodUsed, !rod.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Gear Used")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(rod) with \(log.reelUsed ?? "")")
                                    .font(.title3)
                            }
                        }
                        
                        // Bait
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
            }
            .ignoresSafeArea(edges: .top)
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
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
