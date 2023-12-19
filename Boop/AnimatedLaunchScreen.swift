import SwiftUI

struct AnimatedLaunchScreen: View {
    @Binding var showLaunchScreen: Bool
    
    @State private var fingerRotation = 0.0
    @State private var fingerOffset: CGFloat = 900
    @State private var fingerComeInDuration = 0.5
    
    var body: some View {
        ZStack {
            Color("launch-screen-background")
            
            ZStack{
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 220, height: 600)
                
                Image("finger")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(fingerRotation), anchor: .trailing)
                    .offset(x:fingerOffset, y:-40)
                    .onAppear {
                        animateFingerEntry()
                        DispatchQueue.main.asyncAfter(deadline: .now() + fingerComeInDuration) {
                            animateFingerRotation()
                        }
                    }
            }
        }
        .ignoresSafeArea()
    }
    
    private func animateFingerEntry() {
        withAnimation(Animation.easeInOut(duration: fingerComeInDuration)) {
            fingerOffset = 150
        }
    }
    
    private func animateFingerRotation() {
        withAnimation(Animation.easeInOut(duration: 0.2).repeatForever()) {
            fingerRotation += 25
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            withAnimation {
                showLaunchScreen = false
            }
        }
    }
}

