import SwiftUI
import FirebaseAuth

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var isAuthenticated = false
    
    var body: some View {
        ZStack {
            // Coastal gradient background
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
                // App logo (placeholder)
                Image(systemName: "fish.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                Text("Catch Keeper")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            // Simulate loading, then check auth state
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if Auth.auth().currentUser != nil {
                    isAuthenticated = true
                }
                isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            if isAuthenticated {
                ContentView()
            } else {
                AuthView()
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
} 