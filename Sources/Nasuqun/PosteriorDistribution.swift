import NgramLM

public struct PosteriorDistribution : Posterior {

    private let data: [GivenType: [ValueType: Weight]]
    
    public init(_ data: [GivenType: [ValueType: Weight]]) {
        self.data = data
    }
    
    public typealias ValueType = String
    public typealias GivenType = String
    
    public func callAsFunction(_ condition: Condition<ValueType, GivenType>) -> Weight {
        if let values: [ValueType: Weight] = self.data[condition.given] {
            if let weight: Weight = values[condition.value] {
                return weight
            } else {
                return Weight(0.0)
            }
        } else {
            return Weight(0.0)
        }
    }
    
}
