import SwiftUI
import CoreData

struct AchievementsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Achievement.title, ascending: true)],
        animation: .default)
    private var achievements: FetchedResults<Achievement>
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding()
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Achievements")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
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
            .onAppear {
                checkAndUpdateAchievements()
            }
        }
    }
    
    private func checkAndUpdateAchievements() {
        let fetchRequest: NSFetchRequest<FishingLog> = NSFetchRequest<FishingLog>(entityName: "FishingLog")
        
        do {
            let logs = try viewContext.fetch(fetchRequest)
            
            // Check for weight achievements
            let maxWeight = logs.map { $0.fishWeight }.max() ?? 0
            updateWeightAchievements(maxWeight: maxWeight)
            
            // Check for species achievements
            let uniqueSpecies = Set(logs.compactMap { $0.fishSpecies })
            updateSpeciesAchievements(uniqueSpeciesCount: uniqueSpecies.count)
            
            try viewContext.save()
        } catch {
            print("Error checking achievements: \(error)")
        }
    }
    
    private func updateWeightAchievements(maxWeight: Double) {
        let weightAchievements = [
            (5.0, "5 Pound Club"),
            (10.0, "10 Pound Club"),
            (20.0, "20 Pound Club")
        ]
        
        for (weight, title) in weightAchievements {
            if let achievement = achievements.first(where: { $0.title == title }) {
                achievement.progress = maxWeight
                achievement.completed = maxWeight >= weight
            } else {
                let newAchievement = Achievement(context: viewContext)
                newAchievement.id = UUID()
                newAchievement.title = title
                newAchievement.achievementType = "weight"
                newAchievement.targetValue = weight
                newAchievement.progress = maxWeight
                newAchievement.completed = maxWeight >= weight
            }
        }
    }
    
    private func updateSpeciesAchievements(uniqueSpeciesCount: Int) {
        let speciesAchievements = [
            (5, "Species Collector"),
            (10, "Species Master"),
            (20, "Species Legend")
        ]
        
        for (count, title) in speciesAchievements {
            if let achievement = achievements.first(where: { $0.title == title }) {
                achievement.progress = Double(uniqueSpeciesCount)
                achievement.completed = uniqueSpeciesCount >= count
            } else {
                let newAchievement = Achievement(context: viewContext)
                newAchievement.id = UUID()
                newAchievement.title = title
                newAchievement.achievementType = "species"
                newAchievement.targetValue = Double(count)
                newAchievement.progress = Double(uniqueSpeciesCount)
                newAchievement.completed = uniqueSpeciesCount >= count
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.title ?? "")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Progress: \(Int(achievement.progress))/\(Int(achievement.targetValue))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if achievement.completed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(red: 0.1, green: 0.7, blue: 0.3))
                        .font(.title2)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    achievement.completed ? Color(red: 0.1, green: 0.7, blue: 0.3) : Color(red: 0.1, green: 0.3, blue: 0.5),
                                    achievement.completed ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color(red: 0.2, green: 0.4, blue: 0.6)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: min(CGFloat(achievement.progress / achievement.targetValue) * geometry.size.width, geometry.size.width), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 