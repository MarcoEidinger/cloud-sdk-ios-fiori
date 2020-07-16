//
//  XCTestCase+Extensions.swift
//  SnapshotTestAppTests
//
//  Created by Eidinger, Marco on 7/15/20.
//  Copyright © 2020 SAP. All rights reserved.
//

import Foundation
import XCTest
import SnapshotTesting
import SwiftUI

extension XCTestCase {
    internal struct SnapshotTest {
        static var isRecordMode: Bool = false
        static var configs: [SnapshotTestViewConfig] = {
            let configs = PresetViewImageConfigs()
            return configs.phones + configs.pads
        }()
    }
}

extension XCTestCase {
    internal func assertSnapShotAsImage(
        matching vc: UIViewController,
        with style: UIUserInterfaceStyle = .light,
        on viewConfig: ViewImageConfig,
        isRecording: Bool = false,
        recordAs referenceNamePrefix: String,
        in file: StaticString
    ) {
        switch style {
        case .dark:
            assertSnapshotAtCustomDir(
                matching: vc,
                as: .image(on: viewConfig, traits: .init(userInterfaceStyle: style)),
                record: isRecording,
                file: file,
                testName: referenceNamePrefix + "_dark")
        default:
            assertSnapshotAtCustomDir(
                matching: vc,
                as: .image(on: viewConfig, traits: .init(userInterfaceStyle: style)),
                record: isRecording,
                file: file,
                testName: referenceNamePrefix + "_light")
        }
    }
}

extension XCTestCase {
    internal func assertSnapshot<V: SwiftUI.View>(_ view: V, for size: CGSize? = nil, recordAs referenceNamePrefix: String = #function, file name: StaticString = #file) {
        let vc = view.toVC(size: size)
        for c in SnapshotTest.configs {
            assertSnapShotAsImage(matching: vc, with: .dark, on: c.config, isRecording: SnapshotTest.isRecordMode, recordAs: referenceNamePrefix + c.identifier, in:name)
            assertSnapShotAsImage(matching: vc, on: c.config, isRecording: SnapshotTest.isRecordMode, recordAs: referenceNamePrefix + c.identifier, in: name)
        }
    }
}

fileprivate func assertSnapshotAtCustomDir<Value, Format>(
    matching value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, Format>,
    named name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    let snapshotDirectory = getFilePath(file)
    let failure = verifySnapshot(
        matching: try value(),
        as: snapshotting,
        named: name,
        record: recording,
        snapshotDirectory: snapshotDirectory,
        timeout: timeout,
        file: file,
        testName: testName
    )
    guard let message = failure else { return }
    XCTFail(message, file: file, line: line)
}

internal func getFilePath(_ file: StaticString) -> String {
    let currentFile = file.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
    let components = currentFile.components(separatedBy: "/")
    guard let index = components.firstIndex(of: "SnapshotTestApp") else { return "" }
    let prefix = components.dropLast(components.count - index - 1).joined(separator: "/")
    let suffixs = URL(fileURLWithPath: currentFile).deletingPathExtension().pathComponents.suffix(2)
    guard let parentFolder = suffixs.first, let currentFolder = suffixs.last else { return "" }
    return prefix + "/cloud-sdk-ios-fiori-snapshot-references" + "/" + parentFolder + "/" + currentFolder
}
