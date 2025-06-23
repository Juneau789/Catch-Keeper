import SwiftUI
import CoreData

struct FishingLogsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FishingLog.catchDate, ascending: false)],
        animation: .default)
    private var fishingLogs: FetchedResults<FishingLog>
    
    @State private var selectedSortOption = 0
    @State private var selectedLog: FishingLog? = nil
    @State private var isShowingAddCatchView = false
    
    let sortOptions = ["Date", "Species", "Weight"]
    
    private var sortedLogs: [FishingLog] {
        let logs = Array(fishingLogs)
        switch selectedSortOption {
        case 0: // Date (newest to oldest)
            return logs.sorted { ($0.catchDate ?? Date()) > ($1.catchDate ?? Date()) }
        case 1: // Species (A-Z)
            return logs.sorted { ($0.fishSpecies ?? "") < ($1.fishSpecies ?? "") }
        case 2: // Weight (heaviest to lightest)
            return logs.sorted { $0.fishWeight > $1.fishWeight }
        default:
            return logs
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Only Sort Controls
                VStack(spacing: 12) {
                    Picker("Sort by", selection: $selectedSortOption) {
                        ForEach(0..<sortOptions.count, id: \.self) { index in
                            Text(sortOptions[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.1, green: 0.3, blue: 0.5),
                            Color(red: 0.2, green: 0.4, blue: 0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Logs List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(sortedLogs) { log in
                            FishingLogCard(log: log)
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedLog = log
                                    print("Selected log: \(log), species: \(log.fishSpecies ?? "nil")")
                                }
                        }
                        .padding(.vertical)
                    }
                    .background(Color(.systemGroupedBackground))
                }
                .navigationTitle("Fishing Logs")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Fishing Logs")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingAddCatchView = true
                        }) {
                            Image(systemName: "plus.circle")
                                .imageScale(.large)
                                .foregroundColor(Color.white)
                        }
                    }
                }
                .sheet(isPresented: $isShowingAddCatchView) {
                    AddCatchView()
                }
                .fullScreenCover(item: $selectedLog) { log in
                    let _ = print("Presenting detail view. log: \(log), species: \(log.fishSpecies ?? "nil")")
                    FishingLogDetailView(log: log)
                }
            }
        }
    }
    
    struct FishingLogCard: View {
        @ObservedObject var log: FishingLog
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if let photoData = log.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
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
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(log.fishSpecies ?? "Unknown Species")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(log.catchDate ?? Date(), style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("\(String(format: "%.2f", log.fishWeight)) lbs", systemImage: "scalemass")
                                .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.5))
                            Label("\(String(format: "%.2f", log.fishLength)) in", systemImage: "ruler")
                                .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.5))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(log.locationName ?? "Unknown Location")
                                .foregroundColor(.secondary)
                            if let rod = log.rodUsed, !rod.isEmpty {
                                Text("\(rod) with \(log.reelUsed ?? "")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if let bait = log.baitUsed, !bait.isEmpty {
                        HStack {
                            Image(systemName: "fish")
                                .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.5))
                            Text("Bait: \(bait)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    struct FishingLogGridCard: View {
        @ObservedObject var log: FishingLog
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if let photoData = log.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: nil, height: nil)
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundColor(.gray)
                        )
                }
                // Overlay with species and date
                VStack(alignment: .leading, spacing: 2) {
                    Text(log.fishSpecies ?? "Unknown")
                        .font(.caption2).bold().foregroundColor(.white)
                        .shadow(radius: 2)
                    Text(log.catchDate ?? Date(), style: .date)
                        .font(.caption2).foregroundColor(.white.opacity(0.8))
                        .shadow(radius: 2)
                }
                .padding(6)
                .background(Color.black.opacity(0.35))
                .cornerRadius(8)
                .padding(6)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
        }
    }
    
}

struct FishingLogsView_Previews: PreviewProvider {
    static var previews: some View {
        FishingLogsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

