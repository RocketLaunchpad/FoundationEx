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
import CoreGraphics

extension String {
    public func parseAsHexColor() throws -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        enum ParseHexError: Error {
            case mustStartWithHash
            case invalidCharCount
            case invalidComponentFormat
            case invalidArgs
        }

        func getComponent(_ remaining: Substring) throws -> (CGFloat, Substring) {
            let componentHex = remaining.prefix(2)
            guard componentHex.count == 2 else {
                throw ParseHexError.invalidComponentFormat
            }
            guard let value = Int(componentHex, radix: 16) else {
                throw ParseHexError.invalidComponentFormat
            }
            return (CGFloat(value) / 255.0, remaining.dropFirst(2))
        }

        guard self.count >= 6 else {
            throw ParseHexError.invalidCharCount
        }

        var remaining = self[...]
        if remaining.starts(with: "#") {
            remaining = remaining.dropFirst()
        }

        var red, green, blue, opacity: CGFloat
        (red, remaining) = try getComponent(remaining)
        (green, remaining) = try getComponent(remaining)
        (blue, remaining) = try getComponent(remaining)
        if remaining.isEmpty {
            opacity = 1
        }
        else {
            (opacity, remaining) = try getComponent(remaining)
            guard remaining.isEmpty else {
                throw ParseHexError.invalidComponentFormat
            }
        }

        return (red, green, blue, opacity)
    }
}
