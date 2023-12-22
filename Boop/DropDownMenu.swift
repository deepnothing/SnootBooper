import SwiftUI

struct DropdownMenu: View {
    @Binding var selectedOption: String
    let options: [String]
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    self.selectedOption = option

                } label: {
                    HStack {
                        Text(option)
                        Spacer()
                        if option == selectedOption {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Text("Breed")
                    .foregroundColor(Color.black)
                
                Image(systemName: "pawprint.fill")
                    .foregroundColor(Color.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
    }
}
