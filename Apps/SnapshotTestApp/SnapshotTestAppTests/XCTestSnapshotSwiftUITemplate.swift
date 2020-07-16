//
//  XCTestSnapshotTemplate.swift
//  SnapshotTestAppTests
//
//  Created by Eidinger, Marco on 7/15/20.
//  Copyright © 2020 SAP. All rights reserved.
//

import XCTest
import SnapshotTesting
import SwiftUI

// https://www.vadimbulavin.com/snapshot-testing-swiftui-views/

private let referenceSize = CGSize(width: 500, height: 300)

@testable import SnapshotTestApp

class XCTestSnapshotSwiftUITemplate: XCTestCase {

    var isRecordMode: Bool = false
    lazy var configs: [SnapshotTestViewConfig] = {
        let configs = PresetViewImageConfigs()
        return configs.phones + configs.pads
    }()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func assert<V: SwiftUI.View>(_ view: V, for size: CGSize? = nil, recordAs referenceNamePrefix: String = #function, file name: StaticString = #file) {
        let vc = view.toVC(size: size)
        for c in configs {
            assertSnapShotAsImage(matching: vc, with: .dark, on: c.config, isRecording: isRecordMode, recordAs: referenceNamePrefix + c.identifier, in:name)
            assertSnapShotAsImage(matching: vc, on: c.config, isRecording: isRecordMode, recordAs: referenceNamePrefix + c.identifier, in: name)
        }
    }
}
