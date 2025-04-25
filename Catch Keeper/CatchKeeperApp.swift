import SwiftUI
import CoreData

@main
struct CatchKeeperApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class PersistenceController {
    static let shared = PersistenceController()
    static let preview = PersistenceController(inMemory: true)
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "CatchKeeper")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        if inMemory {
            addSampleData()
        }
    }
    
    private func addSampleData() {
        let viewContext = container.viewContext
        
        // Add sample fishing logs
        let log1 = FishingLog(context: viewContext)
        log1.id = UUID()
        log1.timestamp = Date()
        log1.catchDate = Date()
        log1.fishSpecies = "Bass"
        log1.fishWeight = 5.5
        log1.fishLength = 18.0
        log1.locationName = "Lake Michigan"
        log1.rodUsed = "Ugly Stik"
        log1.reelUsed = "Shimano"
        log1.baitUsed = "Worm"
        
        let log2 = FishingLog(context: viewContext)
        log2.id = UUID()
        log2.timestamp = Date()
        log2.catchDate = Date().addingTimeInterval(-86400) // Yesterday
        log2.fishSpecies = "Trout"
        log2.fishWeight = 3.2
        log2.fishLength = 15.0
        log2.locationName = "Local River"
        log2.rodUsed = "Fenwick"
        log2.reelUsed = "Penn"
        log2.baitUsed = "PowerBait"
        
        let log3 = FishingLog(context: viewContext)
        log3.id = UUID()
        log3.timestamp = Date()
        log3.catchDate = Date().addingTimeInterval(-172800) // Two days ago
        log3.fishSpecies = "Walleye"
        log3.fishWeight = 4.8
        log3.fishLength = 22.0
        log3.locationName = "Lake Superior"
        log3.rodUsed = "St. Croix"
        log3.reelUsed = "Daiwa"
        log3.baitUsed = "Minnow"
        
        // Add sample achievements
        let achievement1 = Achievement(context: viewContext)
        achievement1.id = UUID()
        achievement1.title = "5 Pound Club"
        achievement1.achievementType = "weight"
        achievement1.targetValue = 5.0
        achievement1.progress = 5.5
        achievement1.completed = true
        
        let achievement2 = Achievement(context: viewContext)
        achievement2.id = UUID()
        achievement2.title = "Species Collector"
        achievement2.achievementType = "species"
        achievement2.targetValue = 5.0
        achievement2.progress = 2.0
        achievement2.completed = false
        
        try? viewContext.save()
    }
} 