import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State var username: String
    @State var bio: String
    @State var isPrivate: Bool
    @State private var email: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showPasswordSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    TextField("Username", text: $username)
                    TextField("Bio", text: $bio)
                    Toggle(isOn: $isPrivate) {
                        Text("Private Profile")
                    }
                }
                Section(header: Text("Account")) {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(email).foregroundColor(.secondary)
                    }
                    Button("Change Password") {
                        showPasswordSheet = true
                    }
                }
                if let error = errorMessage {
                    Text(error).foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveProfile() }
                        .disabled(isLoading)
                }
            }
            .onAppear(perform: loadEmail)
            .sheet(isPresented: $showPasswordSheet) {
                ChangePasswordView()
            }
        }
    }
    
    private func loadEmail() {
        if let user = Auth.auth().currentUser {
            email = user.email ?? ""
        }
    }
    
    private func saveProfile() {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        errorMessage = nil
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData([
            "username": username,
            "bio": bio,
            "isPrivate": isPrivate,
            "updatedAt": Timestamp(date: Date())
        ], merge: true) { err in
            isLoading = false
            if let err = err {
                errorMessage = "Failed to save: \(err.localizedDescription)"
            } else {
                dismiss()
            }
        }
    }
}

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm Password", text: $confirmPassword)
                if let error = errorMessage {
                    Text(error).foregroundColor(.red)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { changePassword() }
                        .disabled(isLoading)
                }
            }
        }
    }
    
    private func changePassword() {
        guard newPassword == confirmPassword, !newPassword.isEmpty else {
            errorMessage = "Passwords do not match."
            return
        }
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        errorMessage = nil
        user.updatePassword(to: newPassword) { err in
            isLoading = false
            if let err = err {
                errorMessage = "Failed: \(err.localizedDescription)"
            } else {
                dismiss()
            }
        }
    }
} 