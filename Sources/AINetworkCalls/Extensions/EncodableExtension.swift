//
//  File.swift
//  
//
//  Created by Alexy Ibrahim on 9/17/22.
//

import Foundation

extension Encodable {
    public func asDictionary() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { return [:] }

        return dictionary
    }
    
    var dictionary: [String: Any]? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    
    public func asJsonString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        guard let json = try? encoder.encode(self) else { return nil }
        return String(data: json, encoding: .utf8)
    }
}
