import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AuthView: View {
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("didOnboard") private var didOnboard = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
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
            
            VStack(spacing: 32) {
                Spacer()
                Image(systemName: "fish.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                    .shadow(radius: 8)
                Text(isSignUp ? "Sign Up" : "Log In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    errorMessage = nil
                    isLoading = true
                    if isSignUp {
                        signUp()
                    } else {
                        logIn()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(isSignUp ? "Sign Up" : "Log In")
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
                
                HStack(spacing: 16) {
                    Button(action: {
                        // Placeholder for Google sign-in
                    }) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Google")
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                    }
                    Button(action: {
                        // Placeholder for Apple sign-in
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                            Text("Apple")
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    isSignUp.toggle()
                }) {
                    Text(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.footnote)
                }
                Spacer()
            }
            .padding(.top, 40)
        }
    }
    
    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            guard let user = result?.user else {
                errorMessage = "Unknown error."
                return
            }
            // Create user document in Firestore
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "email": email,
                "createdAt": Timestamp(date: Date())
            ]) { err in
                if let err = err {
                    errorMessage = "Failed to create user profile: \(err.localizedDescription)"
                } else {
                    isLoggedIn = true
                    didOnboard = false
                }
            }
        }
    }
    
    private func logIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            guard let user = result?.user else {
                errorMessage = "Unknown error."
                return
            }
            // Check if user profile exists in Firestore
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).getDocument { document, error in
                if let document = document, document.exists {
                    isLoggedIn = true
                    didOnboard = true
                } else {
                    isLoggedIn = true
                    didOnboard = false
                }
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
} 