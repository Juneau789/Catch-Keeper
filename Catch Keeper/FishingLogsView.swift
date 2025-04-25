import SwiftUI
import CoreData

struct FishingLogsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FishingLog.catchDate, ascending: false)],
        animation: .default)
    private var fishingLogs: FetchedResults<FishingLog>
    
    @State private var selectedSortOption = 0
    @State private var searchText = ""
    
    let sortOptions = ["Date", "Species", "Weight"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Sort Controls
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
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
                        ForEach(fishingLogs) { log in
                            FishingLogCard(log: log)
                                .padding(.horizontal)
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
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.7))
            
            TextField("Search logs", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .placeholder(when: text.isEmpty) {
                    Text("Search logs")
                        .foregroundColor(.white.opacity(0.7))
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}

struct FishingLogCard: View {
    let log: FishingLog
    
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

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct FishingLogsView_Previews: PreviewProvider {
    static var previews: some View {
        FishingLogsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 