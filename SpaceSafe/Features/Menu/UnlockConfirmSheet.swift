import SwiftUI


struct UnlockConfirmSheet: View {
    let satellite: SatelliteCard
    let onConfirm: () throws -> Void
    @Binding var isPresented: Bool
    @State private var coinsBurst = false
    @State private var showSuccess = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Unlock Satellite?")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 28)

            // Satellite name + tier
            VStack(spacing: 6) {
                Text("🛰️").font(.system(size: 52))
                    .scaleEffect(coinsBurst ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: coinsBurst)
                Text(satellite.name)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }

            // Cost pill
            HStack(spacing: 8) {
                Text("🪙")
                Text("\(satellite.unlockCost) coins")
                    .font(.system(size: 17, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.orange.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.4), lineWidth: 1)))

            // Coin particles
            ZStack {
                if coinsBurst {
                    ForEach(0..<8, id: \.self) { i in
                        CoinParticle(index: i)
                    }
                }
            }
            .frame(height: 60)

            // Success state
            if showSuccess {
                VStack(spacing: 6) {
                    Text("🎉").font(.system(size: 40))
                    Text("Unlocked!").font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.cyan)
                }
                .transition(.scale.combined(with: .opacity))
            }

            // Error banner
            if let error = errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.4), lineWidth: 1)))
                .padding(.horizontal, 24)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Spacer()

            // Buttons
            VStack(spacing: 10) {
                Button {
                    errorMessage = nil
                    do {
                        try onConfirm()
                        withAnimation { coinsBurst = true }
                        handleUnlockResult(success: true, error: nil)
                    } catch {
                        handleUnlockResult(success: false, error: error.localizedDescription)
                    }
                } label: {
                    Label("Unlock now", systemImage: "lock.open.fill")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.black).frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)))
                }
                .disabled(showSuccess)

                Button("Cancel") { isPresented = false }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 12)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.9))
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func handleUnlockResult(success: Bool, error: String?) {
        if success {
            withAnimation(.spring()) { showSuccess = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isPresented = false
            }
        } else {
            withAnimation {
                coinsBurst = false
                errorMessage = error ?? "Something went wrong"
            }
        }
    }
}


struct CoinParticle: View {
    let index: Int
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1

    var body: some View {
        Text("🪙").font(.system(size: 18))
            .offset(offset).opacity(opacity)
            .onAppear {
                let angle = Double(index) / 8.0 * .pi * 2
                let dist = CGFloat.random(in: 40...80)
                withAnimation(.easeOut(duration: 0.8).delay(Double(index) * 0.05)) {
                    offset = CGSize(width: cos(angle) * dist, height: sin(angle) * dist - 20)
                    opacity = 0
                }
            }
    }
}
