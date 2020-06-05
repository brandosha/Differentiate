public struct Matrix<Element: Differentiable> {
    public typealias Dimensions = (rows: Int, columns: Int)
    
    public let dimensions: Dimensions
    let array: [[Element]]
    
    public init (_ array: [[Element]]) {
        precondition(array.count > 0, "Cannot initialize empty matrix")
        
        self.dimensions = (array.count, array[0].count)
        self.array = array
        
        precondition(array.allSatisfy { $0.count == self.dimensions.columns }, "Not a valid matrix (irregular shape)")
    }
    
    public init (dimensions: Dimensions, _ array: [Element]) {
        precondition(array.count > 0, "Cannot initialize empty matrix")
        precondition(array.count == dimensions.rows * dimensions.columns, "Array doesn't match dimensions")
        
        self.dimensions = dimensions
        
        let splitIndices = stride(from: 0, to: array.count, by: dimensions.columns)
        self.array = splitIndices.map { Array(array[$0 ..< $0 + dimensions.columns]) }
    }
    
    public func row(_ row: Int) -> [Element] {
        return array[row]
    }
    
    public func col(_ col: Int) -> [Element] {
        return array.map { $0[col] }
    }
    
    public subscript(row: Int, col: Int) -> Element {
        precondition(row < dimensions.rows && col < dimensions.columns, "Index out of bounds")
        return array[row][col]
    }
    
    public func map<T: Differentiable>(_ function: (Differentiable) -> T) -> Matrix<T> {
        var array: [[T]] = []
        
        for row in 0..<dimensions.rows {
            var newRow: [T] = []
            for val in self.row(row) {
                newRow.append(function(val))
            }
            
            array.append(newRow)
        }
        
        return Matrix<T>(array)
    }
    
    public func flattened() -> [Element] {
        return Array(array.joined())
    }
    
    public func sum() -> Differentiable {
        return flattened().reduce(0, +)
    }
}

extension Matrix: CustomStringConvertible {
    public var description: String {
        return "[\n" + array.map { "\t" + String(describing: $0) } .joined(separator: ",\n") + "\n]"
    }
}

extension Matrix where Element: DifferentiableValue {
    public static func random(dimensions: Dimensions, distribution: (Double) -> Double = { $0 }) -> Matrix {
        var array: [[Element]] = []
        
        for _ in 1...dimensions.rows {
            var inArr: [Element] = []
            for _ in 1...dimensions.columns {
                inArr.append( Element( distribution(.random(in: 0..<1)) ) )
            }
            
            array.append(inArr)
        }
        
        return Matrix(array)
    }
    
    public static func zeros(dimensions: Dimensions) -> Matrix {
        let array: [[Element]] = [[Element]](
            repeating: [Element](repeating: Element(0), count: dimensions.columns),
            count: dimensions.rows
        )
        
        return Matrix(array)
    }
}

extension Matrix where Element == Variable {
    public func descend<T>(along gradient: Matrix<T>) {
        precondition(dimensions == gradient.dimensions, "Incompatible gradient")
        
        for row in 0..<dimensions.rows {
            for col in 0..<dimensions.columns {
                self[row, col].value -= gradient[row, col].value
            }
        }
    }
    
    public func ascend<T>(along gradient: Matrix<T>) {
        descend(along: -gradient)
    }
}

extension Expression {
    public func gradient(of x: Matrix<Variable>) -> Matrix<Double> {
        let grads = self.dy(d: x.flattened())
        return Matrix(dimensions: x.dimensions, grads)
    }
}

public func *<T> (left: Differentiable, right: Matrix<T>) -> Matrix<Expression> {
    return right.map { left * $0 }
}

public func *<T> (left: Matrix<T>, right: Differentiable) -> Matrix<Expression> {
    return right * left
}

public func /<T> (left: Matrix<T>, right: Differentiable) -> Matrix<Expression> {
    return left.map { $0 / right }
}

public func +<A,B> (left: Matrix<A>, right: Matrix<B>) -> Matrix<Expression> {
    precondition(left.dimensions == right.dimensions, "Incompatible matrices")
    
    var array: [[Expression]] = []
    for row in 0..<left.dimensions.rows {
        var newRow: [Expression] = []
        for col in 0..<left.dimensions.columns {
            newRow.append(left[row, col] + right[row, col])
        }
        
        array.append(newRow)
    }
    
    return Matrix(array)
}

public func -<A, B> (left: Matrix<A>, right: Matrix<B>) -> Matrix<Expression> {
    precondition(left.dimensions == right.dimensions, "Incompatible matrices")
    
    var array: [[Expression]] = []
    for row in 0..<left.dimensions.rows {
        var newRow: [Expression] = []
        for col in 0..<left.dimensions.columns {
            newRow.append(left[row, col] - right[row, col])
        }
        
        array.append(newRow)
    }
    
    return Matrix(array)
}

public prefix func -<T> (x: Matrix<T>) -> Matrix<Expression> {
    return x.map(-)
}

public func *<A, B> (left: Matrix<A>, right: Matrix<B>) -> Matrix<Expression> {
    precondition(left.dimensions.columns == right.dimensions.rows, "Incompatible matrices")
    
    var array: [[Expression]] = []
    for row in 0..<left.dimensions.rows {
        var newRow: [Expression] = []
        for col in 0..<right.dimensions.columns {
            var sum: Expression = left[row, 0] * right[0, col]
            for i in 1..<left.dimensions.columns {
                sum = sum + left[row, i] * right[i, col]
            }
            
            newRow.append(sum)
        }
        
        array.append(newRow)
    }
    
    return Matrix(array)
}

public func &= (left: Variable, right: Differentiable) {
    left.value = right.value
}

public func &=<T> (left: Matrix<Variable>, right: Matrix<T>) {
    precondition(left.dimensions == right.dimensions, "Incompatible matrices")
    
    for row in 0..<left.dimensions.rows {
        for col in 0..<left.dimensions.columns {
            left[row, col].value = right[row, col].value
        }
    }
}

public func +=<T> (left: Matrix<Variable>, right: Matrix<T>) {
    left &= left + right
}

public func -=<T> (left: Matrix<Variable>, right: Matrix<T>) {
    left &= left - right
}
