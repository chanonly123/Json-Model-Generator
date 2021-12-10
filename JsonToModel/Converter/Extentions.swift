//
//  Converter.swift
//  JsonToModel
//
//  Created by Chandan on 07/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Foundation

extension String {
    func to(caseType: CaseType) -> String {
        switch caseType {
        case .upperCamel:
            return toCamelCaseCapFirst()
        case .camel:
            return toCamelCase()
        case .lowerSnake:
            return toSnakeCase(lowercase: true)
        case .snake:
            return toSnakeCase(lowercase: false)
        default:
            return self
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.dropFirst()
    }
    
    func toCamelCaseCapFirst() -> String {
        return replacingOccurrences(of: "-", with: "_")
            .split(separator: "_").map({ String($0).capitalizingFirstLetter() }).joined()
    }
    
    func toCamelCase() -> String {
        var comps = replacingOccurrences(of: "-", with: "_").split(separator: "_")
        let first = comps.removeFirst()
        var last = comps.map({ return String($0).capitalizingFirstLetter() })
        last.insert(String(first), at: 0)
        return last.joined()
    }
    
    func toSnakeCase(lowercase: Bool) -> String {
        let pattern = "([a-z0-9])([A-Z])"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        let str = regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
        if lowercase {
            return str?.lowercased() ?? self
        }
        return str?.split(separator: "_").map({ String($0).capitalizingFirstLetter() }).joined(separator: "_") ?? self
    }
    
    func removeSpaceBetweenNewlines() -> String {
        let new = self.split(separator: "\n", maxSplits: Int.max, omittingEmptySubsequences: false)
            .map({
                if $0.isEmpty { return String($0) }
                else {
                    if $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        return ""
                    } else {
                        return String($0)
                    }
                }
            })
            .joined(separator: "\n")
        return new
    }
    
    func removeExtraNewlines() -> String {
        let subs = self.split(separator: "\n", maxSplits: Int.max, omittingEmptySubsequences: false)
        var new = [SubSequence]()
        var count = 0
        for each in subs {
            if each.isEmpty {
                count += 1
            } else {
                count = 0
            }
            if count < 2 {
                new.append(each)
            }
        }
        return new.joined(separator: "\n")
    }
    
    func trimTrailing() -> String {
        var copy = String(self)
        while copy.last == " " || copy.last == "\n" {
            copy = String(copy.dropLast())
        }
        return copy
    }
}

// https://stackoverflow.com/questions/42476395/how-to-split-string-using-regex-expressions
extension NSRegularExpression {
    convenience init(_ pattern: String) throws {
        try self.init(pattern: pattern, options: [])
    }
    
    /// An array of substring of the given string, separated by this regular expression, restricted to returning at most n items.
    /// If n substrings are returned, the last substring (the nth substring) will contain the remainder of the string.
    /// - Parameter str: String to be matched
    /// - Parameter n: If `n` is specified and n != -1, it will be split into n elements else split into all occurences of this pattern
    func splitn(_ str: String, _ n: Int = -1) -> [String] {
        let range = NSRange(location: 0, length: str.utf8.count)
        let matches = self.matches(in: str, range: range);
        
        var result = [String]()
        if (n != -1 && n < 2) || matches.isEmpty { return [str] }
        
        if let first = matches.first?.range {
            if first.location == 0 { result.append("") }
            if first.location != 0 {
                let _range = NSRange(location: 0, length: first.location)
                result.append(String(str[Range(_range, in: str)!]))
            }
        }
        
        for (cur, next) in zip(matches, matches[1...]) {
            let loc = cur.range.location + cur.range.length
            if n != -1 && result.count + 1 == n {
                let _range = NSRange(location: loc, length: str.utf8.count - loc)
                result.append(String(str[Range(_range, in: str)!]))
                return result
                
            }
            let len = next.range.location - loc
            let _range = NSRange(location: loc, length: len)
            result.append(String(str[Range(_range, in: str)!]))
        }
        
        if let last = matches.last?.range, !(n != -1 && result.count >= n) {
            let lastIndex = last.length + last.location
            if lastIndex == str.utf8.count { result.append("") }
            if lastIndex < str.utf8.count {
                let _range = NSRange(location: lastIndex, length: str.utf8.count - lastIndex)
                result.append(String(str[Range(_range, in: str)!]))
            }
        }
        
        return result;
    }
}

enum CaseType {
    case upperCamel, camel, snake, lowerSnake, none
}
