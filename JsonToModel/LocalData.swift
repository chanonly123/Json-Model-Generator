//
//  LocalData.swift
//  JsonToModel
//
//  Created by Chandan Karmakar on 25/03/20.
//  Copyright © 2020 Chandan. All rights reserved.
//

import Foundation

class LocalVars {
    
    @LocalVarCodable(key: "savedTemplates")
    static var savedTemplates: TemplateList?
}

@propertyWrapper
struct LocalVarCodable<Type: Codable> {
    let key: String
    let loc: UserDefaults = UserDefaults.standard
    var actualValue: Type?
    
    var wrappedValue: Type? {
        set {
            actualValue = newValue
            if let obj = newValue {
                if let data = try? JSONEncoder().encode(obj) {
                    loc.set(data, forKey: key)
                    loc.synchronize()
                }
            } else {
                loc.set(nil, forKey: key)
                loc.synchronize()
            }
        }
        mutating get {
            if actualValue == nil {
                if let data = loc.value(forKey: key) as? Data {
                    actualValue = try? JSONDecoder().decode(Type.self, from: data)
                }
            }
            return actualValue
        }
    }
}

