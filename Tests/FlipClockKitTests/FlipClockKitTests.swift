import XCTest
@testable import FlipClockKit

final class FlipClockKitTests: XCTestCase {

    func testDigitParsing() {
        // 305 seconds = 5 min 5 sec
        let seconds = 305
        XCTAssertEqual(String(seconds / 60 / 10), "0")
        XCTAssertEqual(String((seconds / 60) % 10), "5")
        XCTAssertEqual(String((seconds % 60) / 10), "0")
        XCTAssertEqual(String(seconds % 10), "5")
    }

    func testTileHeightIsHalfFontSize() {
        let style = FlipClockStyle.default
        XCTAssertEqual(style.tileHeight, style.fontSize / 2)
    }

    func testCustomStyleOverrides() {
        let custom = FlipClockStyle(fontSize: 80, cardWidth: 60)
        XCTAssertEqual(custom.fontSize, 80)
        XCTAssertEqual(custom.tileHeight, 40)
    }
}
