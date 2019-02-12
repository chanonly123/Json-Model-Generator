//
//  ViewController.swift
//  JsonToModel
//
//  Created by Chandan on 05/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Cocoa
import SavannaKit

class ViewController: NSViewController {
    @IBOutlet var tvCode: SyntaxTextView!
    @IBOutlet var tvJsonString: SyntaxTextView!
    @IBOutlet var tfError: NSTextField!
    
    // options class
    @IBOutlet weak var tfRootName: NSTextField!
    @IBOutlet weak var tfPrefix: NSTextField!
    @IBOutlet weak var tfSuffix: NSTextField!
    
    // options variables
    @IBOutlet weak var tfVarPrefix: NSTextField!
    @IBOutlet weak var tfVarSuffix: NSTextField!
    @IBOutlet weak var rVarStyleCamel: NSButton!
    @IBOutlet weak var rVarStyleSnake: NSButton!
    
    // Converter selection
    @IBOutlet weak var popUpConverter: NSPopUpButton!
    
    let lexer = MyLexer()
    
    var converter: Converter!
    var caseTypeClass: CaseType = .upperCamel
    var caseTypeVar: CaseType = .camel
    var converterType: Moldable = ObjectMapper()
    var classRoot = "Root"
    var classPrefix: String = ""
    var classSuffix: String = ""
    var varPrefix: String = ""
    var varSuffix: String = ""
    
    let arrConverterTypes: [ConverterType] = [.objMapper, .gloss]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfRootName.delegate = self
        tfPrefix.delegate = self
        tfSuffix.delegate = self
        tfVarPrefix.delegate = self
        tfVarSuffix.delegate = self
        
        popUpConverter.removeAllItems()
        popUpConverter.addItems(withTitles: arrConverterTypes.map({ $0.rawValue }))
        popUpConverter.target = self
        popUpConverter.action = #selector(converterTypeChanged)
        
        tvCode.delegate = self
        tvCode.scrollView.drawsBackground = true
        tvCode.theme = MyTheme()
        
        tvJsonString.delegate = self
        tvJsonString.scrollView.drawsBackground = true
        tvJsonString.theme = MyTheme()
        tvJsonString.text =
            """
                    {
                    "success": true,
                    "data": {
                    "voice_opinions": [
                    {
                    "createdAt": 1541413168000,
                    "updateAt": 1541413168000,
                    "id": 246,
                    "unique_id": "uo-5edc608309257fde",
                    "user_id": 614,
                    "hot_topic_id": 8,
                    "vote": 0,
                    "audio_id": 234,
                    "status": 1,
                    "counter_opinions": [
                    {
                    "createdAt": 1541413168000,
                    "updateAt": 1541413168000,
                    "id": 246,
                    "unique_id": "uo-5edc608309257fde",
                    "user_id": 614,
                    "hot_topic_id": 8,
                    "vote": 0,
                    "audio_id": 234,
                    "status": 1
                    }
                    ]
                    }
                    ]
                    },
                    "code": 200
                    }
            """
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func processJson(jsonString: String, type: Moldable) {
        self.converter = Converter()
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { [weak self] in
            guard let `self` = self else { return }
            
            self.converter.libType = type
            self.converter.caseTypeClass = self.caseTypeClass
            self.converter.caseTypeVar = self.caseTypeVar
            self.converter.rooClassName = self.classRoot
            self.converter.classPrefix = self.classPrefix
            self.converter.classSuffix = self.classSuffix
            self.converter.varPrefix = self.varPrefix
            self.converter.varSuffix = self.varSuffix
            
            self.converter.convertToDictionary(text: jsonString, handler: { [weak self] text, error in
                guard let `self` = self else { return }
                print("Result generated")
                if let text = text {
                    self.tvCode.text = "\(text)"
                    self.tfError.isHidden = true
                    self.tvCode.isHidden = false
                } else if let error = error {
                    self.tfError.stringValue = error
                    self.tfError.isHidden = false
                    self.tvCode.isHidden = true
                }
            })
        }
    }
    
    @IBAction func radioClassChanged(_ sender: NSButton) {
        sender.state = .on
        sender.superview?.subviews.filter({ $0 !== sender }).forEach({ ($0 as? NSButton)?.state = .off })
        if sender.tag == 0 {
            caseTypeClass = .none
        } else if sender.tag == 1 {
            caseTypeClass = .upperCamel
        } else if sender.tag == 2 {
            caseTypeClass = .lowerSnake
        }
        processJson()
    }
    
    @IBAction func radioVarChanged(_ sender: NSButton) {
        sender.state = .on
        sender.superview?.subviews.filter({ $0 !== sender }).forEach({ ($0 as? NSButton)?.state = .off })
        if sender.tag == 0 {
            caseTypeVar = .none
        } else if sender.tag == 1 {
            caseTypeVar = .camel
        } else if sender.tag == 2 {
            caseTypeVar = .lowerSnake
        }
        processJson()
    }
    
    @objc func converterTypeChanged() {
        converterType = ConverterType(rawValue: popUpConverter.titleOfSelectedItem ?? "")?.converter ?? ObjectMapper()
        processJson()
    }
    
    func processJson() {
        let text = tvJsonString.text
        processJson(jsonString: text, type: converterType)
    }
}

extension ViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        classSuffix = tfSuffix.stringValue
        classPrefix = tfPrefix.stringValue
        classRoot = tfRootName.stringValue
        varPrefix = tfVarPrefix.stringValue
        varSuffix = tfVarSuffix.stringValue
        processJson()
    }
}

extension ViewController: SyntaxTextViewDelegate {
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        if syntaxTextView === tvJsonString {
            processJson()
        }
    }
    
    func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {
    }
    
    func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
}

enum ConverterType: String {
    case objMapper = "Objective Mapper", gloss = "Gloss"
    var converter: Moldable {
        switch self {
        case .objMapper:
            return ObjectMapper()
        case .gloss:
            return Gloss()
        }
    }
}
