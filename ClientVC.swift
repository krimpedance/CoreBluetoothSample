//
//  ClientVC.swift
//  ThrowMusic
//
//  Copyright © 2016年 Krimpedance. All rights reserved.
//

import UIKit
import CoreBluetooth
import AVFoundation

class ClientVC: UIViewController {

    let serviceUUID = CBUUID(string: "0000")
    let characteristicUUID = CBUUID(string: "0001")

    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


/**
 *  Actions -------------------
 */
extension ClientVC {
    func sendTestData() {
        let data = "Hello world.".dataUsingEncoding(NSUTF8StringEncoding)!
        peripheral?.writeValue(data, forCharacteristic: characteristic!, type: .WithResponse)
    }
}


/**
 *  Button actions -------------------
 */
extension ClientVC {

}


/**
 *  CBCentralManager delegate ---------------------
 */
extension ClientVC: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            centralManager = central
            centralManager.scanForPeripheralsWithServices([serviceUUID], options: nil)
        default:
            break
        }
    }

    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        guard let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] else { return }
        if serviceUUIDs.first != serviceUUID { return }
        self.peripheral = peripheral
        centralManager.connectPeripheral(peripheral, options: nil)
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected! - ", peripheral.name)
        self.peripheral!.delegate = self
        self.peripheral!.discoverServices([serviceUUID])
    }

    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("FailToConnect: ", peripheral.name, error)
    }
}


/**
 *  CBCentralManager delegate ---------------------
 */
extension ClientVC: CBPeripheralDelegate {
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let error = error {
            print("error: \(error)")
            return
        }

        guard let service = peripheral.services?.filter({ $0.UUID==serviceUUID }).first else {
            print("error: services don't contain UUID=\(serviceUUID.UUIDString)")
            return
        }
        peripheral.discoverCharacteristics([characteristicUUID], forService: service)
    }

    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let error = error {
            print("error: \(error)")
            return
        }

        guard let characteristic = service.characteristics?.filter({ $0.UUID==characteristicUUID }).first else {
            print("error: characteristics don't contain UUID=\(characteristicUUID.UUIDString)")
            return
        }
        self.characteristic = characteristic

        sendTestData()
    }

    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let error = error {
            print("Write error: \(error)")
            return
        }
        print("Writed!!")
    }
}
