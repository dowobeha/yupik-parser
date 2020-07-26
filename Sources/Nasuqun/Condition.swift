public struct Condition<ValueType: Hashable, GivenType: Hashable> {
    public let value: ValueType
    public let given: GivenType
}
