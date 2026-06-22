//
//  ContentView.swift
//  GuitarTunerApp
//
//  Created by Negi on 29/05/26.
//

import SwiftUI

import SwiftUI

struct TunerView: View {

    @State private var viewModel = TunerViewModel()

    var body: some View {

        VStack(spacing: 30) {

            Text("🎸 Guitar Tuner")
                .font(.largeTitle)

            Text(viewModel.isListening ? "Listening..." : "Stopped")
                .font(.headline)

            Button("Request Microphone Permission") {
                viewModel.requestPermission()
            }

            Text("Frequency Detected")
                .font(.headline)

            if let frequency = viewModel.detectedFrequency {
                Text("\(Int(frequency)) Hz")
                    .font(.title)
            } else {
                Text("-- Hz")
                    .font(.title)
            }

            Text("RMS Amplitude")
                .font(.headline)

            Text(String(format: "%.4f", viewModel.rms))
            
            Button("Start Listening") {
                viewModel.startListening()
            }

            .buttonStyle(.borderedProminent)

            Button("Stop Listening") {
                viewModel.stopListening()
            }
            .buttonStyle(.bordered)

        }
        .padding()
    }
}

#Preview {
    TunerView()
}
