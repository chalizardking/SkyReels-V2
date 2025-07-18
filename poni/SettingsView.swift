//
//  SettingsView.swift
//  poni
//
//  Created by Assistant on 2024
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var dataSourceManager = DataSourceManager.shared
    @StateObject private var appearanceManager = AppearanceManager.shared
    @State private var apiKey = ""
    @State private var showingAPIKeyAlert = false
    @State private var isTestingConnection = false

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Appearance Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeaderView(
                            icon: appearanceIcon,
                            title: "Appearance",
                            subtitle: "Choose your preferred theme"
                        )
                        
                        Picker("Appearance", selection: $appearanceManager.currentMode) {
                            Text("System").tag(AppearanceMode.system)
                            Text("Light").tag(AppearanceMode.light)
                            Text("Dark").tag(AppearanceMode.dark)
                        }
                        .pickerStyle(.segmented)
                    }
                } header: {
                    Text("Display")
                } footer: {
                    Text("System mode follows your device's appearance settings.")
                }
                
                // MARK: - API Configuration Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: apiKeyStatusIcon)
                                    .foregroundColor(apiKeyStatusColor)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("API Key Status")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(apiKeyStatusText)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            SecureField("Enter Racing API Key", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    saveAPIKey()
                                }
                            
                            HStack {
                                Button("Save API Key") {
                                    saveAPIKey()
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(apiKey.isEmpty)
                                
                                Spacer()
                                
                                Button("Get API Key") {
                                    showingAPIKeyAlert = true
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            if dataSourceManager.apiKeyConfigured {
                                Button(action: {
                                    Task {
                                        await testAPIConnection()
                                    }
                                }) {
                                    HStack {
                                        if isTestingConnection {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text("Testing...")
                                        } else {
                                            Image(systemName: "network")
                                            Text("Test Connection")
                                        }
                                    }
                                }
                                .buttonStyle(.bordered)
                                .frame(maxWidth: .infinity)
                                .disabled(isTestingConnection)
                            }
                        }
                    } header: {
                        Text("Horse Racing USA API Configuration")
                    } footer: {
                        Text("You need a valid API key from the Horse Racing USA API on RapidAPI to access real horse racing data. Visit rapidapi.com to get your key.")
                    }
                
                // MARK: - Data Status Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                            Text("Data Coverage")
                                .font(.headline)
                        }
                        
                        DataCoverageRow(title: "Horse Profiles", available: true)
                        DataCoverageRow(title: "Race Results", available: true)
                        DataCoverageRow(title: "Jockey Statistics", available: true)
                        DataCoverageRow(title: "Trainer Statistics", available: true)
                        DataCoverageRow(title: "Breeding Information", available: true)
                    }
                } header: {
                    Text("Available Data")
                } footer: {
                    Text("Data is sourced from Horse Racing USA API via RapidAPI.")
                }
                
                // MARK: - Error Display
                if let errorMessage = dataSourceManager.errorMessage {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        
                        Button("Clear Error") {
                            dataSourceManager.clearError()
                        }
                        .buttonStyle(.bordered)
                    } header: {
                        Text("Error")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(appearanceManager.currentMode.colorScheme)
        .onAppear {
            loadSavedAPIKey()
        }
        .alert("Get API Key", isPresented: $showingAPIKeyAlert) {
            Button("Visit RapidAPI") {
                #if os(iOS)
                if let url = URL(string: "https://rapidapi.com/api-sports/api/horse-racing-usa") {
                    UIApplication.shared.open(url)
                }
                #elseif os(macOS)
                if let url = URL(string: "https://rapidapi.com/api-sports/api/horse-racing-usa") {
                    NSWorkspace.shared.open(url)
                }
                #endif
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You can get a free API key from the Horse Racing USA API on RapidAPI. Note: This API has a limit of 10 requests per minute.")
        }

    }
    
    // MARK: - Computed Properties
    private var appearanceIcon: String {
        switch appearanceManager.currentMode {
        case .system:
            return "gearshape.2"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }
    
    private func iconForMode(_ mode: AppearanceMode) -> String {
        switch mode {
        case .system:
            return "gearshape.2"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }
    

    
    private var apiKeyStatusIcon: String {
        dataSourceManager.apiKeyConfigured ? "checkmark.circle.fill" : "xmark.circle.fill"
    }
    
    private var apiKeyStatusColor: Color {
        dataSourceManager.apiKeyConfigured ? .green : .red
    }
    
    private var apiKeyStatusText: String {
        dataSourceManager.apiKeyConfigured ? "API key configured" : "API key required"
    }
    
    // MARK: - Methods
    private func loadSavedAPIKey() {
        apiKey = UserDefaults.standard.string(forKey: "racing_api_key") ?? ""
    }
    
    private func saveAPIKey() {
        if dataSourceManager.configureAPIKey(apiKey) {
            // Show success feedback
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
            
            // Clear any existing error
            dataSourceManager.clearError()
        }
    }
    
    private func testAPIConnection() async {
        await MainActor.run {
            isTestingConnection = true
            dataSourceManager.setError("Testing connection...")
        }
        
        let realService = RealDataService.shared
        
        // Show current API key info
        let currentKey = realService.getCurrentAPIKey()
        print("Current API key: \(currentKey.prefix(20))...")
        print("API key length: \(currentKey.count)")
        print("Is valid format: \(realService.isAPIKeyValid())")
        
        // Try to make a test request
        do {
            let races = try await realService.fetchTodaysRaces()
            await MainActor.run {
                dataSourceManager.setError("✅ Connection successful! Found \(races.count) races.")
                isTestingConnection = false
            }
        } catch {
            await MainActor.run {
                dataSourceManager.setError("❌ Connection failed: \(error.localizedDescription)")
                isTestingConnection = false
            }
            print("Connection test error: \(error)")
        }
    }
}

// MARK: - Section Header View
struct SectionHeaderView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Data Coverage Row
struct DataCoverageRow: View {
    let title: String
    let available: Bool
    
    var body: some View {
        HStack {
            Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(available ? .green : .red)
                .font(.caption)
            
            Text(title)
                .font(.caption)
            
            Spacer()
        }
    }
}



#Preview {
    SettingsView()
}
