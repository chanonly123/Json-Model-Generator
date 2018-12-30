//
//  CaseConverter.swift
//  JsonToModel
//
//  Created by Chandan on 10/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Foundation

//CaseConverter.convertToCamelCase(input);     // TheQuickBrownFoxJumpsOverTheLazyDog
//CaseConverter.convertToSnakeCase(input);     // The_Quick_Brown_Fox_Jumps_Over_The_Lazy_Dog
//CaseConverter.convertToKebabCase(input);     // the-quick-brown-fox-jumps-over-the-lazy-dog
//CaseConverter.convertToStudlyCaps(input);     // thE qUIck BRoWN foX jUMPs oVeR tHe lAZY doG
//CaseConverter.invertCase(input);         // tHE QUICK BROWN FOX JUMPS OVER THE LAZY DOG


class CaseConverter {
    
    public static func convertToCamelCase(str: String) -> String {
        let throwAwayChars = "()[]{}=?!.:,-_+\\\"#~/"
        let regex = try! NSRegularExpression(pattern: throwAwayChars, options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, str.count)
        regex.stringByReplacingMatches(in: str, options: [], range: range, withTemplate: "")
        
        value = str.replaceAll("[" + Pattern.quote(throwAwayChars) + "]", " ")
        value = CaseConverter.convertToStartCase(value)
        return value.replaceAll("\\s+", "")
    }
    
    /**
     * Converts a text into snake case.
     * Example: "snake case" into "Snake_Case".
     *
     * @param value
     * @return converted string
     */
    public static String convertToSnakeCase(String value) {
        String throwAwayChars = "()[]{}=?!.:,-_+\\\"#~/"
        value = value.replaceAll("[" + Pattern.quote(throwAwayChars) + "]", " ")
        value = CaseConverter.convertToStartCase(value)
        return value.trim().replaceAll("\\s+", "_")
    }
    
    /**
     * Converts a text into kebab case.
     * Example: "Kebab Case" into "kebab-case".
     *
     * @param value
     * @return converted string
     */
    public static String convertToKebabCase(String value) {
        String throwAwayChars = "()[]{}=?!.:,-_+\\\"#~/"
        value = value.replaceAll("[" + Pattern.quote(throwAwayChars) + "]", " ")
        value = value.toLowerCase()
        return value.trim().replaceAll("\\s+", "-")
    }
    
    /**
     * Converts a text into studly caps. Studly caps is a text case where the
     * capitalization of letters varies randomly.
     * Example: "Studly Caps" into "stuDLY CaPS" or "STudLy CAps".
     *
     * @param value
     * @return converted string
     */
    public static String convertToStudlyCaps(String value) {
        StringBuilder returnValue = new StringBuilder()
        value = value.toLowerCase()
        int numOfFollowingUppercase = 0
        int numOfFollowingLowercase = 0
        boolean doCapitalLetter = false
        Random randomizer = new Random()
        for char c: value.toCharArray {
            if Character.isAlphabetic(c) {
                if numOfFollowingUppercase < 2 {
                    if randomizer.nextInt(100) % 2 == 0 {
                        doCapitalLetter = true
                        numOfFollowingUppercase++
                    } else {
                        doCapitalLetter = false
                        numOfFollowingUppercase = 0
                    }
                } else {
                    doCapitalLetter = false
                    numOfFollowingUppercase = 0
                }
                if !doCapitalLetter {
                    numOfFollowingLowercase++
                }
                if numOfFollowingLowercase > 3 {
                    doCapitalLetter = true
                    numOfFollowingLowercase = 0
                    numOfFollowingUppercase++
                }
                if doCapitalLetter {
                    c = Character.toUpperCase(c)
                }
            }
            returnValue.append(c)
        }
        return returnValue.toString()
    }
    
    /**
     * Inverts the case of a given text.
     * Converts the spelling of each letter in the reverse order:
     * lowercase letters are converted to uppercase and vice versa.
     * Example: "Inverted Case" into "iNVERTED cASE".
     *
     * @param value
     * @return converted string
     */
    public static String invertCase(String value) {
        StringBuilder returnValue = new StringBuilder()
        for char c: value.toCharArray {
            if Character.isAlphabetic(c) {
                if Character.isLowerCase(c) {
                    c = Character.toUpperCase(c)
                } else {
                    c = Character.toLowerCase(c)
                }
            }
            returnValue.append(c)
        }
        return returnValue.toString()
    }
}
