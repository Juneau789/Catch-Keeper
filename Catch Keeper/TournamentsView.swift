import SwiftUI

struct TournamentsView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.5), Color(red: 0.2, green: 0.6, blue: 0.7)]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                Image(systemName: "trophy.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.yellow)
                    .shadow(radius: 8)
                Text("Tournaments Coming Soon!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Compete with friends and anglers in public and private tournaments. Stay tuned!")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            }
        }
    }
} 