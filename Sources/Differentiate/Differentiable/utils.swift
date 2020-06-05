struct Context {
    static var currentlyComputing: Variable? = nil
}

extension Variable: CustomStringConvertible {
    public var description: String {
        if let name = name { return name }
        else { return "(\(value))" }
    }
}

extension Expression: CustomStringConvertible {
    public var description: String {
        if inputs.count == 1 {
            return operation + "(\(inputs[0]))"
        } else {
            return "(" + inputs.map { String(describing: $0) } .joined(separator: operation) + ")"
        }
    }
}

extension Int: Differentiable {
    public var value: Double { return Double(self) }
    public var isCurrentlyComputing: Bool { return false }
    public func dy(d x: Variable) -> Double { return 0 }
}

extension Double: Differentiable {
    public var value: Double { return self }
    public var isCurrentlyComputing: Bool { return false }
    public func dy(d x: Variable) -> Double { return 0 }
}
