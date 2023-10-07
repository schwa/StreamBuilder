import Foundation

@resultBuilder
public struct StreamBuilder {

    public static func buildBlock() -> EmptyElement {
        return EmptyElement()
    }

    public static func buildBlock<Content>(_ content: Content) -> Content where Content: StreamElement {
        return content
    }
    
    //    public static func buildBlock<each Content>(_ content: repeat each Content) -> ListElement<AnyElement> where repeat each Content: StreamElement {
    //        fatalError()
    //    }

    public static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> TupleElement2<C0, C1> where C0: StreamElement, C1: StreamElement {
        return TupleElement2(content: (c0, c1))
    }

    public static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleElement3<C0, C1, C2> where C0: StreamElement, C1: StreamElement, C2: StreamElement {
        return TupleElement3(content: (c0, c1, c2))
    }

    public static func buildExpression<Content>(_ content: Content) -> Content where Content: StreamElement {
        return content
    }

    public static func buildIf<Content>(_ content: Content?) -> Content? where Content : StreamElement {
        fatalError()
    }

    public static func buildEither<TrueContent, FalseContent>(first: TrueContent) -> ConditionalElement<TrueContent, FalseContent> where TrueContent : StreamElement, FalseContent : StreamElement {
        fatalError()
    }

    public static func buildEither<TrueContent, FalseContent>(second: FalseContent) -> ConditionalElement<TrueContent, FalseContent> where TrueContent : StreamElement, FalseContent : StreamElement {
        fatalError()
    }

    public static func buildLimitedAvailability<Content>(_ content: Content) -> AnyElement where Content : StreamElement {
        fatalError()
    }
}

// MARK: -

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

// MARK: -

public struct Group <Content>: StreamElement where Content: StreamElement {
    let content: Content

    public init(@StreamBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some StreamElement {
        EmptyElement()
    }
}

extension Group: StringAtomConvertable {
    public var atom: StringAtom {
        return .atoms([.incrementDepth, content.makeAtom(), .decrementDepth])
    }
}

// MARK: -

public struct Stack <Content>: StreamElement where Content: StreamElement {
    let content: Content
    
    public init(@StreamBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some StreamElement {
        EmptyElement()
    }
}

extension Stack: StringAtomConvertable {
    public var atom: StringAtom {
        return .atoms([.pushDelimiter("\n"), content.makeAtom(), .popDelimiter])
    }
}

// MARK: -

public struct Text: StreamElement {
    let string: String
    
    public init(_ string: String) {
        self.string = string
    }
    
    public var body: some StreamElement {
        EmptyElement()
    }
}

extension Text: StringAtomConvertable {
    public var atom: StringAtom {
        return .string(string)
    }
}

// MARK: -

public struct Labeled <Label, Content>: StreamElement where Label: StreamElement, Content: StreamElement {
    var label: Label
    var content: Content
    
    public init(@StreamBuilder label: () -> Label, @StreamBuilder content: () -> Content) {
        self.label = label()
        self.content = content()
    }
    
    public var body: some StreamElement {
        EmptyElement()
    }
}

public extension Labeled where Label == Text {
    init(label: String, @StreamBuilder content: () -> Content) {
        self = .init(label: {
            Text(label)
        }, content: content)
    }
}

public extension Labeled where Label == Text, Content == Text {
    init(label: String, content: String) {
        self = .init(label: {
            Text(label)
        }, content: {
            Text(content)
        })
    }
}

extension Labeled: StringAtomConvertable {
    public var atom: StringAtom {
        return .atoms([.pushDelimiter(""), label.makeAtom(), .string(": "), content.makeAtom(), .popDelimiter])
    }
}


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

// MARK: -

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
