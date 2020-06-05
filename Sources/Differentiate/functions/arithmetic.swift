import Foundation

public func + (left: Differentiable, right: Differentiable) -> Expression {
    return Expression(operation: "+",
        inputs: [left, right],
        value: { left.value + right.value },
        derivative: { left.dy(d: $1) + right.dy(d: $1) }
    )
}

public func - (left: Differentiable, right: Differentiable) -> Expression {
    return Expression(operation: "-",
        inputs: [left, right],
        value: { left.value - right.value },
        derivative: { left.dy(d: $1) - right.dy(d: $1) }
    )
}

public prefix func - (x: Differentiable) -> Expression {
    return (0 - x).compound(operation: "-", inputs: [x])
    /*return Expression(operation: "-",
        inputs: [right],
        value: { left.value - right.value },
        derivative: { left.dy(d: $1) - right.dy(d: $1) }
    )*/
}

public func * (left: Differentiable, right: Differentiable) -> Expression {
    return Expression(operation: "*",
        inputs: [left, right],
        value: { right.value * left.value },
        derivative: { right.value * left.dy(d: $1) + left.value * right.dy(d: $1) }
    )
}

public func / (left: Differentiable, right: Differentiable) -> Expression {
    return Expression(operation: "/",
        inputs: [left, right],
        value: { left.value / right.value },
        derivative: { (right.value * left.dy(d: $1) - left.value * right.dy(d: $1)) / pow(right.value, 2) }
    )
}

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}
infix operator ** : ExponentiationPrecedence
public func ** (left: Differentiable, right: Differentiable) -> Expression {
    return Expression(operation: "^",
        inputs: [left, right],
        inner: {
            let computingLeft = left.isCurrentlyComputing
            let computingRight = right.isCurrentlyComputing
            precondition(!(computingLeft && computingRight), "can't do that type of exponent")

            if computingLeft { return left }
            else if computingRight { return right }
            else { return nil }
        },
        value: { pow(left.value, right.value) },
        derivative: { val, _ in
            let computingLeft = left.isCurrentlyComputing
            let computingRight = right.isCurrentlyComputing
            precondition(!(computingLeft && computingRight), "can't do that type of exponent")

            if computingLeft { return right.value * pow(val, right.value - 1) }
            else if computingRight { return pow(left.value, val) * log(left.value) }
            else { return 0 }
        }
    )
}

public func sqrt(_ x: Differentiable) -> Expression {
    return Expression(operation: "√",
        inputs: [x],
        value: { x.value.squareRoot() },
        derivative: { val, _ in 1 / (2 * val.squareRoot()) }
    )
}

public func exp(_ x: Differentiable) -> Expression {
    return Expression(operation: "e^",
        inputs: [x],
        value: { exp(x.value) },
        derivative: { val, _ in exp(val) }
    )
}

public func ln(_ x: Differentiable) -> Expression {
    return Expression(operation: "ln",
        inputs: [x],
        value: { log(x.value) },
        derivative: { val, _ in 1 / val }
    )
}

public func log10(_ x: Differentiable) -> Expression {
    return (ln(x) / ln(10)).compound(operation: "log10", inputs: [x])
}
