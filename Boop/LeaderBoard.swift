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
                Text("COMPETITION")
                    .fontWeight(.heavy)
                    .padding(.leading, 20)
                    .foregroundColor(.white)
                Spacer()
                Text("Show More")
                    .padding(.trailing, 20)
                    .foregroundColor(.white)
            }
            
            VStack{
                ScrollView(.horizontal, showsIndicators: false)
                {
                    HStack(spacing: 10){
                        ForEach(playersList, id: \.self) { item in
                            VStack{
                                Image(uiImage: item.image!)
                                    .resizable()
                                    .frame(width: 72, height: 72, alignment: .center)
                                    .clipShape(Circle())
                                Text(item.name)
                                    .fontWeight(.heavy)
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                                    .truncationMode(.middle)
                                    .frame(minWidth:105,idealWidth:105,maxWidth:105)
                                Text(item.score)
                                    .foregroundColor(.white)
                            }.padding(5)
                        }
                    }
                }
                .padding(.leading, 10.0)
            }
            .padding(5)
            .frame(minWidth:350, idealWidth:350,maxWidth:350, minHeight: 113)
            .clipShape(RoundedRectangle(cornerRadius: 20))
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