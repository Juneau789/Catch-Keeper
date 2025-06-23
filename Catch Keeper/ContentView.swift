//
//  ContentView.swift
//  Catch Keeper
//
//  Created by Harrison Juneau on 4/21/25.
//

import SwiftUI
import CoreData
import FirebaseFirestore

struct ContentView: View {
    @AppStorage("didOnboard") private var didOnboard = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        if !isLoggedIn {
            AuthView()
        } else if !didOnboard {
            OnboardingView(onFinish: {
                didOnboard = true
            })
        } else {
            MainAppView()
        }
    }
}

struct MainAppView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem { Label("Feed", systemImage: "house.fill") }
            TournamentsView()
                .tabItem { Label("Tournaments", systemImage: "trophy.fill") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
