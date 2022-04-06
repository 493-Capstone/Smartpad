//
//  ConnectionDataTest.swift
//  Smartpad-iOSTests
//
//  Created by Alireza Azimi on 2022-03-13.
//

import XCTest

@testable import Smartpad_iOS

class ConnectionDataTest: XCTestCase {
    override func tearDown() {
        super.tearDown()
        resetDefaults()
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    func testSetCurrentDeviceName() {
        // Arrange
        let data = ConnectionData()
        // Act
        let name = "my iPhone"
        data.setDeviceName(name: name)
        //Assert
        XCTAssertEqual(UserDefaults.standard.string(forKey: ConnectionKeys.currDeviceName), "my iPhone")
    }
    
    func testGetCurrentDeviceName() {
        //Arrange
        resetDefaults()
        let data = ConnectionData()
        // Act
        let name = "my iPhone"
        data.setDeviceName(name: name)
        //Assert
        XCTAssertEqual(data.getDeviceName(), "my iPhone")
    }
    
    func testSetCurrentDeviceUUID() {
        // Arrange
        resetDefaults()
        let uuidString = UUID().uuidString
        let data = ConnectionData()
        // Act
        data.setCurrentDeviceUUID(uuid: uuidString)
        // Assert
        XCTAssertEqual(UserDefaults.standard.string(forKey: ConnectionKeys.currDeviceUUID), uuidString)
    }
    
    func testGetCurrentDeviceUUID() {
        // Arrange
        resetDefaults()
        let uuidString = UUID().uuidString
        let data = ConnectionData()
        // Act
        data.setCurrentDeviceUUID(uuid: uuidString)
        // Assert
        XCTAssertEqual(data.getCurrentDeviceUUID(), uuidString)
    }

    func testSetPeerName() {
        // Arrange
        resetDefaults()
        let data = ConnectionData()
        // Act
        data.setSelectedPeer(name: "Ali's macbook")
        // Assert
        XCTAssertEqual(UserDefaults.standard.string(forKey: ConnectionKeys.selectedPeerName), "Ali's macbook")
    }
    
    func testGetPeerName() {
        // Arrange
        resetDefaults()
        let data = ConnectionData()
        // Act
        data.setSelectedPeer(name: "Ali's macbook")
        // Assert
        XCTAssertEqual(data.getSelectedPeer(), "Ali's macbook")
    }
}
