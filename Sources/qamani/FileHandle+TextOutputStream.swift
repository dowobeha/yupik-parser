//public struct StandardErrorOutputStream: TextOutputStream {
//    public mutating func write(_ string: String) { fputs(string, stderr) }
//}
//
//public var stderr = StandardErrorOutputStream()

import Foundation

// var stderr = FileHandle.standardError

extension FileHandle : TextOutputStream {
  public func write(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    self.write(data)
  }
}
