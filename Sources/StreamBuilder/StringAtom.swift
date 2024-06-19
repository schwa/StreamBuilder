import Foundation

public enum StringAtom {
    case string(String)
    case atoms([StringAtom])
    case incrementDepth
    case decrementDepth
    case pushDelimiter(String)
    case popDelimiter
}

extension StringAtom: CustomStringConvertible {
    public var description: String {
        var s = ""
        var depth = 0
        var delimiterStack: [String] = []
        toString(output: &s, depth: &depth, delimiterStack: &delimiterStack)
        return s
    }
}

public extension StringAtom {
    func toString(output: inout some TextOutputStream) {
        var depth = 0
        var delimiterStack: [String] = []
        toString(output: &output, depth: &depth, delimiterStack: &delimiterStack)
    }

    internal func toString(output: inout some TextOutputStream, depth: inout Int, delimiterStack: inout [String]) {
        switch self {
        case .string(let string):
            if depth > 0 {
                let prefix = repeatElement(" ", count: depth).joined(separator: "")
                print(prefix, terminator: "", to: &output)
            }
            print(string, terminator: "", to: &output)
            if let delimiter = delimiterStack.last {
                print(delimiter, terminator: "", to: &output)
            }
        case .atoms(let atoms):
            atoms.forEach { atom in
                atom.toString(output: &output, depth: &depth, delimiterStack: &delimiterStack)
            }
        case .incrementDepth:
            depth += 1
        case .decrementDepth:
            depth -= 1
        case .pushDelimiter(let delimiter):
            delimiterStack.append(delimiter)
        case .popDelimiter:
            _ = delimiterStack.popLast()
        }
    }
}

public protocol StringAtomConvertable {
    var atom: StringAtom { get }
}
