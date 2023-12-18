import SwiftUI

struct BackgroundPicker: View {
    @Binding var backgroundImage: String
    let options: [String]
    
    var body: some View {
        VStack(spacing:20) {
            HStack {
                ForEach(options[0..<3], id: \.self) { option in
                    optionCircle(option: option)
                }
            }
            HStack {
                ForEach(options[3..<6], id: \.self) { option in
                    optionCircle(option: option)
                }
            }
        }
    }
    
    @ViewBuilder
    private func optionCircle(option: String) -> some View {
        VStack {
            Image(option)
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
                .onTapGesture {
                    backgroundImage = option
                }
            Text(option.capitalized)
                .font(.caption)
                .foregroundColor(.white)
            
        }
        // keep everything spaced equally
        .frame(width: 60)
    }
}

