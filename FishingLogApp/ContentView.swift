//
//  ContentView.swift
//  FishingLogApp
//
//  Created by Harrison Juneau on 8/15/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background Image for the blue fabric background
                Image("BlueFabricBackground")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)  // Make sure it covers the entire screen
                
                VStack {
                    Spacer()

                    // Title of the logbook
                    Text("Fishing Log Book")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)  // Black text
                        .padding(.bottom, 50) // Spacing above buttons
                        

                    Spacer()

                    // "Log a Catch" Button
                    NavigationLink(destination: LogCatchView()) {
                        Text("Log Entry")
                            .frame(width: 200)  // Smaller width
                            .padding()
                            .background(
                                Color.white.opacity(0.8)  // Creamy off-white background
                                    .cornerRadius(30)
                                    .shadow(radius: 2)
                            )
                            .foregroundColor(.black)  // Black text
                            .font(.title3)
                    }
                    .padding(.bottom, 20)  // Space between buttons

                    // "View Log" Button
                    NavigationLink(destination: LogBookView()) {
                        Text("View Log")
                            .frame(width: 200)  // Smaller width
                            .padding()
                            .background(
                                Color.white.opacity(0.8)  // Creamy off-white background
                                    .cornerRadius(30)
                                    .shadow(radius: 2)
                            )
                            .foregroundColor(.black)  // Black text
                            .font(.title3)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)  // Hide the default navigation bar
        }
    }
}

#Preview {
    ContentView()
}


