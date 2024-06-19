import CoreGraphics
import XCTest
/*@testable*/ import StreamBuilder

final class StreamBuilderTests: XCTestCase {
    func testStreamBuilder1() throws {
        let stream = MyType().body
        let atom = stream.makeAtom()
        print(atom)
    }

    func testStreamBuilder2() throws {
        VStack {
            Divider()
            Text("Hello")
            Labeled(label: "Name", content: { Text("Content")} )

//            Divider()
        }
        .print()
    }
}

struct Divider: StreamElement {
    var body: some StreamElement {
        Text("---------------------------------------")
    }
}

struct MyType: StreamElement {
    var body: some StreamElement {
        VStack {
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
        HStack {
            Labeled {
                Text("X")
            } content: {
                Text("\(x)")
            }
            Text(",")
            Labeled {
                Text("Y")
            } content: {
                Text("\(y)")
            }
        }
    }
}
