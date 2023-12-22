import SwiftUI
import GameKit
import CoreMotion

struct Player: Hashable, Comparable{
    static func < (lhs: Player, rhs: Player) -> Bool {
        return rhs.score > lhs.score
    }
    let id = UUID()
    let name: String
    let score: String
    let image: UIImage?
}

struct ContentView: View {
    
    @AppStorage("GKGameCenterViewControllerState") var gameCenterViewControllerState:GKGameCenterViewControllerState = .default
    @AppStorage("IsGameCenterActive") var isGKActive:Bool = false
  
    
    @State private var showLaunchScreen = true
    @State private var selectedBreed = "Dalmatian"
    @State private var backgroundImage: String = "blue"
    @State private var boopCounter: CGFloat = 0
    @State private var isComplete = false
    @State private var showModal = false
    @State private var timer: Timer?
    @State private var timeString = "00:00:000"
    @State private var elapsedTime: TimeInterval = 0.0
    @State var playersList: [Player] = []
    @State private var isAuthenticated: Bool = false
    
    
    private let breedNames = ["Dalmatian", "Greyhound"]
    private let backgroundOptions = ["blue", "city", "jungle", "beach", "space", "desert"]
    private let tiltAngle: Double = 10
    private let scaleSize = 0.03
    private let animationDuration: Double = 0.1
    private let boopsCompletedNumber: Double = 10
    private let timerInterval = 0.01
    var leaderboardIdentifier = "boopers_1"
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { timer in
            elapsedTime += timerInterval
            let minutes = Int(elapsedTime / 60)
            let seconds = Int(elapsedTime) % 60
            let milliseconds = Int((elapsedTime * 1000).truncatingRemainder(dividingBy: 1000))
            timeString = String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
        }
    }
    
    func stopTimer() {
        print("stopping",elapsedTime)
        timer?.invalidate()
        timer = nil
    }
    
    
    func submitScoreToLeaderboard() async {
        do {
            let scoreValue = Int(100000000 * elapsedTime)
            try await GKLeaderboard.submitScore(
                scoreValue,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: ["boopers_1"]
            )
            print("\(elapsedTime) submitted to leaderboard")
            Task {
                await loadLeaderboard(source: 2)
            }
        } catch {
            print("Error submitting score to leaderboard: \(error)")
        }
    }
    
    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "GKPLAYER AUTH ERROR")
                return
            }
            Task{
                print(GKLocalPlayer.local.isAuthenticated,"auth")
                isAuthenticated = GKLocalPlayer.local.isAuthenticated
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
    
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                
                Image(backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 2)
                    .frame(maxWidth: geometry.size.width, maxHeight: .infinity)
                    .edgesIgnoringSafeArea([.top, .bottom])
                
                VStack{
                    HStack(alignment: .top) {
                        VStack(alignment:.leading){
                            DropdownMenu(selectedOption: $selectedBreed, options: breedNames)
                            
                            Text("Tap the dog's nose as quickly as you can to play!")
                                .foregroundColor(.white)
                                .padding(.top,2)
                        }
                        Spacer()
                        BackgroundPicker(backgroundImage: $backgroundImage, options: backgroundOptions)
                    }
                    .padding()
                    
                    LeaderBoard(playersList: $playersList,isAuthenticated: $isAuthenticated)
                    
                    HStack{
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .scaleEffect(1)
                        
                        ProgressView(value: min(Double(boopCounter) / boopsCompletedNumber, 1.0))
                            .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                            .scaleEffect(x: 1, y: 2)
                        
                        Spacer(minLength:10)
                        
                        Text(timeString)
                            .foregroundColor(Color.white)
                            .font(Font.system(size: min(geometry.size.width, geometry.size.height) * 0.06, weight: .bold, design: .monospaced))
                            .padding(10)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.white, lineWidth: 5)
                            )
                        
                    }
                    .padding([.leading,.trailing])
                    
                    
                    Dog(boopCounter: $boopCounter,selectedBreed: $selectedBreed)
                    
                }
                
                if showModal {
                    Modal(showModal: $showModal, boopCounter: $boopCounter, timeString:$timeString, elapsedTime: $elapsedTime)
                }
                if showLaunchScreen{
                    AnimatedLaunchScreen(showLaunchScreen: $showLaunchScreen)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .onChange(of: boopCounter) { newValue in
                if newValue >= boopsCompletedNumber {
                    stopTimer()
                    showModal = true
                    Task {
                        await submitScoreToLeaderboard()
                    }
                }
                if newValue == 1 {
                    startTimer()
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
            }
//            .onTapGesture {
//                gameCenterViewControllerState = .leaderboards
//                isGKActive = true
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

