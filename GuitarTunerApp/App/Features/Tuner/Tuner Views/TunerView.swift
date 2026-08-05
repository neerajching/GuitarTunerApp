//
//  ContentView.swift
//  GuitarTunerApp
//
//  Created by Negi on 29/05/26.
//

import SwiftUI

struct TunerView: View {

    @State private var viewModel = TunerViewModel()
    @State private var manualStringIndex: Int? = nil
    @State private var glowPulse = false
    
    @Environment(\.bottomBarInset)
        private var bottomBarInset

    private var activeIndex: Int {
        manualStringIndex ?? PitchMath.nearestStringIndex(to: viewModel.detectedFrequency ?? 0) ?? 3
    }

    private var activeString: GuitarString {
        StandardTuning.strings[activeIndex]
    }

    private var cents: Double {
        guard let freq = viewModel.detectedFrequency, freq > 0 else { return 0 }
        return PitchMath.cents(of: freq, relativeTo: activeString.frequency)
    }

    private var status: TuningStatus {
        guard viewModel.isListening, let freq = viewModel.detectedFrequency, freq > 0 else { return .silent }
        return PitchMath.status(forCents: cents)
    }

    private var displayNote: String {
        guard let freq = viewModel.detectedFrequency, freq > 0 else { return "–" }
        return PitchMath.nearestNote(for: freq).name
    }

    private var frequencyText: String {
        guard let freq = viewModel.detectedFrequency, freq > 0 else { return "-- Hz" }
        return String(format: "%.1f Hz", freq)
    }

    private var statusColor: Color {
        switch status {
        case .inTune: return .auroraGreen
        case .tooHigh, .tooLow: return .white.opacity(0.7)
        case .silent: return .white.opacity(0.3)
        }
    }

    private var statusText: String {
        switch status {
        case .silent: return "Listening…"
        case .inTune: return "In Tune"
        case .tooHigh: return "Too High"
        case .tooLow: return "Too Low"
        }
    }

    var body: some View {
        ZStack {
            background

            switch viewModel.permissionState {
            case .denied:
                permissionCard
            case .undetermined, .granted:
                tunerContent
            }
        }
        .safeAreaPadding(.bottom, bottomBarInset)
        .onAppear { viewModel.prepareAudio() }
        .onDisappear { viewModel.stopListening() }
        .onChange(of: status) { _, newValue in
            if newValue == .inTune {
                withAnimation(.easeInOut(duration: 0.8).repeatCount(3, autoreverses: true)) {
                    glowPulse = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) { glowPulse = false }
            }
        }
    }

    // MARK: - Main tuner content

    private var tunerContent: some View {
        VStack(spacing: 0) {
            header

            Spacer(minLength: 8)

            hero

            Spacer(minLength: 8)

            stringSelector

            levelIndicator
                .padding(.top, 24)

            Text("A4 = 440 Hz")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.35))
                .padding(.top, 18)
        }
        .padding(.horizontal, 28)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Permission gate

    private var permissionCard: some View {
        VStack(spacing: 0) {
            header
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "mic.slash.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 72, height: 72)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.08)))

                VStack(spacing: 6) {
                    Text("Microphone Access Needed")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Tuning listens to your guitar in real time.\nEnable the microphone in Settings to continue.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Settings")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.auroraGreen))
                }
                .padding(.top, 4)
            }
            .padding(28)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
            .overlay(RoundedRectangle(cornerRadius: 28).strokeBorder(.white.opacity(0.08)))
            .padding(.horizontal, 20)
            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            RadialGradient(
                colors: [Color(white: 0.08), .black],
                center: .top, startRadius: 0, endRadius: 520
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.auroraGreen.opacity(status == .inTune ? 0.32 : 0.2))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: -100, y: -160)
                .animation(.easeInOut(duration: 1.0), value: status)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 220, height: 220)
                .blur(radius: 70)
                .offset(x: 120, y: 220)
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            VStack(spacing: 4) {
                Text("GUITAR")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(4)
                    .foregroundStyle(.white.opacity(0.45))
                Text("Standard Tuning")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
            }

            HStack {
                Spacer()
                Button {
                    // present settings sheet
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.08)))
                }
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 8)
    }

    // MARK: - Hero (note, frequency, gauge, status)

    private var hero: some View {
        VStack(spacing: 4) {
            Text(displayNote)
                .font(.system(size: 160, weight: .semibold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.white, Color(white: 0.85)], startPoint: .top, endPoint: .bottom)
                )
                .contentTransition(.interpolate)
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: displayNote)
                .shadow(color: statusColor.opacity(status == .inTune ? 0.35 : 0), radius: 40)

            Text(frequencyText)
                .font(.system(size: 21, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: frequencyText)

            ArcGaugeView(cents: cents, isActive: status != .silent, accentColor: .auroraGreen)
                .frame(width: 250, height: 110)
                .padding(.top, 26)

            Text(statusText.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .tracking(2)
                .foregroundStyle(statusColor)
                .padding(.horizontal, 22)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.12))
                        .overlay(Capsule().strokeBorder(statusColor.opacity(0.35)))
                )
                .shadow(color: statusColor.opacity(status == .inTune ? 0.4 : 0), radius: 16)
                .scaleEffect(glowPulse ? 1.05 : 1.0)
                .padding(.top, 16)
        }
    }

    // MARK: - String selector

    private var stringSelector: some View {
        HStack(spacing: 8) {
            ForEach(Array(StandardTuning.strings.enumerated()), id: \.offset) { index, string in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        manualStringIndex = index
                    }
                } label: {
                    Text(string.name)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .frame(width: 38, height: 38)
                        .foregroundStyle(index == activeIndex ? Color.black : .white.opacity(0.55))
                        .background(
                            Circle().fill(index == activeIndex ? Color.auroraGreen : Color.white.opacity(0.05))
                        )
                        .overlay(
                            Circle().strokeBorder(.white.opacity(index == activeIndex ? 0 : 0.08))
                        )
                        .shadow(color: Color.auroraGreen.opacity(index == activeIndex ? 0.45 : 0), radius: 12)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Input level

    private var levelIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { i in
                Capsule()
                    .fill(barIsLit(i) ? Color.auroraGreen : Color.white.opacity(0.2))
                    .frame(width: 4, height: barHeight(i))
            }
        }
        .animation(.easeOut(duration: 0.12), value: viewModel.rms)
    }

    /// Rough RMS-to-bar-count mapping. Tune the multiplier against your
    /// mic's actual gain once you're testing against a real guitar signal.
    private func normalizedLevel() -> Double {
        min(max(Double(viewModel.rms) * 18, 0), 1)
    }

    private func barIsLit(_ index: Int) -> Bool {
        normalizedLevel() >= Double(index + 1) / 5.0
    }

    private func barHeight(_ index: Int) -> CGFloat {
        barIsLit(index) ? CGFloat(6 + (index + 1) * 3) : 6
    }
}

extension Color {
    static let auroraGreen = Color(red: 48 / 255, green: 209 / 255, blue: 88 / 255)
}

#Preview {
    TunerView()
}
// MARK: TAP FIRES ON A BACKGROUND AUDIO THREAD — SWIFTUI UPDATES MUST HAPPEN ON MAIN THREAD

#Preview {
    TunerView()
}
