//
//  VMDataSourceTests.swift
//  VMDataSource_Tests
//
//  Created by Cloy Vserv on 03/12/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import VMDataSource

class VMDataSourceTests: XCTestCase {
    let sut = MarvelDataSource()
    override func setUpWithError() throws {
    }
    override func tearDownWithError() throws {
        sut.clearCache()
    }
    func testDataSource() {
        sut.fetch(from: 0) { result in
            switch result{
            case .success(let heros):
                print("heros count:\(heros.count)")
                XCTAssertEqual(heros.count, 100)
            case .failure(_):
                XCTFail("No Data")
            }
        }
    }
}
