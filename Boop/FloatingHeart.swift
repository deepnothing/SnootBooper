import SwiftUI

// Custom GeometryEffect for curved motion
struct CurvedMotionEffect: GeometryEffect {
    var amount: CGFloat
    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }
    
    let shouldInvertXTranslation: Bool = Bool.random()


    func effectValue(size: CGSize) -> ProjectionTransform {
        // Curve upwards with a slight horizontal deviation
        let baseXTranslation = sin(amount * .pi * 2) * 20

       
        // Flip the direction if shouldInvertXTranslation is true, this doent work yet because rendering a new
        // heart changes the path of a previous heart... can be replicted with the line below
        // let xTranslation = shouldInvertXTranslation ? -baseXTranslation : baseXTranslation
        let xTranslation = baseXTranslation
        let yTranslation = -100 * amount // Primary upward movement

        return ProjectionTransform(CGAffineTransform(translationX: xTranslation, y: yTranslation))
    }
}

// FloatingHeart view
struct FloatingHeart: View {
    @State private var motionAmount: CGFloat
    @State private var startAnimation = false

    init() {
        // Randomly determine the extent of horizontal deviation
        _motionAmount = State(initialValue: CGFloat.random(in: 0.5...1.5))
    }

    var body: some View {
        Image(systemName: "heart.fill")
            .foregroundColor(.pink)
            .scaleEffect(1.5)
            .opacity(startAnimation ? 0 : 1)
            .modifier(CurvedMotionEffect(amount: startAnimation ? motionAmount : 0))
            .onAppear {
                withAnimation(.easeOut(duration: 1)) {
                    startAnimation = true
                }
            }
            .allowsHitTesting(false)
    }
}

