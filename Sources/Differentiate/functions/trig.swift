import Foundation

public func sin(_ x: Differentiable) -> Expression {
    return Expression(operation: "sin",
        inputs: [x],
        value: { sin(x.value) },
        derivative: { val, _ in cos(val) }
    )
}

public func cos(_ x: Differentiable) -> Expression {
    return Expression(operation: "cos",
        inputs: [x],
        value: { cos(x.value) },
        derivative: { val, _ in -sin(val) }
    )
}

public func tan(_ x: Differentiable) -> Expression {
    return (sin(x) / cos(x)).compound(operation: "tan", inputs: [x])
}

public func csc(_ x: Differentiable) -> Expression {
    return (1 / sin(x)).compound(operation: "csc", inputs: [x])
}

public func sec(_ x: Differentiable) -> Expression {
    return (1 / cos(x)).compound(operation: "sec", inputs: [x])
}

public func cot(_ x: Differentiable) -> Expression {
    return (1 / tan(x)).compound(operation: "cot", inputs: [x])
}

public func asin(_ x: Differentiable) -> Expression {
    return Expression(operation: "asin",
        inputs: [x],
        value: { asin(x.value) },
        derivative: { val, _ in 1 / (1 - pow(val, 2)).squareRoot() }
    )
}

public func acos(_ x: Differentiable) -> Expression {
    return Expression(operation: "asin",
        inputs: [x],
        value: { acos(x.value) },
        derivative: { val, _ in -1 / (1 - pow(val, 2)).squareRoot() }
    )
}

public func atan(_ x: Differentiable) -> Expression {
    return Expression(operation: "asin",
        inputs: [x],
        value: { atan(x.value) },
        derivative: { val, _ in 1 / (1 + pow(val, 2)) }
    )
}
