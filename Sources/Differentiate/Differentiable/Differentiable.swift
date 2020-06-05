public protocol Differentiable {
    var value: Double { get }
    var isCurrentlyComputing: Bool { get }
    func dy(d x: Variable) -> Double
}
