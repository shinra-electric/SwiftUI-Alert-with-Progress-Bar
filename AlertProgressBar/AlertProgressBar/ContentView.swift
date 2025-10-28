//
//  ContentView.swift
//  AlertProgressBar
//
//  Created by Séamus on 2025/10/27.
//

import SwiftUI

struct ContentView: View {
    @State private var showAlert: Bool = false
    @State private var progress: CGFloat = 0
    @State private var config: ProgressAlertConfig = .init(title: "Downloading...", message: "Please wait until download completes")
    
    var body: some View {
        NavigationStack {
            List {
                Button("Show Alert") {
                    progress = 0
                    showAlert.toggle()
                    Task {
                        for _ in 1...1000 {
                            try? await Task.sleep(for: .seconds(0.001))
                            progress += 0.001
                            if progress >= 1 {
                                showAlert = false
                            }
                        }
                    }
                }
            }
            .navigationTitle("Progress Alert")
            .progressAlert(config: config, isPresented: $showAlert, progress: $progress) {
                Button("Cancel", role: .cancel) {
                    progress = 0
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
