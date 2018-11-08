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
    
    @IBOutlet weak var tfPrefix: NSTextField!
    @IBOutlet weak var tfRootName: NSTextField!
    @IBOutlet weak var tfInfix: NSTextField!
    
    let lexer = MyLexer()
    var converter: Converter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { [weak self] in
            guard let `self` = self else { return }
            
            self.converter = Converter()
            self.converter.libType = type
            
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
    
    @IBAction func radioButtonChanged(_ sender: AnyObject) {
    }
}

extension ViewController: SyntaxTextViewDelegate {
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        if syntaxTextView === tvJsonString {
            let text = syntaxTextView.text
            processJson(jsonString: text, type: ObjectMapper())
        }
    }
    
    func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {
    }
    
    func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
}
