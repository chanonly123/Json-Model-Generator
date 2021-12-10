//
//  UITests.swift
//  UITests
//
//  Created by Chandan Karmakar on 10/12/21.
//  Copyright © 2021 Chandan. All rights reserved.
//

import XCTest

class UITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        
        let jsonToModelV15Window2 = app.windows.firstMatch
        let jsonToModelV15Window = jsonToModelV15Window2
        jsonToModelV15Window.doubleClick()
        app.menuBars.menuBarItems["JsonToModel"].click()
        
        let splitGroup = jsonToModelV15Window.children(matching: .splitGroup).element
        let popUpButton = splitGroup.children(matching: .splitGroup).element.children(matching: .popUpButton).element
        popUpButton.click()
        popUpButton.click()
        jsonToModelV15Window2/*@START_MENU_TOKEN@*/.menuItems["Codable Simple | Swift"]/*[[".splitGroups",".popUpButtons",".menus.menuItems[\"Codable Simple | Swift\"]",".menuItems[\"Codable Simple | Swift\"]"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.click()
        jsonToModelV15Window2/*@START_MENU_TOKEN@*/.buttons["info"]/*[[".splitGroups.buttons[\"info\"]",".buttons[\"info\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        app.dialogs["Untitled"].buttons[XCUIIdentifierCloseWindow].click()
        
        let sameRadioButton = jsonToModelV15Window2/*@START_MENU_TOKEN@*/.radioButtons["same"]/*[[".splitGroups",".radioGroups.radioButtons[\"same\"]",".radioButtons[\"same\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        sameRadioButton.click()
        jsonToModelV15Window2/*@START_MENU_TOKEN@*/.radioButtons["aB"]/*[[".splitGroups",".radioGroups.radioButtons[\"aB\"]",".radioButtons[\"aB\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
        splitGroup.click()
        jsonToModelV15Window2/*@START_MENU_TOKEN@*/.radioButtons["AB"]/*[[".splitGroups",".radioGroups.radioButtons[\"AB\"]",".radioButtons[\"AB\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let pathButton = jsonToModelV15Window2/*@START_MENU_TOKEN@*/.buttons["path"]/*[[".splitGroups.buttons[\"path\"]",".buttons[\"path\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        pathButton.click()
        jsonToModelV15Window2/*@START_MENU_TOKEN@*/.buttons["list view"]/*[[".splitGroups.buttons[\"list view\"]",".buttons[\"list view\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        pathButton.click()
        jsonToModelV15Window2/*@START_MENU_TOKEN@*/.buttons["New template"]/*[[".splitGroups.buttons[\"New template\"]",".buttons[\"New template\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let sheetsQuery = jsonToModelV15Window.sheets
        sheetsQuery.children(matching: .textField).element.typeText("Testing 2")
        sheetsQuery.children(matching: .popUpButton).element.click()
        jsonToModelV15Window2.sheets/*@START_MENU_TOKEN@*/.menuItems["Java"]/*[[".popUpButtons",".menus.menuItems[\"Java\"]",".menuItems[\"Java\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let textView = sheetsQuery.scrollViews.children(matching: .textView).element
        textView.click()
        textView.typeText("Just testing ")
        sheetsQuery.buttons["Create"].click()
        sameRadioButton.click()
        
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
