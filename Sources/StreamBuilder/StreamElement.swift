import Foundation

public protocol StreamElement {
    associatedtype Body: StreamElement
    @StreamBuilder /*@MainActor*/ var body: Self.Body { get }
}

// MARK: -

extension Never: StreamElement {
    public var body: Never {
        fatalError()
    }
}

// MARK: -

public struct EmptyElement: StreamElement {
    public var body: Never {
        fatalError()
    }
}

public extension StreamElement {
    func makeAtom() -> StringAtom {
        if let self = self as? StringAtomConvertable {
            return self.atom
        }
        else {
            return self.body.makeAtom()
        }
    }
}

// MARK: -

//extension TupleElement: StringAtomConvertable {
//    public var atom: StringAtom {
//
//
//
//
//        return .string("TUPLE YO")
//    }
//}

public protocol CustomStreamConvertable {
    associatedtype Content: StreamElement
    @StreamBuilder
    var stream: Content { get }
}

extension CustomStringConvertible where Self: CustomStreamConvertable {
    public var description: String {
        stream.makeAtom().description
    }
}

public extension StreamElement {
    func print(to output: inout some TextOutputStream) {
        makeAtom().toString(output: &output)
    }

    func print() {
        var s = ""
        makeAtom().toString(output: &s)
        Swift.print(s, terminator: "")
    }
}

// MARK: -

public struct ListElement <T>: StreamElement where T: StreamElement {
    var content: [T]

    public init(_ content: [T]) {
        self.content = content
    }

    public var body: some StreamElement {
        EmptyElement()
    }
}

extension ListElement: StringAtomConvertable {
    public var atom: StringAtom {
        return .atoms(content.map({ $0.makeAtom() }))
    }
}

// https://github.com/apple/swift-evolution/blob/main/proposals/0393-parameter-packs.md
// https://github.com/apple/swift-evolution/blob/main/proposals/0398-variadic-types.md
// https://github.com/apple/swift-evolution/blob/main/proposals/0399-tuple-of-value-pack-expansion.md
// https://github.com/apple/swift-evolution/blob/main/proposals/0408-pack-iteration.md
//public struct TupleElement <each T>: StreamElement {
//    let content: (repeat each T)
//    public var body: some StreamElement {
//        EmptyElement()
//    }
//}

public struct TupleElement2 <T1, T2>: StreamElement where T1: StreamElement, T2: StreamElement {
    let content: (T1, T2)

    public var body: some StreamElement {
        ListElement<AnyElement>([AnyElement(content.0), AnyElement(content.1)])
    }
}

public struct TupleElement3 <T1, T2, T3>: StreamElement where T1: StreamElement, T2: StreamElement, T3: StreamElement {
    let content: (T1, T2, T3)

    public var body: some StreamElement {
        ListElement<AnyElement>([AnyElement(content.0), AnyElement(content.1), AnyElement(content.2)])
    }
}

public struct ConditionalElement <LHS, RHS>: StreamElement {
    public var body: some StreamElement {
        EmptyElement()
    }
}

public struct AnyElement: StreamElement {
    var base: Any

    var _atom: () -> StringAtom

    init<T>(_ base: T) where T: StreamElement {
        self.base = base
        _atom = { base.makeAtom() }
    }

    public var body: some StreamElement {
        EmptyElement()
    }
}

extension AnyElement: StringAtomConvertable {
    public var atom: StringAtom {
        _atom()
    }
}

// MARK: -

public struct ForEach <Element, Content>: StreamElement where Content: StreamElement {
    let list: ListElement<Content>

    public init(_ data: [Element], @StreamBuilder content: (Element) -> Content) {
        list = ListElement(data.map { content($0) })
    }

    public var body: some StreamElement {
        list
    }
}
