//
//  SplashView.swift
//  Momentum
//
//  Created by Mutaz on 3/5/2026.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var animateLogo = false

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "EABF55"),
                        Color(hex: "D64904"),
                        Color(hex: "962603")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image("logo-sp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 148, height: 148)
                        .scaleEffect(animateLogo ? 1 : 0.80)
                        .opacity(animateLogo ? 1 : 0)

                    VStack(spacing: 8) {
                        Text("Momentum")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.95))
                        
                        Text("Don't set goals, bulid habits")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        animateLogo = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)

        let r = Double((hexNumber & 0xff0000) >> 16) / 255
        let g = Double((hexNumber & 0x00ff00) >> 8) / 255
        let b = Double(hexNumber & 0x0000ff) / 255

        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    SplashView()
        .environmentObject(HabitStore())
}
