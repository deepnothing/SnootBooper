import SwiftUI
import GameKit

struct LeaderBoard: View {
    @Binding var playersList: [Player]
    @Binding var isAuthenticated: Bool
    @Binding var showFriendsOnly: Bool
    var toggleFriendsOnly: () -> Void
    
    var leaderFontSize: CGFloat = 15

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                Text("LEADERBOARD")
                    .fontWeight(.heavy)
                    .padding(.leading)
                    .foregroundColor(.white)
                Spacer()
                Button(showFriendsOnly ? "Show All" : "Show Friends"){
                    toggleFriendsOnly()
                }
                .padding(.trailing)
                .foregroundColor(.white)
            }
            
            VStack{
                if !isAuthenticated {
                    HStack{
                        Button("Sign in"){
                            openSettings()
                        }
                        .padding(10)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(7)
                        
                        Text("to Game Center")
                            .foregroundColor(.white)
                    } .padding()
                } else
                if playersList.isEmpty {
                    HStack{
                        Text("No entries yet")
                            .foregroundColor(.white)
                            .padding(10)
                    }.padding()
                }
                else {
                    ScrollView(.horizontal, showsIndicators: false)
                    {
                        HStack(spacing: 0){
                            ForEach(playersList, id: \.self) { item in
                                HStack{
                                    HStack{
                                        Image(uiImage: item.image!)
                                            .resizable()
                                            .frame(width: 35, height: 35, alignment: .center)
                                            .clipShape(Circle())
                                        VStack(alignment: .leading){
                                            HStack{
                                                Text(item.name)
                                                    .bold()
                                                    .lineLimit(1)
                                                    .foregroundColor(.white)
                                                    .truncationMode(.middle)
                                                    .font(.system(size: leaderFontSize))
                                                   
                                                if playersList.first == item {
                                                    Image(systemName: "crown.fill")
                                                        .resizable()
                                                        .frame(width: 20, height: 15, alignment: .center)
                                                        .foregroundColor(.yellow)
                                                }
                                                
                                            }
                                            HStack(spacing: 5){
                                                
                                                Text(String((Double(item.score.replacingOccurrences(of: ",", with: "")) ?? 100000000000) / 100000000))
                                                    .foregroundColor(.white)
                                                    .font(.system(size: leaderFontSize))
                                                Text("Seconds")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: leaderFontSize))
                                            }
                                        }
                                    }
                                    .padding(10)
                                }
                                .background(Color("dark-green"))
                                .cornerRadius(10)
                                .padding([.top,.leading,.bottom])
                                .shadow(color: Color.black.opacity(0.7), radius: 4, x: 0, y: 2)
                    
                            }
                        }
                    }
                }
            }
        }
    }
}
