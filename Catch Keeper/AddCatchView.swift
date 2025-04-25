import SwiftUI
import CoreData
import CoreLocation
import PhotosUI

struct AddCatchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var fishSpecies = ""
    @State private var fishWeight = ""
    @State private var fishLength = ""
    @State private var locationName = ""
    @State private var rodUsed = ""
    @State private var reelUsed = ""
    @State private var baitUsed = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
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
                    if let location = locationManager.location {
                        Text("Current Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    }
                    Button("Use Current Location") {
                        locationManager.requestLocation()
                    }
                }
                
                Section(header: Text("Gear Used")) {
                    TextField("Rod", text: $rodUsed)
                    TextField("Reel", text: $reelUsed)
                    TextField("Bait/Lure", text: $baitUsed)
                }
                
                Section(header: Text("Photo")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                    
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Select Photo", systemImage: "photo")
                    }
                }
            }
            .navigationTitle("Add Catch")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveCatch()
                }
            )
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImage = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    private func saveCatch() {
        withAnimation {
            let newCatch = FishingLog(context: viewContext)
            newCatch.id = UUID()
            newCatch.timestamp = Date()
            newCatch.catchDate = Date()
            newCatch.fishSpecies = fishSpecies
            newCatch.fishWeight = Double(fishWeight) ?? 0
            newCatch.fishLength = Double(fishLength) ?? 0
            newCatch.locationName = locationName
            newCatch.rodUsed = rodUsed
            newCatch.reelUsed = reelUsed
            newCatch.baitUsed = baitUsed
            
            if let location = locationManager.location {
                newCatch.latitude = location.coordinate.latitude
                newCatch.longitude = location.coordinate.longitude
            }
            
            if let image = selectedImage {
                newCatch.photoData = image.jpegData(compressionQuality: 0.8)
            }
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                print("Error saving catch: \(error)")
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}

struct AddCatchView_Previews: PreviewProvider {
    static var previews: some View {
        AddCatchView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 