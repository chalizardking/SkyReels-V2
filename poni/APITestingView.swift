//
//  APITestingView.swift
//  poni
//
//  Created by Assistant on 2024
//

import SwiftUI

struct APITestingView: View {
    @StateObject private var testingService = APITestingService.shared
    @StateObject private var dataSourceManager = DataSourceManager.shared
    @State private var showingExportSheet = false
    @State private var exportedReport = ""

    var body: some View {
        NavigationStack {
            List {
                // API Status Section
                Section("API Status") {
                    HStack {
                        Label("Status", systemImage: testingService.overallTestStatus.icon)
                            .foregroundColor(testingService.overallTestStatus.color)
                        Spacer()
                        Text(testingService.overallTestStatus.rawValue.capitalized)
                    }
                }
                
                // Test Results Section
                Section("Test Results") {
                    if testingService.testResults.isEmpty {
                        ContentUnavailableView(
                            "No Test Results",
                            systemImage: "checkmark.circle",
                            description: Text("Run tests to see results")
                        )
                    } else {
                        ForEach(testingService.testResults) { result in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Label(result.testName, systemImage: result.status.icon)
                                        .foregroundColor(result.status.color)
                                    Spacer()
                                    Text(String(format: "%.1fs", result.duration))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(result.message)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("API Testing")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await testingService.runAllTests()
                        }
                    } label: {
                        if testingService.isRunningTests {
                            ProgressView()
                        } else {
                            Text("Run Tests")
                        }
                    }
                    .disabled(testingService.isRunningTests)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Export Results") {
                            exportedReport = testingService.exportResults()
                            showingExportSheet = true
                        }
                        .disabled(testingService.testResults.isEmpty)
                        
                        Button("Clear Results") {
                            testingService.clearResults()
                        }
                        .disabled(testingService.testResults.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                NavigationStack {
                    ScrollView {
                        Text(exportedReport)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                    }
                    .navigationTitle("Test Report")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingExportSheet = false
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct APITestingView_Previews: PreviewProvider {
    static var previews: some View {
        APITestingView()
    }
}
