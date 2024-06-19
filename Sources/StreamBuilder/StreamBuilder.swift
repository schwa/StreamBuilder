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

