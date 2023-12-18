import SwiftUI

struct GlassView: View {
    var body: some View {
        Rectangle()
            .fill(Color.clear) // Simulates glass
        // Add more view modifiers for styling
    }
}

struct CondensationView: View {
    var size: CGFloat
    
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.5))
            .frame(width: size, height: size)
            .blur(radius: 10)
    }
}

struct Fog: View {
    @Binding var boopCounter: CGFloat
    let maxFogSize: CGFloat = 100
    
    var body: some View {
        GlassView()
            .overlay(
                CondensationView(size: min(boopCounter * 5, maxFogSize))
            )
            .allowsHitTesting(false)
    }
}
