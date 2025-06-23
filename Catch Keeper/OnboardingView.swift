import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// Initialize Firebase Storage with your correct bucket
let storage = Storage.storage(url: "gs://catch-keeper-4df3a.appspot.com")

struct OnboardingView: View {
    @State private var username = ""
    @State private var bio = ""
    @State private var isPrivate = false
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    var onFinish: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.3, blue: 0.5),
                    Color(red: 0.2, green: 0.6, blue: 0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                Text("Set Up Your Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Button(action: { showImagePicker = true }) {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 8)
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 100, height: 100)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $profileImage)
                }
                
                VStack(spacing: 16) {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    TextField("Bio (optional)", text: $bio)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                Toggle(isOn: $isPrivate) {
                    Text("Private Profile")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }
                
                Button(action: saveProfile) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Finish")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .disabled(isLoading)
                Spacer()
            }
            .padding(.top, 40)
        }
    }
    
    private func saveProfile() {
        errorMessage = nil
        isLoading = true
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Not signed in."
            isLoading = false
            print("Not signed in.")
            return
        }
        // Upload profile image if selected
        if let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            print("Uploading profile image for user: \(user.uid), image data size: \(imageData.count) bytes")
            let storageRef = storage.reference().child("profilePics/")
                .child("\(user.uid).jpg")
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Upload error: \(error.localizedDescription)")
                    errorMessage = "Failed to upload image: \(error.localizedDescription)"
                    isLoading = false
                    return
                }
                print("Upload succeeded, getting download URL...")
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Download URL error: \(error.localizedDescription)")
                        errorMessage = "Failed to get image URL."
                        isLoading = false
                    } else if let url = url {
                        print("Image uploaded successfully. URL: \(url.absoluteString)")
                        saveProfileData(profilePicUrl: url.absoluteString)
                    }
                }
            }
        } else {
            print("No profile image selected, saving profile without image.")
            saveProfileData(profilePicUrl: nil)
        }
    }
    
    private func saveProfileData(profilePicUrl: String?) {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Not signed in."
            isLoading = false
            print("Not signed in.")
            return
        }
        let db = Firestore.firestore()
        print("Saving profile for user: \(user.uid)")
        db.collection("users").document(user.uid).setData([
            "username": username,
            "bio": bio,
            "isPrivate": isPrivate,
            "profilePicUrl": profilePicUrl ?? "",
            "updatedAt": Timestamp(date: Date())
        ], merge: true) { err in
            isLoading = false
            if let err = err {
                errorMessage = "Failed to save profile: \(err.localizedDescription)"
                print("Firestore error: \(err.localizedDescription)")
            } else {
                print("Profile saved successfully.")
                onFinish?()
            }
        }
    }
}

// Simple ImagePicker for profile photo
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
} 