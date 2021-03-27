extension String {
    static func | (left: String, right: String) -> Condition<String, String> {
        return Condition(value: left, given: right)
    }
}

let c: Condition<String, String> = "house" | "the"

