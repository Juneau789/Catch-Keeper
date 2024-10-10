//
//  LogCatchView.swift
//  FishingLogApp
//
//  Created by Harrison Juneau on 8/15/24.
//

import SwiftUI
import UIKit
import CoreLocation

// Extension to hide the keyboard
extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Custom TextField using UIViewRepresentable to handle placeholder color and height
struct CustomTextField: UIViewRepresentable {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.keyboardType = keyboardType
        textField.textColor = .black // Input text color
        textField.backgroundColor = UIColor.white
        textField.layer.cornerRadius = 10
        textField.setPlaceholderColor(.black) // Set placeholder color
        
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChangeSelection(_:)), for: .editingChanged)

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
}

// Extension to set the placeholder color in the UITextField
extension UITextField {
    func setPlaceholderColor(_ color: UIColor) {
        guard let placeholder = self.placeholder else { return }
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}

struct LogCatchView: View {
    @State private var species: String = ""
    @State private var length: String = ""
    @State private var weight: String = ""
    @State private var catchDate = Date()
    @State private var useCurrentLocation = true
    @State private var location: String = "" // Manual location input if needed
    @State private var selectedImage: UIImage? // To store the selected photo
    @State private var isImagePickerPresented = false // To present the image picker
    @State private var catchSaved = false // To track if the catch is saved
    @State private var navigateToLogBook = false // To navigate to Log Book after saving

    var body: some View {
        NavigationStack {
            ZStack {
                Image("WeatheredPaper")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Photo Section
                        VStack(alignment: .leading) {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                            } else {
                                Button(action: {
                                    isImagePickerPresented = true
                                }) {
                                    HStack {
                                        Image(systemName: "camera")
                                        Text("Add a Photo")
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.5))
                                    .cornerRadius(10)
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        
                        // Details Section (Species, Length, Weight)
                        VStack(alignment: .leading) {
                            Text("Details")
                                .font(.headline)

                            CustomTextField(placeholder: "Species", text: $species, keyboardType: .default)
                                .frame(height: UIScreen.main.bounds.height * 0.06)
                                .padding(.horizontal)

                            CustomTextField(placeholder: "Length (inches)", text: $length, keyboardType: .decimalPad)
                                .frame(height: UIScreen.main.bounds.height * 0.06)
                                .padding(.horizontal)
                            
                            CustomTextField(placeholder: "Weight (lbs)", text: $weight, keyboardType: .decimalPad)
                                .frame(height: UIScreen.main.bounds.height * 0.06)
                                .padding(.horizontal)
                        }

                        // Date and Time Section
                        VStack(alignment: .leading) {
                            Text("Date and Time")
                                .font(.headline)

                            DatePicker("Select Date", selection: $catchDate, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }

                        // Location Section
                        VStack(alignment: .leading) {
                            Text("Location")
                                .font(.headline)

                            Toggle("Use Current Location", isOn: $useCurrentLocation)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)

                            if !useCurrentLocation {
                                CustomTextField(placeholder: "Enter Location", text: $location, keyboardType: .default)
                                    .frame(height: UIScreen.main.bounds.height * 0.06)
                                    .padding(.horizontal)
                            }
                        }

                        // Save Catch Button
                        Button(action: {
                            // Save the log functionality
                            catchSaved = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                navigateToLogBook = true
                            }
                        }) {
                            Text(catchSaved ? "Catch Saved" : "Save Catch")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(catchSaved ? Color.blue : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        // Navigation to LogBookView after saving a catch
                        NavigationLink(destination: LogBookView(), isActive: $navigateToLogBook) {
                            EmptyView()
                        }
                    }
                    .padding(20)
                }
            }
            .onTapGesture {
                UIApplication.shared.hideKeyboard()  // Dismiss the keyboard
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
}

#Preview {
    LogCatchView()
}
