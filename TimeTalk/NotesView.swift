//
//  NotesView.swift
//  Time Tell
//
//  Created by Pieter Yoshua Natanael on 04/12/24.
//

import SwiftUI
import AVFoundation

/// A view that provides note-taking functionality with persistence and sound feedback.
/// Features:
/// - Add and delete notes with timestamp tracking
/// - Mark notes as completed with visual feedback
/// - Sound effects for user interactions
/// - Data persistence using UserDefaults
/// - Days ago calculation for each note
///
struct NotesView: View {
    // MARK: - UI State
    @State private var showAdsAndAppFunctionality = false
    @State private var showDeleteConfirmation = false
    @State private var selectedNote: Worry?
    @State private var newNoteText = ""
    
    // MARK: - Data Management
    @State private var notes: [Worry] = []
    @State private var soundEffect: AVAudioPlayer?
    @State private var defaults = UserDefaults.standard
    @StateObject private var viewModel = WorryViewModel()
    
    // MARK: - Formatters
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    // MARK: - Data Persistence
    
    /// Saves the current notes to UserDefaults.
    /// Uses JSONEncoder to convert notes array to Data.
    private func save() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(notes) {
            defaults.set(encoded, forKey: "SavedWorries")
        }
    }
    
    /// Loads previously saved notes from UserDefaults.
    /// Decodes the data using JSONDecoder and updates the notes array.
    private func load() {
        let decoder = JSONDecoder()
        if let data = defaults.data(forKey: "SavedWorries") {
            if let loadedNotes = try? decoder.decode([Worry].self, from: data) {
                notes = loadedNotes
            }
        }
    }
    
    // MARK: - Note Management
    
    /// Adds a new note to the collection.
    /// - Appends the note to the array
    /// - Clears the input field
    /// - Saves to persistence
    /// - Plays feedback sound
    /// - Shows confirmation message
    private func addNote() {
        guard !newNoteText.isEmpty else { return }
        let newNote = Worry(text: newNoteText)
        notes.append(newNote)
        newNoteText = ""
        save()
        playSoundEffect()
        showMessage(title: "Thank You!", message: "Thank you for sharing your notes.")
    }
    
    
    /// Deletes notes at the specified offsets.
    /// - Parameter offsets: IndexSet of items to delete
    private func deleteNote(atOffsets offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        save()
    }
    
    // MARK: - Audio Feedback
    
    /// Plays a sound effect for user feedback.
    /// Attempts to load and play the "flute.mp3" sound file.
    private func playSoundEffect() {
        if let soundURL = Bundle.main.url(forResource: "flute", withExtension: "mp3") {
            do {
                soundEffect = try AVAudioPlayer(contentsOf: soundURL)
                soundEffect?.play()
            } catch {
                print("Error loading sound file: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - User Feedback
    
    /// Shows an alert message to the user.
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - message: The message to display
    private func showMessage(title: String, message: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            windowScene.windows.first?.rootViewController?.present(alertController, animated: true)
        }
    }
    
    /// Toggles the completion status of a note.
    /// - Parameter note: The note to toggle
    private func toggleRealized(for note: Worry) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].realized.toggle()
            save()
        }
    }
    
    var body: some View {
        ZStack {
            // Background Color Gradient
            LinearGradient(colors: [Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(.white))
                            .padding()
                            .shadow(color: Color.black.opacity(0.6), radius: 5, x: 0, y: 2)
                    }
                }
                Spacer()
                HStack {
                    Text("Time Tell Notes")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
                List {
                    ForEach(notes) { note in
                        VStack(alignment: .leading) {
                            Text(note.text)
                            HStack {
                                Text("Added: \(note.timestamp, formatter: dateFormatter)")
                                Spacer()
                                Text("\(note.daysAgo) days ago")
                                Button(action: {
                                    toggleRealized(for: note)
                                }) {
                                    Image(systemName: note.realized ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundColor(note.realized ? Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)) : .primary)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Button(action: {
                                    selectedNote = note
                                    showDeleteConfirmation = true
                                }) {
                                    Image(systemName: "trash")
                                        .font(.title3.bold())
                                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .foregroundColor(note.realized ? Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)) : .primary)
                        }
                    }
                    .onDelete(perform: deleteNote)
                }
                .listStyle(PlainListStyle())
                
                TextField("Enter your notes", text: $newNoteText)
                    .padding()

                Button(action: addNote) {
                    Text("Save Notes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)))
                        .foregroundColor(.white)
                        .font(.title3.bold())
                        .cornerRadius(10)
                        .padding()
                        .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .onAppear {
                load()
            }
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                AdsAndAppFunctionalityView(onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Notes"),
                    message: Text("Are you sure you want to delete this notes?"),
                    primaryButton: .destructive(Text("Yes")) {
                        if let selectedNote = selectedNote {
                            if let index = notes.firstIndex(where: { $0.id == selectedNote.id }) {
                                notes.remove(at: index)
                            }
                        }
                        selectedNote = nil
                        save()
                        playSoundEffect()
                    },
                    secondaryButton: .cancel(Text("No")) {
                        selectedNote = nil
                    }
                )
            }
        }
    }
}

// MARK: - Supporting Types

/// Custom style for text input fields
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

/// Model representing a single note entry
struct Worry: Identifiable, Codable {
    /// Unique identifier for the note
    let id = UUID()
    /// The content of the note
    let text: String
    /// Whether the note has been marked as completed
    var realized = false
    /// When the note was created
    let timestamp = Date()
    
    /// Calculated property for the age of the note in days
    var daysAgo: Int {
        Calendar.current.dateComponents([.day], from: timestamp, to: Date()).day ?? 0
    }
}

// MARK: - Ads and App Functionality View

/// View showing information about ads and the app functionality
struct AdsAndAppFunctionalityView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                // Section header
                HStack {
                    Text("Ads & App Functionality")
                        .font(.title3.bold())
                    Spacer()
                }
                Divider().background(Color.gray)

                // Ads section
                VStack {
                    // Ads header
                    HStack {
                        Text("Apps for you")
                            .font(.largeTitle.bold())
                        Spacer()
                    }

                        Divider().background(Color.gray)

                        CardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                        Divider().background(Color.gray)

                        CardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)

                        CardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)

                    }
                    Spacer()
                }
                .padding()
                .cornerRadius(15.0)

                // App functionality section
                HStack {
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }

                Text("""
                • Users can enter their notes into a text field and save them.
                • Saved notes are displayed in a list with details such as the date added and how many days ago they were added.
                • Each notes in the list has a 'checkmark' button that users can tap to mark the notes as resolved.
                • Users can delete notes by tapping the "trash" button next to each notes, with a confirmation dialog to ensure they want to delete it permanently.
                • The app automatically calculates and displays the number of days since each notes was added.
                •We do not collect data, so there's no need to worry
                """)
                .font(.title3)
                .multilineTextAlignment(.leading)
                .padding()

                Spacer()

                HStack {
                    Text("Time Tell is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

                // Close button
                Button("Close") {
                    onConfirm()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .font(.title3.bold())
                .cornerRadius(10)
                .padding()
                .shadow(color: Color.white.opacity(12), radius: 3, x: 3, y: 3)
            }
            .padding()
            .cornerRadius(15.0)
        }
    }


// MARK: - Ads App Card View

/// View displaying individual ads app cards
struct CardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String

    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)

            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)

            Spacer()

            // Try button
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - View Model

/// View model for managing notes data
class WorryViewModel: ObservableObject {
    @Published var notes: [Worry] = []

    private let dataManager = DataManager()

    init() {
        loadWorries()
    }

    func loadWorries() {
        notes = dataManager.loadWorries()
    }

    func saveWorry(_ worry: Worry) {
        dataManager.saveWorry(worry)
        loadWorries()
    }

    func deleteWorry(atOffsets offsets: IndexSet) {
        dataManager.deleteWorry(atOffsets: offsets)
        loadWorries()
    }
}

// MARK: - Data Manager

/// Data manager for persisting notes data
class DataManager {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func loadWorries() -> [Worry] {
        guard let data = defaults.data(forKey: "SavedWorries") else { return [] }
        guard let loadedWorries = try? decoder.decode([Worry].self, from: data) else { return [] }
        return loadedWorries
    }
    /// Function to save notes
    func saveWorry(_ worry: Worry) {
        var savedWorries = loadWorries()
        savedWorries.append(worry)
        if let encoded = try? encoder.encode(savedWorries) {
            defaults.set(encoded, forKey: "SavedWorries")
        }
    }

    func deleteWorry(atOffsets offsets: IndexSet) {
        var savedWorries = loadWorries()
        savedWorries.remove(atOffsets: offsets)
        if let encoded = try? encoder.encode(savedWorries) {
            defaults.set(encoded, forKey: "SavedWorries")
        }
    }
}

// MARK: - Preview

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView()
    }
}
