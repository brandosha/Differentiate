# Differentiate

### Automatic differentiation in Swift
Find the partial derivative of an expression with `dy(d x: Variable)`

#### Example
```swift
let a = Variable(1)
let b = Variable(2)
let c = Variable(3)

let x = Variable(4)

let y = a * x ** 2 + b * x + c
print(y.dy(d: x)) // 10
```

`Variable`s can be changed by setting their `value` property
```
x.value = 2
```
