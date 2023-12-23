import SwiftUI

struct Modal: View {
    @Binding var showModal: Bool
    @Binding var boopCounter: CGFloat
    @Binding var timeString: String
    @Binding var elapsedTime:Double
    
    var body: some View {
        
        VStack {
            VStack{
                Text("Done!")
                    .font(.largeTitle)
                    .bold()
                
                Text("Your Time:")
                Text(timeString)
                
                Button("OK") {
                    boopCounter = 0
                    showModal = false
                    timeString = "00:00:00"
                    elapsedTime = 0
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .frame(minWidth: 200)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .edgesIgnoringSafeArea(.all)
    }
}

