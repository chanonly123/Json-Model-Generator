//
//  Highlighter.swift
//  JsonToModel
//
//  Created by Chandan on 07/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Foundation
import SavannaKit

class MyLexer: Lexer {
    init() {}
    
    func getSavannaTokens(input: String) -> [Token] {
        var tokens = [MyToken]()
        input.enumerateSubstrings(in: input.startIndex..<input.endIndex, options: [.byWords]) { word, range, _, _ in
            if let word = word {
                let type = MyTokenType(word)
                let token = MyToken(type: type, isEditorPlaceholder: false, isPlain: false, range: range)
                tokens.append(token)
            }
        }
        return tokens
    }
}

enum MyTokenType {
    case keyword
    case type
    case normal
    
    init(_ str: String) {
        if MyTokenType.keywords.contains(str) {
            self = .keyword
        } else if MyTokenType.types.contains(str) {
            self = .type
        } else {
            self = .normal
        }
    }
    
    static let keywords: [String] = [
        "var", "class", "func", "struct", "let", "init", "init?", "required"
    ]
    
    static let types: [String] = [
        "Bool", "Int", "String", "Double", "int", "double", "void"
    ]
}

struct MyToken: Token {
    let type: MyTokenType
    let isEditorPlaceholder: Bool
    let isPlain: Bool
    let range: Range<String.Index>
}

class MyTheme: SyntaxColorTheme {
    let font = NSFont.systemFont(ofSize: 12)
    let backgroundColor = Color.white
    let lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: NSFont.systemFont(ofSize: 12), textColor: lineNumbersColor)
    let gutterStyle: GutterStyle = GutterStyle(backgroundColor: Color.white, minimumWidth: 32)
    
    private static var lineNumbersColor: Color {
        return Color.lightGray
    }
    
    func globalAttributes() -> [NSAttributedStringKey: Any] {
        var attributes = [NSAttributedStringKey: Any]()
        attributes[.font] = font
        attributes[.foregroundColor] = Color.black
        
        return attributes
    }
    
    func attributes(for token: Token) -> [NSAttributedStringKey: Any] {
        guard let myToken = token as? MyToken else { return [:] }
        
        var attributes = [NSAttributedStringKey: Any]()
        
        switch myToken.type {
        case .keyword:
            attributes[.foregroundColor] = Color.red
        case .type:
            attributes[.foregroundColor] = Color.blue
        case .normal:
            attributes[.foregroundColor] = Color.black
        }
        
        return attributes
    }
}
