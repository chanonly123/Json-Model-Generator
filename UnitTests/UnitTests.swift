//
//  UnitTests.swift
//  UnitTests
//
//  Created by Chandan Karmakar on 10/12/21.
//  Copyright © 2021 Chandan. All rights reserved.
//

@testable import JsonToModel
import XCTest

class UnitTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let testName = #function
        let asyncExpectation = expectation(description: testName)
        var obj: Root!
        let json = ##"{"success":true,"data":{"voice_opinions":[{"status":1,"updateAt":1541413168000,"id":246,"unique_id":"uo-5edc608309257fde","counter_opinions":[{"status":1,"updateAt":1541413168000,"id":246,"unique_id":"uo-5edc608309257fde","user_id":614,"audio_id":234,"createdAt":1541413168000,"hot_topic_id":8,"vote":0}],"user_id":614,"audio_id":234,"createdAt":1541413168000,"hot_topic_id":8,"vote":0}]},"code":200}"##

        let list = TemplateList.createInitialList()
        let codable = list.first(where: { $0.name.lowercased().contains("codable") })
        let converter = TemplateConverter(t: codable!, js: json)
        converter.convert()
        converter.completion = { res in
            switch res {
            case .failed(let error):
                assertionFailure()
            case .success(let code):
                obj = try! JSONDecoder().decode(Root.self, from: json.data(using: .utf8)!)
                asyncExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5) { _ in
            XCTAssert(obj != nil, testName)
            
            XCTAssert(obj.code != nil, testName)
            XCTAssert(obj.success != nil, testName)
            XCTAssert(obj.data != nil, testName)
            
            XCTAssert(obj.data?.voiceOpinions != nil, testName)
            
            XCTAssert(obj.data?.voiceOpinions?.first?.counterOpinions != nil, testName)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    struct Root: Codable {
        var code: Int?
        var data: Data?
        var success: Bool?

        enum CodingKeys: String, CodingKey {
            case code
            case data
            case success
        }
    }

    struct Data: Codable {
        var voiceOpinions: [VoiceOpinions]?

        enum CodingKeys: String, CodingKey {
            case voiceOpinions = "voice_opinions"
        }
    }

    struct VoiceOpinions: Codable {
        var vote: Int?
        var createdAt: Int?
        var userId: Int?
        var id: Int?
        var status: Int?
        var counterOpinions: [CounterOpinions]?
        var updateAt: Int?
        var hotTopicId: Int?
        var uniqueId: String?
        var audioId: Int?

        enum CodingKeys: String, CodingKey {
            case vote
            case createdAt
            case userId = "user_id"
            case id
            case status
            case counterOpinions = "counter_opinions"
            case updateAt
            case hotTopicId = "hot_topic_id"
            case uniqueId = "unique_id"
            case audioId = "audio_id"
        }
    }

    struct CounterOpinions: Codable {
        var hotTopicId: Int?
        var vote: Int?
        var audioId: Int?
        var userId: Int?
        var id: Int?
        var createdAt: Int?
        var uniqueId: String?
        var updateAt: Int?
        var status: Int?

        enum CodingKeys: String, CodingKey {
            case hotTopicId = "hot_topic_id"
            case vote
            case audioId = "audio_id"
            case userId = "user_id"
            case id
            case createdAt
            case uniqueId = "unique_id"
            case updateAt
            case status
        }
    }
}
