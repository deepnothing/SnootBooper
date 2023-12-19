import SwiftUI
import GameKit
import CoreMotion

struct Player: Hashable, Comparable {
    static func < (lhs: Player, rhs: Player) -> Bool {
        return rhs.score > lhs.score
    }
    
    let id = UUID()
    let name: String
    let score: String
    let image: UIImage?
}

struct LeadersTileView: View {
    @AppStorage("GKGameCenterViewControllerState") var gameCenterViewControllerState:GKGameCenterViewControllerState = .default
    @AppStorage("IsGameCenterActive") var isGKActive:Bool = false
    var leaderboardIdentifier = "boopers_1"
    @State var playersList: [Player] = []
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                Text("LEADERBOARD")
                    .fontWeight(.heavy)
                    .padding(.leading)
                    .foregroundColor(.white)
                Spacer()
                Button("Show Friends"){
                    
                }.padding(.trailing)
                    .foregroundColor(.white)
            }
            
            VStack{
                ScrollView(.horizontal, showsIndicators: false)
                {
                    HStack(spacing: 10){
                        ForEach(playersList, id: \.self) { item in
                            HStack{
                                HStack{
                                    Image(uiImage: item.image!)
                                        .resizable()
                                        .frame(width: 40, height: 40, alignment: .center)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading){
                                        Text(item.name)
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                            .foregroundColor(.white)
                                            .truncationMode(.middle)
                                        HStack(spacing: 5){
                                            Text(String((Double(item.score.replacingOccurrences(of: ",", with: "")) ?? 100000000000) / 100000000))
                                                .foregroundColor(.white)
                                            Text("Seconds")
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding(10)
                            }
                            .background(Color("dark-green"))
                            .cornerRadius(10)
                            .padding()
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                }
            }
        }
        .onAppear(){
            if !GKLocalPlayer.local.isAuthenticated {
                authenticateUser()
            } else if playersList.count == 0 {
                Task{
                    await loadLeaderboard(source: 1)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                // 7.
                withAnimation {
                    if !GKLocalPlayer.local.isAuthenticated {
                        authenticateUser()
                    } else if playersList.count == 0 {
                        Task{
                            await loadLeaderboard(source: 2)
                        }
                    }
                }
            }
        }
        .onTapGesture {
            gameCenterViewControllerState = .leaderboards
            isGKActive = true
        }
    }
    
    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            Task{
                await loadLeaderboard(source: 3)
            }
        }
    }
    
    func loadLeaderboard(source: Int = 0) async {
        print(source)
        print("source")
        playersList.removeAll()
        Task{
            var playersListTemp : [Player] = []
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardIdentifier])
            if let leaderboard = leaderboards.filter ({ $0.baseLeaderboardID == self.leaderboardIdentifier }).first {
                let allPlayers = try await leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(1...5))
                if allPlayers.1.count > 0 {
                    for leaderboardEntry in allPlayers.1 {
                        do {
                            let image = try await leaderboardEntry.player.loadPhoto(for: .small)
                            playersListTemp.append(Player(name: leaderboardEntry.player.displayName, score: leaderboardEntry.formattedScore, image: image))
                        } catch {
                            print("Error loading player photo: \(error)")
                        }
                    }
                }
            }
            print("playersList")
            print(playersListTemp)
            playersList = playersListTemp
        }
    }
}
