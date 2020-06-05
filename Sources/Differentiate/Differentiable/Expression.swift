public struct Expression {
    let operation: String
    let inputs: [Differentiable]
    let innerFunc: () -> Differentiable?
    let valueFunc: () -> Double
    let derivative: (Double, Variable) -> Double

    public init (operation: String, inputs: [Differentiable], inner: Differentiable? = nil, value: @escaping () -> Double, derivative: @escaping (Double, Variable) -> Double) {
        self.operation = operation
        self.inputs = inputs
        self.valueFunc = value
        self.derivative = derivative
        
        if inputs.count == 1 && inner == nil {
            self.innerFunc = { inputs[0] }
        } else {
            self.innerFunc = { inner }
        }
    }

    public init (operation: String, inputs: [Differentiable], inner: @escaping () -> Differentiable?, value: @escaping () -> Double, derivative: @escaping (Double, Variable) -> Double) {
        self.operation = operation
        self.inputs = inputs
        self.innerFunc = inner
        self.valueFunc = value
        self.derivative = derivative
    }

    public func compound(operation: String, inputs: [Differentiable], inner: Differentiable? = nil) -> Expression {
        return Expression(operation: operation,
            inputs: inputs,
            inner: inner == nil ? self.innerFunc : { inner },
            value: self.valueFunc,
            derivative: self.derivative
        )
    }

    public func compound(operation: String, inputs: [Differentiable], inner: @escaping () -> Differentiable?) -> Expression {
        return Expression(operation: operation,
            inputs: inputs,
            inner: innerFunc,
            value: self.valueFunc,
            derivative: self.derivative
        )
    }
}

extension Expression: Differentiable {
    public var value: Double {
        return valueFunc()
    }

    public var isCurrentlyComputing: Bool {
        for input in inputs {
            if input.isCurrentlyComputing { return true }
        }

        return false
    }

    public func dy(d x: Variable) -> Double {
        Context.currentlyComputing = x
        
        var result: Double
        if let inner = innerFunc() {
            result = derivative(inner.value, x) * inner.dy(d: x)
        } else {
            result = derivative(x.value, x)
        }
        
        Context.currentlyComputing = nil
        
        return result
    }
    
    public func dy(d xs: [Variable]) -> [Double] {
        return xs.map { self.dy(d: $0) }
    }
}
