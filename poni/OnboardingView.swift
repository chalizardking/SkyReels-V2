//
//  OnboardingView.swift
//  poni
//
//  Created by Assistant on 2024
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var dataSourceManager = DataSourceManager.shared
    @State private var apiKey = ""
    @State private var currentPage = 0
    @State private var showingAPIKeyAlert = false
    @Environment(\.dismiss) private var dismiss
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to Poni",
            subtitle: "Professional Horse Racing Analysis",
            description: "Get comprehensive insights into horse racing with real-time data, performance analytics, and breeding information.",
            imageName: "chart.line.uptrend.xyaxis",
            color: .blue
        ),
        OnboardingPage(
            title: "Real-Time Data",
            subtitle: "Live Racing Information",
            description: "Access current race entries, results, jockey statistics, and trainer performance data from the Horse Racing USA API.",
            imageName: "network",
            color: .green
        ),
        OnboardingPage(
            title: "Advanced Analytics",
            subtitle: "Performance Insights",
            description: "Analyze horse performance, breeding information, ROI data, and make informed betting decisions.",
            imageName: "brain.head.profile",
            color: .purple
        ),
        OnboardingPage(
            title: "Get Started",
            subtitle: "API Key Required",
            description: "To access live horse racing data, you'll need an API key from the Horse Racing USA API on RapidAPI.",
            imageName: "key.fill",
            color: .orange
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Page Content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index], isLastPage: index == pages.count - 1) {
                        if index == pages.count - 1 {
                            // Last page - show API key input
                        } else {
                            withAnimation {
                                currentPage = index + 1
                            }
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Bottom Section
            VStack(spacing: 20) {
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? pages[currentPage].color : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                
                // API Key Input (only on last page)
                if currentPage == pages.count - 1 {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Enter your API Key")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Racing API Key", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    saveAPIKeyAndContinue()
                                }
                        }
                        
                        HStack(spacing: 12) {
                            Button("Get API Key") {
                                showingAPIKeyAlert = true
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Continue") {
                                saveAPIKeyAndContinue()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(apiKey.isEmpty)
                        }
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Navigation Buttons
                    HStack {
                        if currentPage > 0 {
                            Button("Previous") {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Spacer()
                        
                        Button(currentPage == pages.count - 2 ? "Setup" : "Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 40)
        }
        .alert("Get API Key", isPresented: $showingAPIKeyAlert) {
            Button("Visit RapidAPI") {
                if let url = URL(string: "https://rapidapi.com/api-sports/api/horse-racing-usa") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Get your free API key from the Horse Racing USA API on RapidAPI. Free tier includes 500 requests per month.")
        }
    }
    
    private func saveAPIKeyAndContinue() {
        dataSourceManager.configureAPIKey(apiKey)
        dismiss()
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(page.color)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
}