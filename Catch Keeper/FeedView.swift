import SwiftUI
import CoreData
import FirebaseAuth
import FirebaseFirestore

struct FeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FishingLog.catchDate, ascending: false)],
        animation: .default)
    private var fishingLogs: FetchedResults<FishingLog>
    
    @State private var userProfile: UserProfile? = nil
    @State private var isShowingAddCatchView = false
    @State private var isLoadingProfile = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Profile header
                    if let profile = userProfile {
                        HStack(spacing: 16) {
                            if let url = profile.profilePicUrl, let imageUrl = URL(string: url) {
                                AsyncImage(url: imageUrl) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else {
                                        Circle().fill(Color.white.opacity(0.2))
                                    }
                                }
                                .frame(width: 56, height: 56)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 4)
                            } else {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 56, height: 56)
                                    .overlay(Image(systemName: "person.crop.circle.fill").font(.system(size: 32)).foregroundColor(.white))
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.username)
                                    .font(.title2).bold().foregroundColor(.white)
                                if let bio = profile.bio, !bio.isEmpty {
                                    Text(bio).font(.subheadline).foregroundColor(.white.opacity(0.8))
                                }
                            }
                            Spacer()
                            NavigationLink(destination: ProfileView()) {
                                Image(systemName: "person.crop.circle")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.7))
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.5), Color(red: 0.2, green: 0.6, blue: 0.7)]),
                                startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    } else if isLoadingProfile {
                        HStack { ProgressView().padding(); Spacer() }
                    } else if let error = errorMessage {
                        Text(error).foregroundColor(.red).padding()
                    }
                    // Feed
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(fishingLogs) { log in
                                FishingLogsView.FishingLogCard(log: log)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                        .background(Color(.systemGroupedBackground))
                    }
                }
                // Floating add button
                Button(action: { isShowingAddCatchView = true }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                        .padding()
                }
                .sheet(isPresented: $isShowingAddCatchView) {
                    AddCatchView()
                }
            }
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.5), Color(.systemGroupedBackground)]),
                    startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .onAppear(perform: loadUserProfile)
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
}

struct UserProfile {
    let username: String
    let bio: String?
    let profilePicUrl: String?
} 