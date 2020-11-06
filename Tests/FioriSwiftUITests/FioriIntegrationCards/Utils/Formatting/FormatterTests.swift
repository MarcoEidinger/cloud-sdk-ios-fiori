@testable import FioriIntegrationCards
import Foundation
import XCTest

class FormatterTests: XCTestCase {

    func testFloatFormatting() throws {
        let formatter = Formatter.shared
        let formattedResult = formatter.eval(script: "format.float(50000,{decimals:2,style:'short'},'en-US')")
        XCTAssertEqual(formattedResult, "50.00K")
    }

    func testPercentageFormatting() throws {
        let formatter = Formatter.shared
        let formattedResult = formatter.eval(script: "format.percent(0.50)")
        XCTAssertEqual(formattedResult, "50%")
    }

    func testDateTimeFormatting() throws {
        let swiftDateFormatter = DateFormatter()
        swiftDateFormatter.dateFormat = "MMM d, yyyy"

        let formatter = Formatter.shared
        let formattedResult = formatter.eval(script: "format.dateTime(Date.now(), {format: 'yMMMd'})")
        XCTAssertEqual(formattedResult, swiftDateFormatter.string(from: Date()))
    }

    func testUoMFormatting() throws {
        let formatter = Formatter.shared
        let formattedResult = formatter.eval(script: "format.unit(99, 'length-kilometer')")
        XCTAssertEqual(formattedResult, "99 km")
    }
}

