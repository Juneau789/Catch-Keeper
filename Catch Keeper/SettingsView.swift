import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("useMetricSystem") private var useMetricSystem = false
    @AppStorage("syncWithiCloud") private var syncWithiCloud = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Units")) {
                    Toggle("Use Metric System", isOn: $useMetricSystem)
                }
                
                Section(header: Text("iCloud Sync")) {
                    Toggle("Sync with iCloud", isOn: $syncWithiCloud)
                    Text("Your fishing logs will be synced across all your devices")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://en.wikipedia.org/wiki/List_of_fish_species") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("Fish Species Reference")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 