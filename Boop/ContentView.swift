import SwiftUI
//import CoreBluetooth
import GameKit

struct ContentView: View {
    //@StateObject private var bluetoothManager = BluetoothManager()
    
    @State private var showLaunchScreen = true
    @State private var selectedBreed = "Dalmatian"
    @State private var backgroundImage: String = "blue"
    @State private var boopCounter: CGFloat = 0
    @State private var isComplete = false
    @State private var showModal = false
    @State private var timer: Timer?
    @State private var timerCounter = 0
    @State private var timeString = "00:00:00"
    
    
    //@State private var isFogOn: Bool = false
    //@State private var fogSize: CGFloat = 100
    
    private let breedNames = ["Dalmatian", "Greyhound"]
    private let backgroundOptions = ["blue", "city", "jungle", "beach", "space", "desert"]
    private let tiltAngle: Double = 10
    private let scaleSize = 0.03
    private let animationDuration: Double = 0.1
    private let boopsCompletedNumber: Double = 10
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            timerCounter += 1
            let milliseconds = timerCounter % 100
            let seconds = (timerCounter / 100) % 60
            let minutes = (timerCounter / 100) / 60
            timeString = String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
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
                            // Fog switch --
                            // HStack{
                            //      Toggle("", isOn: $isFogOn)
                            //          .labelsHidden()
                            //      Text(" Fog")
                            //          .foregroundColor(Color.white)
                            //          bold()
                            // }
                            
                            Text("Tap the dog's nose as quickly as you can to play!")
                                .foregroundColor(.white)
                                .padding(.top,2)
                            
                            
                        }
                        Spacer()
                        BackgroundPicker(backgroundImage: $backgroundImage, options: backgroundOptions)
                    }
                    .padding()
                    
                    
                    HStack{
                        
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .scaleEffect(1)
                        ProgressView(value: min(Double(boopCounter) / boopsCompletedNumber, 1.0))
                            .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                        
                        Spacer(minLength: 20)
                        
                        Text(timeString)
                            .foregroundColor(Color.white)
                            .font(Font.system(size: min(geometry.size.width, geometry.size.height) * 0.05, weight: .bold, design: .monospaced))
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.white, lineWidth: 5)
                            )
                    }
                    .padding()
                    
                    Dog(
                        boopCounter: $boopCounter,
                        selectedBreed: $selectedBreed
                        //,isFogOn: $isFogOn
                    )
                }
                
                // Modal View
                if showModal {
                    ModalView(showModal: $showModal, boopCounter: $boopCounter, timeString:$timeString, timerCounter: $timerCounter)
                }
                if showLaunchScreen{
                    AnimatedLaunchScreen(showLaunchScreen: $showLaunchScreen)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .onChange(of: boopCounter) { newValue in
                if newValue >= boopsCompletedNumber {
                    showModal = true
                    stopTimer()
                }
                if newValue == 1 {
                    startTimer()
                }
            }
            //            .onAppear {
            //                // Start Bluetooth scanning when ContentView appears
            //                bluetoothManager.startScanning()
            //            }
            //            .onDisappear {
            //                // Stop Bluetooth scanning when ContentView disappears
            //                bluetoothManager.stopScanning()
            //            }
        }
    }
}

struct ModalView: View {
    @Binding var showModal: Bool
    @Binding var boopCounter: CGFloat
    @Binding var timeString: String
    @Binding var timerCounter: Int
    
    var body: some View {
        VStack {
            VStack{
                Text("Done!")
                    .font(.largeTitle)
                    .bold()
                Text(timeString)
                Button("OK") {
                    boopCounter = 0
                    showModal = false
                    timeString = "00:00:00"
                    timerCounter = 0
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

