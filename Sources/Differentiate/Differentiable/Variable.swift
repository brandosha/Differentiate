public class Variable: Differentiable {
    public var value: Double
    public var name: String?

    public init (_ value: Double, name: String) {
        self.value = value
        self.name = name
    }
    
    public required init(_ value: Double) {
        self.value = value
    }

    public var isCurrentlyComputing: Bool {
        return Context.currentlyComputing === self
    }

    public func dy(d x: Variable) -> Double {
        if x === self { return 1 }
        else { return 0 }
    }
}
