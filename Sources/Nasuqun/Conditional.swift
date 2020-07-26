public protocol Conditional {
    
    associatedtype ValueType: Hashable
    associatedtype GivenType: Hashable
    
    func callAsFunction(_ condition: Condition<ValueType, GivenType>) -> Float
}

public protocol Posterior {
    func callAsFunction(_ condition: Condition<String, String>) -> Float
}
