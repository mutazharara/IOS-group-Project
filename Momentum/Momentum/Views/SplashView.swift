//
//  SplashView.swift
//  Momentum
//
//  Created by Mutaz on 3/5/2026.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {

                    // app logo
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .frame(width: 55, height: 55)
                            .foregroundColor(.black)
                    }

                    // app name
                    Text("Momentum")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // tagline
                    Text("Build Better. Every Day.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .onAppear {
                    // wait 2 seconds then go to the home screen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(HabitStore())
}
