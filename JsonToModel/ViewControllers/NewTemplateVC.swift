//
//  NewTemplateVC.swift
//  JsonToModel
//
//  Created by Chandan Karmakar on 25/03/20.
//  Copyright © 2020 Chandan. All rights reserved.
//

import Cocoa
import SavannaKit

class NewTemplateVC: NSViewController {
    
    @IBOutlet weak var tfName: NSTextField!
    @IBOutlet weak var popupLang: NSPopUpButton!
    @IBOutlet weak var tfTemplate: SyntaxTextView!
    @IBOutlet weak var btnDelete: NSButton!
    
    var inputTemplate: TemplateBean?
    
    var didUpdate: (()->Void)?
    var didCreate: (()->Void)?
    var didDelete: (()->Void)?
    
    var allLangs: [LangaugeType] = [.Swift, .Java, .Kotlin, .Dart]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupLang.removeAllItems()
        popupLang.addItems(withTitles: allLangs.map { $0.rawValue })
        
        tfTemplate.delegate = self
        tfTemplate.scrollView.drawsBackground = true
        tfTemplate.theme = MyTheme()
        
        if let temp = inputTemplate {
            tfName.stringValue = temp.name
            tfTemplate.text = temp.template
            if let index = allLangs.index(of: temp.language) {
                popupLang.selectItem(at: index)
            }
            btnDelete.isHidden = false
        } else {
            btnDelete.isHidden = true
        }
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        dismiss(nil)
    }
    
    @IBAction func actionDelete(_ sender: Any) {
        guard let temp = inputTemplate else { return }
        let savedList = LocalVars.savedTemplates
        if let index = savedList?.list.firstIndex(where: {
            $0.date == temp.date
        }) {
            savedList?.list.remove(at: index)
            LocalVars.savedTemplates = savedList
            dismiss(nil)
            didDelete?()
        }
    }
    
    @IBAction func actionCreate(_ sender: Any) {
        let text = tfTemplate.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = tfName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            return
        }
        if text.isEmpty {
            return
        }
        if popupLang.indexOfSelectedItem == -1 {
            return
        }
        
        let list = LocalVars.savedTemplates ?? TemplateList()
        if inputTemplate == nil {
            let template = TemplateBean(n: name, t: text, l: allLangs[popupLang.indexOfSelectedItem], isUser: true)
            list.list.insert(template, at: 0)
        } else {
            inputTemplate?.name = name
            inputTemplate?.template = text
            inputTemplate?.language = allLangs[popupLang.indexOfSelectedItem]
        }
        
        LocalVars.savedTemplates = list
        dismiss(nil)
        
        if inputTemplate == nil {
            didCreate?()
        } else {
            didUpdate?()
        }
    }
}

extension NewTemplateVC: SyntaxTextViewDelegate {
    func didChangeText(_ syntaxTextView: SyntaxTextView) {}
    
    func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {}
    
    func lexerForSource(_ source: String) -> Lexer {
        return ViewController.lexer
    }
}
