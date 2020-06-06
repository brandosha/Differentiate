import XCTest
@testable import Differentiate

func relu(_ x: Differentiable) -> Expression {
    return Expression(operation: "relu",
        inputs: [x],
        value: { if x.value > 0 { return x.value } else { return 0 } },
        derivative: { val, _ in if val > 0 { return 1 } else { return 0 } }
    )
}

struct Dense {
    let weights: Matrix<Variable>
    let biases: Matrix<Variable>
    
    let output: Matrix<Expression>
    
    init (input: Matrix<Variable>, outputSize: Int, activation: (Differentiable) -> Expression = Dense.activation) {
        weights = .random(dimensions: (input.dimensions.columns, outputSize))
        biases = .random(dimensions: (1, outputSize))
        
        output = (input * weights + biases).map(activation)
    }
    
    init (input: Dense, outputSize: Int, activation: (Differentiable) -> Expression = Dense.activation) {
        weights = .random(dimensions: (input.output.dimensions.columns, outputSize))
        biases = .random(dimensions: (1, outputSize))
        
        output = (input.output * weights + biases).map(activation)
    }
    
    static var activation: (Differentiable) -> Expression = relu
}

final class DifferentiateTests: XCTestCase {
    
    func testReinforceTraining() {
        measure {
            print("----------\n")
            
            let input: Matrix<Variable> = .zeros(dimensions: (1, 1))
            input[0, 0] &= 1
            
            let weights: Matrix<Variable> = .random(dimensions: (1, 3))
            let output = input * weights
            
            let lr = 0.1
            let rewards = [2.5, 5, 10]
            var totalReward = 0.0
            var randomReward = 0.0
            let iterations = 500
            for _ in 1...iterations {
                let outVals = output.row(0).map { $0.value }
                let valSum = outVals.reduce(0, +)
                let normalized = outVals.map { $0 / valSum }
                
                let p: Double = .random(in: 0..<1)
                var chosenIndex = -1
                var sum = 0.0
                while sum < p {
                    chosenIndex += 1
                    sum += normalized[chosenIndex]
                }
                chosenIndex = max(0, min(chosenIndex, outVals.count - 1))
                
                let reward = rewards[chosenIndex]
                totalReward += reward
                randomReward += rewards.randomElement()!
                let probability = normalized[chosenIndex]
                
                let gradient = output[0, chosenIndex].gradient(of: weights)
                weights += lr * reward / probability * gradient
            }
            
            print("average reward:", totalReward / Double(iterations))
            print("random agent reward:", randomReward / Double(iterations))
            
            print("\n----------")
        }
    }
    
    func testDifferentiation() {
        let a = Variable(1)
        let b = Variable(2)
        let c = Variable(3)

        let x = Variable(4)

        let y = a * x ** 2 + b * x + c
        print(y.dy(d: x)) // 10
        
        XCTAssert(y.dy(d: a) == 16)
        XCTAssert(y.dy(d: b) == 4)
        XCTAssert(y.dy(d: c) == 1)
        XCTAssert(y.dy(d: x) == 10)
    }

    static var allTests = [
        ("testReinforceTraining", testReinforceTraining),
        ("testDifferentiation", testDifferentiation)
    ]
}
