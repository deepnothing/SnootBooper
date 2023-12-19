import SwiftUI
import GameKit

struct ContentView: View {
    
    @State private var showLaunchScreen = true
    @State private var selectedBreed = "Dalmatian"
    @State private var backgroundImage: String = "blue"
    @State private var boopCounter: CGFloat = 0
    @State private var isComplete = false
    @State private var showModal = false
    @State private var timer: Timer?
    @State private var timeString = "00:00:000"
    @State private var elapsedTime: TimeInterval = 0.0
    @State private var showLeaderboard = false
    
    
    private let breedNames = ["Dalmatian", "Greyhound"]
    private let backgroundOptions = ["blue", "city", "jungle", "beach", "space", "desert"]
    private let tiltAngle: Double = 10
    private let scaleSize = 0.03
    private let animationDuration: Double = 0.1
    private let boopsCompletedNumber: Double = 10
    private let timerInterval = 0.01
    
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
            let scoreValue = Int(1000000 * elapsedTime)
            try await GKLeaderboard.submitScore(
                scoreValue,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: ["boopers_1"]
            )
        } catch {
            print("Error submitting score to leaderboard: \(error)")
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
                    
                    
                    HStack{
                        if !showLeaderboard {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                                .scaleEffect(1)
                            
                            ProgressView(value: min(Double(boopCounter) / boopsCompletedNumber, 1.0))
                                .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                                .scaleEffect(x: 1, y: 2)
                            
                            Text(timeString)
                                .foregroundColor(Color.white)
                                .font(Font.system(size: min(geometry.size.width, geometry.size.height) * 0.05, weight: .bold, design: .monospaced))
                                .padding(10)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white, lineWidth: 5)
                                )
                        }
                        
                        Button(action: {
                            withAnimation {
                                showLeaderboard.toggle()
                            }
                        }) {
                            Image(systemName: showLeaderboard ? "chevron.right" : "chevron.left")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(10)
                        
                        if showLeaderboard{
                            ScrollView(.horizontal) {
                                HStack{
                                    Text("LEASDER 1")
                                    Text("LEASDER 2")
                                    Text("LEASDER 3")
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    
                    LeadersTileView()
                    Dog(
                        boopCounter: $boopCounter,
                        selectedBreed: $selectedBreed
                    )
                    
                }
                
                if showModal {
                    ModalView(showModal: $showModal, boopCounter: $boopCounter, timeString:$timeString, elapsedTime: $elapsedTime)
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
//                    Task {
//                        await submitScoreToLeaderboard()
//                    }
                }
                if newValue == 1 {
                    startTimer()
                }
            }
        }
    }
}

struct ModalView: View {
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
                    timeString = "00:00:000"
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

