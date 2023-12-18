//import CoreBluetooth
//
//class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
//    private var centralManager: CBCentralManager!
//
//    @Published var discoveredPeripherals: [CBPeripheral] = []
//
//    override init() {
//        super.init()
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//    }
//
//    func startScanning() {
//        print("starting Bluetooth scan...")
//        centralManager.scanForPeripherals(withServices: nil, options: nil)
//    }
//
//    func stopScanning() {
//        centralManager.stopScan()
//    }
//
//    // MARK: - CBCentralManagerDelegate
//
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn {
//            startScanning()
//        } else {
//            stopScanning()
//        }
//    }
//
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
//        // Handle discovered peripheral
//        print(discoveredPeripherals)
//        if !discoveredPeripherals.contains(peripheral) {
//            discoveredPeripherals.append(peripheral)
//        }
//    }
//
//    // Add more delegate methods as needed...
//
//    // Note: You might need to implement other delegate methods depending on your requirements.
//}
