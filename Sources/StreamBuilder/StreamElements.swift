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

public struct HStack <Content>: StreamElement where Content: StreamElement {
    let content: Content
    let spacing: Int

    public init(spacing: Int = 1, @StreamBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some StreamElement {
        EmptyElement()
    }
}

extension HStack: StringAtomConvertable {
    public var atom: StringAtom {
        return .atoms([.pushDelimiter(String(repeating: " ", count: spacing)), content.makeAtom(), .popDelimiter])
    }
}

// MARK:-

public struct VStack <Content>: StreamElement where Content: StreamElement {
    let content: Content

    public init(@StreamBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some StreamElement {
        EmptyElement()
    }
}

extension VStack: StringAtomConvertable {
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

public struct Labeled <Label, Content> where Label: StreamElement, Content: StreamElement {
    var label: Label
    var content: Content

    public init(@StreamBuilder label: () -> Label, @StreamBuilder content: () -> Content) {
        self.label = label()
        self.content = content()
    }
}

extension Labeled: StreamElement {
    public var body: some StreamElement {
        Swift.print(type(of: content))
        return HStack(spacing: 0) {
            label
            Text(": ")
            content
        }
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

