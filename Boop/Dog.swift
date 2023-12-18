import SwiftUI
import SceneKit

struct Dog: View {
    @State private var heartIDs = [UUID]()
    @State private var tapLocations = [UUID: CGPoint]()
    @Binding var boopCounter: CGFloat
    @Binding var selectedBreed: String
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    USDZSceneView(heartIDs: $heartIDs, tapLocations: $tapLocations, boopCounter: $boopCounter,  selectedBreed: $selectedBreed)
                        .background(Color.clear)
                        .frame(width: geometry.size.width)
                        .overlay(
                            ForEach(heartIDs, id: \.self) { id in
                                if let tapLocation = tapLocations[id] {
                                    FloatingHeart()
                                        .position(x: tapLocation.x, y: tapLocation.y - 30)
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                heartIDs.removeAll { $0 == id }
                                                tapLocations.removeValue(forKey: id)
                                            }
                                        }
                                }
                            }
                        )
                        .overlay(
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "hand.tap")
                                        .resizable()
                                        .frame(width: 40, height: 45)
                                        .foregroundColor(.white)
                                        .padding()
                                }
                                Spacer()
                            }
                        )
                }
            }
        }
    }
}

struct USDZSceneView: UIViewRepresentable {
    @Binding var heartIDs: [UUID]
    @Binding var tapLocations: [UUID: CGPoint]
    @Binding var boopCounter: CGFloat
    @Binding var selectedBreed: String
    
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        
        // Load the scene
        setupScene(view: sceneView)
        
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        sceneView.addGestureRecognizer(tap)
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(rec:)))
        sceneView.addGestureRecognizer(panGesture)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the view if needed
        if context.coordinator.lastSelectedBreed != selectedBreed {
            setupScene(view: uiView)
            context.coordinator.lastSelectedBreed = selectedBreed
        }
    }
    
    private func setupScene(view: SCNView) {
        // Load the scene
        if let scene = SCNScene(named: "\(selectedBreed).usdz") {
            view.scene = scene
        }
        
        view.backgroundColor = UIColor.clear
        view.autoenablesDefaultLighting = true
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, heartIDs: $heartIDs, tapLocations: $tapLocations)
    }
    
    class Coordinator: NSObject {
        var parent: USDZSceneView
        @Binding var heartIDs: [UUID]
        @Binding var tapLocations: [UUID: CGPoint]
        
        var lastSelectedBreed: String
        
        let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
        
        init(_ parent: USDZSceneView, heartIDs: Binding<[UUID]>, tapLocations: Binding<[UUID: CGPoint]>) {
            self.parent = parent
            self._heartIDs = heartIDs
            self._tapLocations = tapLocations
            self.lastSelectedBreed = ""
        }
        
        @objc func handleTap(rec: UITapGestureRecognizer) {
            guard let sceneView = rec.view as? SCNView else { return }
            
            if rec.state == .ended {
                let location: CGPoint = rec.location(in: sceneView)
                let hits = sceneView.hitTest(location, options: nil)
                
                
                if let tappedNode = hits.first?.node, tappedNode.name == "Nose" {
                    hapticFeedback.impactOccurred()
                    
                    // print(tappedNode.name, tappedNode.name == "Nose")
                    let newID = UUID()
                    self.heartIDs.append(newID)
                    self.tapLocations[newID] = location // Update tap location for the new ID
                    self.parent.boopCounter += 1
                    
                    if let headNode = tappedNode.parent {
                        let rotation = SCNAction.rotateBy(x: -20 * .pi / 180.0, y: 0, z: 0, duration: 0.20)
                        headNode.runAction(rotation)
                        let rotateUp = SCNAction.rotateBy(x: 20 * .pi / 180.0, y: 0, z: 0, duration: 0.10)
                        headNode.runAction(rotateUp)
                    } else {
                        print("Failed to find 'head' node.")
                    }
                } else {
                    print("Node not tapped")
                }
            }
        }
        
        @objc func handlePan(rec: UIPanGestureRecognizer) {
            guard let sceneView = rec.view as? SCNView else { return }
            
            if rec.state == .changed {
                let translation = rec.translation(in: sceneView)
                let rotation = SCNAction.rotateBy(x: 0, y: translation.x/100, z: 0, duration: 0)
                
                if let bodyNode = sceneView.scene?.rootNode.childNode(withName: "Body", recursively: true) {
                    bodyNode.runAction(rotation)
                }
                
                rec.setTranslation(CGPoint.zero, in: sceneView)
            }
        }
    }
}

