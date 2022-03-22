//
//  ConnectionDataTest.swift
//  Smartpad-iOSTests
//
//  Created by Alireza Azimi on 2022-03-13.
//

import XCTest

@testable import Smartpad_iOS

class ConnectionDataTest: XCTestCase {
    override func setUp(){
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()

        
    }

    override func tearDown(){
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

    func testDataSet() throws {
        // Arrange
        let data = ConnectionData()
        // Act
        let uuidValue = "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d"
        data.setSelectedDeviceUUID(uuid: uuidValue)
        //Assert
        XCTAssertEqual(UserDefaults.standard.string(forKey: ConnectionKeys.connDeviceUUID), "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d")
    }
    
    func testDataGet() throws {
        // Arrange
        let data = ConnectionData()
        // Act
        let uuidValue = "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d"
        data.setSelectedDeviceUUID(uuid: uuidValue)
        //Assert
        XCTAssertEqual(data.getSelectedDeviceUUID(), "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d")
    }
    


}
