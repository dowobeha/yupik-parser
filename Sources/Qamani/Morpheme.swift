
public struct Morpheme: Codable  {
    
    public let underlyingForm: String
    public let surfaceForm: String
    public let type: String
    
    public init(underlying: String, type: String, surface: String) {
        self.underlyingForm = underlying
        self.surfaceForm = surface
        self.type = type
    }

}
