//
// Copyright (c) 2023 DEPT Digital Products, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

extension Int: DefaultsRawVAlue {}
extension Bool: DefaultsRawVAlue {}
extension String: DefaultsRawVAlue {}
extension Data: DefaultsRawVAlue {}

public protocol DefaultsValue: Equatable {
    associatedtype RawDefaultsValue
    var rawDefaultsValue: RawDefaultsValue? { get }
    static func defaultsValue(_ rawValue: RawDefaultsValue) -> Self?
}

public extension DefaultsValue {
    static func defaultsValue(_ rawValue: RawDefaultsValue?) -> Self? {
        return rawValue.flatMap { defaultsValue($0) }
    }
}

public protocol DefaultsRawVAlue: DefaultsValue where RawDefaultsValue == Self {
}

public extension DefaultsRawVAlue {
    var rawDefaultsValue: Self? {
        self
    }

    static func defaultsValue(_ rawValue: RawDefaultsValue) -> Self? {
        return rawValue
    }
}

public protocol DefaultsJSONValue: DefaultsValue, Codable where RawDefaultsValue == Data {
}

public extension DefaultsJSONValue {
    var rawDefaultsValue: Data? {
        maybe { try JSONEncoder().encode(self) }
    }

    static func defaultsValue(_ rawValue: Data) -> Self? {
        maybe { try JSONDecoder().decode(Self.self, from: rawValue) }
    }
}

public extension UserDefaults {
    func decode<T: DefaultsValue>(_ key: String) -> T? {
        guard let rawValue = value(forKey: key) as? T.RawDefaultsValue else { return nil }
        return T.defaultsValue(rawValue)
    }

    func encode<T: DefaultsValue>(_ value: T, forKey key: String) {
        let savedValue: T? = decode(key)
        if value != savedValue {
            set(value.rawDefaultsValue, forKey: key)
        }
    }
}
