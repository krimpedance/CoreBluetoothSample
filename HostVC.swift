//
//  HostVC.swift
//  ThrowMusic
//
//  Copyright © 2016年 Krimpedance. All rights reserved.
//

import UIKit
import CoreBluetooth

class HostVC: UIViewController {

    var peripheralManager: CBPeripheralManager!
    var service: CBMutableService!

    var characteristic: CBMutableCharacteristic {
        let characteristicUUID = CBUUID(string: "0001")
        let properties: CBCharacteristicProperties = [.Notify, .Read, .Write]
        let permissions: CBAttributePermissions = [.Readable, .Writeable]
        return CBMutableCharacteristic(type: characteristicUUID, properties: properties, value: nil, permissions: permissions)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPeripheralManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


/**
 *  Actions -------------------
 */
extension HostVC {
    func setUpPeripheralManager() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        setUpService()
    }

    func setUpService() {
        let serviceUUID = CBUUID(string: "0000")
        service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [characteristic]
    }

    func startAdvertisement() {
        let data: [String: AnyObject] = [
            CBAdvertisementDataLocalNameKey: UIDevice.currentDevice().name,
            CBAdvertisementDataServiceUUIDsKey: [service.UUID]
        ]
        peripheralManager.startAdvertising(data)
    }

    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }
}


/**
 *  CBPeripheralManager delegate -------------------
 */
extension HostVC: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        let enumName = "CBPeripheralManagerState."
        var valueName = ""
        switch peripheralManager.state {
        case .PoweredOff:
            valueName = enumName + "PoweredOff"
        case .PoweredOn:
            valueName = enumName + "PoweredOn"

            //このタイミングでペリフェラルにサービスを追加するようにしないと失敗する
            peripheralManager.addService(service)

        case .Resetting:
            valueName = enumName + "Resetting"
        case .Unauthorized:
            valueName = enumName + "Unauthorized"
        case .Unknown:
            valueName = enumName + "Unknown"
        case .Unsupported:
            valueName = enumName + "Unsupported"
        }
        print(valueName)
    }

    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if let error = error {
            print("Failed... error: \(error)")
            return
        }
        print("Successed!")
    }

    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if let error = error {
            print("サービス追加失敗！ error: \(error)")
            return
        }
        print("サービス追加成功！")
        startAdvertisement()
    }

    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        var data: NSData?
        for request in requests {
            if request.characteristic.UUID.isEqual(characteristic.UUID) {
                data = request.value
            }
        }
        peripheralManager.respondToRequest(requests[0], withResult: .Success)

        let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
        print(string)
    }
}
