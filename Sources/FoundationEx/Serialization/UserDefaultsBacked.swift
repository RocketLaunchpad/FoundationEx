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

// MARK: - UserDefaults property wrappers

public protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}

extension UserDefaults {
    public func maybeSet<T: PropertyListRepresentable>(_ value: T, forKey key: String)  {
        if let optional = value as? AnyOptional, optional.isNil {
            removeObject(forKey: key)
        }
        else {
            set(value.encode(), forKey: key)
        }
    }
}

@propertyWrapper public struct UserDefaultsBacked<Value: PropertyListRepresentable> {
    public let key: String
    public let requireMainThread: Bool
    public var storage: UserDefaults
    public let defaultValue: Value
    public var lastValue: Value!

    var storedValue: Value {
        guard let anyValue = storage.object(forKey: key) else {
            return defaultValue
        }
        guard let encoded = anyValue as? Value.PropertyListValue else {
            assertionFailure()
            return defaultValue
        }
        return maybe(FoundationEx.env.logCodingError) { try Value.decode(encoded) } ?? defaultValue
    }

    public init(
        key: String,
        requireMainThread: Bool = true,
        storage: UserDefaults = FoundationEx.env.userDefaults,
        defaultValue: Value
    ) {
        self.key = key
        self.requireMainThread = requireMainThread
        self.storage = storage
        self.defaultValue = defaultValue
        lastValue = requireMainThread ? storedValue : defaultValue
    }

    public var wrappedValue: Value {
        get {
            requireMainThread ? lastValue : storedValue
        }
        set {
            if requireMainThread {
                assert(Thread.isMainThread)
                lastValue = newValue
            }
            storage.maybeSet(newValue, forKey: key)
        }
    }
}

public extension UserDefaultsBacked {
    init<T>(key: String, requireMainThread: Bool = true) where T? == Value {
        self = .init(key: key, requireMainThread: requireMainThread, defaultValue: nil)
    }

    init<T>(key: String, requireMainThread: Bool = true) where [T] == Value {
        self = .init(key: key, requireMainThread: requireMainThread, defaultValue: [])
    }
}
