import CoreGraphics
import XCTest
/*@testable*/ import StreamBuilder

final class StreamBuilderTests: XCTestCase {
    func testStreamBuilder() throws {
        let stream = MyType().body
        let atom = stream.makeAtom()
        print(atom)
    }
}

struct MyType: StreamElement {
    var body: some StreamElement {
        Stack {
            Group {
                Text("A")
            }
            Text("B")
            Labeled(label: "Point", content: { CGPoint(x: 10, y: 20) })
        }
    }
}

extension CGPoint: StreamElement {
    public var body: some StreamElement {
        Labeled {
            Text("X")
        } content: {
            Text("\(x)")
        }
        Text(", ")
        Labeled {
            Text("Y")
        } content: {
            Text("\(y)")
        }

    }
}
