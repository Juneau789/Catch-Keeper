import SwiftUI
import CoreData
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FishingLog.catchDate, ascending: false)],
        animation: .default)
    private var fishingLogs: FetchedResults<FishingLog>
    
    @State private var userProfile: UserProfile? = nil
    @State private var isLoadingProfile = true
    @State private var errorMessage: String? = nil
    @State private var selectedLog: FishingLog? = nil
    @State private var isShowingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Profile header
                    if let profile = userProfile {
                        VStack(spacing: 0) {
                            ZStack(alignment: .topTrailing) {
                                HStack(alignment: .center, spacing: 16) {
                                    // Profile picture on the left
                                    if let url = profile.profilePicUrl, let imageUrl = URL(string: url) {
                                        AsyncImage(url: imageUrl) { phase in
                                            if let image = phase.image {
                                                image.resizable().scaledToFill()
                                            } else {
                                                Circle().fill(Color.white.opacity(0.2))
                                            }
                                        }
                                        .frame(width: 72, height: 72)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                        .shadow(radius: 8)
                                    } else {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 72, height: 72)
                                            .overlay(Image(systemName: "person.crop.circle.fill").font(.system(size: 40)).foregroundColor(.white))
                                    }
                                    // Username to the right of the profile pic
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(profile.username)
                                            .font(.title).bold().foregroundColor(.white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        // Space for future stats or info
                                    }
                                    Spacer()
                                }
                                .padding(.top, 32)
                                .padding(.horizontal)
                                // Gear icon button in the top right
                                Button(action: { isShowingSettings = true }) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.blue.opacity(0.8))
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding(.top, 24)
                                .padding(.trailing, 24)
                            }
                            .frame(maxWidth: .infinity)
                            // Bio
                            if let bio = profile.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.top, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            // Showcase row
                            HStack(spacing: 20) {
                                ForEach(0..<4) { i in
                                    VStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.15))
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                Image(systemName: showcaseIcon(for: i))
                                                    .font(.title2)
                                                    .foregroundColor(.blue)
                                            )
                                        Text(showcaseLabel(for: i))
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)
                            .padding(.bottom, 20)
                        }
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.5), Color(red: 0.2, green: 0.6, blue: 0.7)]),
                                startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    } else if isLoadingProfile {
                        ProgressView().padding()
                    } else if let error = errorMessage {
                        Text(error).foregroundColor(.red).padding()
                    }
                    // Catches grid
                    Text("My Catches")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(fishingLogs) { log in
                            FishingLogsView.FishingLogGridCard(log: log)
                                .aspectRatio(1, contentMode: .fit)
                                .onTapGesture {
                                    selectedLog = log
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGroupedBackground), Color(red: 0.1, green: 0.3, blue: 0.5).opacity(0.2)]),
                    startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Profile")
            .onAppear(perform: loadUserProfile)
            .fullScreenCover(item: $selectedLog) { log in
                FishingLogDetailView(log: log)
            }
            .sheet(isPresented: $isShowingSettings) {
                if let profile = userProfile {
                    ProfileSettingsView(
                        username: profile.username,
                        bio: profile.bio ?? "",
                        isPrivate: false // TODO: fetch real privacy value
                    )
                }
            }
        }
    }
    
    private func loadUserProfile() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "Not signed in"; self.isLoadingProfile = false; return
        }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { doc, err in
            DispatchQueue.main.async {
                self.isLoadingProfile = false
                if let err = err {
                    self.errorMessage = "Failed to load profile: \(err.localizedDescription)"
                } else if let doc = doc, doc.exists, let data = doc.data() {
                    self.userProfile = UserProfile(
                        username: data["username"] as? String ?? "Unknown",
                        bio: data["bio"] as? String ?? "",
                        profilePicUrl: data["profilePicUrl"] as? String
                    )
                } else {
                    self.errorMessage = "Profile not found."
                }
            }
        }
    }
    
    // Add showcase helpers
    func showcaseIcon(for index: Int) -> String {
        // Placeholder icons for showcase
        switch index {
        case 0: return "star.fill" // Badge
        case 1: return "trophy.fill" // Trophy
        case 2: return "medal.fill" // Achievement
        case 3: return "crown.fill" // Special
        default: return "questionmark" }
    }
    
    func showcaseLabel(for index: Int) -> String {
        // Placeholder labels for showcase
        switch index {
        case 0: return "Badge"
        case 1: return "Trophy"
        case 2: return "Medal"
        case 3: return "Crown"
        default: return "?" }
    }
} 