import Foundation

public protocol DifferentiableValue: Differentiable {
    init (_: Double)
}

extension Variable: DifferentiableValue { }
extension Double: DifferentiableValue { }
extension Int: DifferentiableValue { }
