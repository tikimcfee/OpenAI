//
//  OpenAITestsCombine.swift
//  
//
//  Created by Sergii Kryvoblotskyi on 04/04/2023.
//

#if canImport(Combine)

import XCTest
@testable import OpenAI

@available(iOS 13.0, *)
@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
final class OpenAITestsCombine: XCTestCase {
    
    var openAI: OpenAIProtocol!
    var urlSession: URLSessionMock!
    
    override func setUp() {
        super.setUp()
        self.urlSession = URLSessionMock()
        let configuration = OpenAI.Configuration(token: "foo", organizationIdentifier: "bar", timeoutInterval: 14)
        self.openAI = OpenAI(configuration: configuration, session: self.urlSession)
    }
    
    func testCompletions() throws {
        let query = CompletionsQuery(model: .textDavinci_003, prompt: "What is 42?", temperature: 0, maxTokens: 100, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
        let expectedResult = CompletionsResult(id: "foo", object: "bar", created: 100500, model: .babbage, choices: [
            .init(text: "42 is the answer to everything", index: 0)
        ], usage: .init(promptTokens: 10, completionTokens: 10, totalTokens: 20))
        try self.stub(result: expectedResult)
        
        let result = try awaitPublisher(self.openAI.completions(query: query))
        XCTAssertEqual(result, expectedResult)
    }
    
    func testChats() throws {
       let query = ChatQuery(model: .gpt4, messages: [
           .init(role: .system, content: "You are Librarian-GPT. You know everything about the books."),
           .init(role: .user, content: "Who wrote Harry Potter?")
       ])
       let chatResult = ChatResult(id: "id-12312", object: "foo", created: 100, model: .gpt3_5Turbo, choices: [
        .init(index: 0, message: .init(role: .system, content: "bar"), delta: nil, finishReason: "baz"),
        .init(index: 0, message: .init(role: .user, content: "bar1"), delta: nil, finishReason: "baz1"),
        .init(index: 0, message: .init(role: .assistant, content: "bar2"), delta: nil, finishReason: "baz2")
        ], usage: .init(promptTokens: 100, completionTokens: 200, totalTokens: 300))
       try self.stub(result: chatResult)
       let result = try awaitPublisher(openAI.chats(query: query))
       XCTAssertEqual(result, chatResult)
    }
    
    func testEdits() throws {
        let query = EditsQuery(model: .gpt4, input: "What day of the wek is it?", instruction: "Fix the spelling mistakes")
        let editsResult = EditsResult(object: "edit", created: 1589478378, choices: [
            .init(text: "What day of the week is it?", index: 0)
        ], usage: .init(promptTokens: 25, completionTokens: 32, totalTokens: 57))
        try self.stub(result: editsResult)
        let result = try awaitPublisher(openAI.edits(query: query))
        XCTAssertEqual(result, editsResult)
    }
    
    func testEmbeddings() throws {
        let query = EmbeddingsQuery(model: .textSearchBabbageDoc, input: "The food was delicious and the waiter...")
        let embeddingsResult = EmbeddingsResult(data: [
            .init(object: "id-sdasd", embedding: [0.1, 0.2, 0.3, 0.4], index: 0),
            .init(object: "id-sdasd1", embedding: [0.4, 0.1, 0.7, 0.1], index: 1),
            .init(object: "id-sdasd2", embedding: [0.8, 0.1, 0.2, 0.8], index: 2)
        ], model: .textSearchBabbageDoc, usage: .init(promptTokens: 10, totalTokens: 10))
        try self.stub(result: embeddingsResult)
        
        let result = try awaitPublisher(openAI.embeddings(query: query))
        XCTAssertEqual(result, embeddingsResult)
    }
    
    func testRetrieveModel() throws {
        let query = ModelQuery(model: .gpt4)
        let modelResult = ModelResult(id: .gpt4, object: "model", ownedBy: "organization-owner")
        try self.stub(result: modelResult)
        
        let result = try awaitPublisher(openAI.model(query: query))
        XCTAssertEqual(result, modelResult)
    }
    
    func testListModels() throws {
        let listModelsResult = ModelsResult(data: [], object: "model")
        try self.stub(result: listModelsResult)
        
        let result = try awaitPublisher(openAI.models())
        XCTAssertEqual(result, listModelsResult)
    }
    
    func testModerations() throws {
        let query = ModerationsQuery(input: "Hello, world!")
        let moderationsResult = ModerationsResult(id: "foo", model: .moderation, results: [
            .init(categories: .init(hate: false, hateThreatening: false, selfHarm: false, sexual: false, sexualMinors: false, violence: false, violenceGraphic: false),
                  categoryScores: .init(hate: 0.1, hateThreatening: 0.1, selfHarm: 0.1, sexual: 0.1, sexualMinors: 0.1, violence: 0.1, violenceGraphic: 0.1),
                  flagged: false)
        ])
        try self.stub(result: moderationsResult)
        
        let result = try awaitPublisher(openAI.moderations(query: query))
        XCTAssertEqual(result, moderationsResult)
    }
    
    func testAudioTranscriptions() throws {
        let data = Data()
        let query = AudioTranscriptionQuery(file: data, fileName: "audio.m4a", model: .whisper_1)
        let transcriptionResult = AudioTranscriptionResult(text: "Hello, world!")
        try self.stub(result: transcriptionResult)
        
        let result = try awaitPublisher(openAI.audioTranscriptions(query: query))
        XCTAssertEqual(result, transcriptionResult)
    }
    
    func testAudioTranslations() throws {
        let data = Data()
        let query = AudioTranslationQuery(file: data, fileName: "audio.m4a", model: .whisper_1)
        let transcriptionResult = AudioTranslationResult(text: "Hello, world!")
        try self.stub(result: transcriptionResult)
        
        let result = try awaitPublisher(openAI.audioTranslations(query: query))
        XCTAssertEqual(result, transcriptionResult)
    }
}

@available(tvOS 13.0, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)
extension OpenAITestsCombine {
    
    func stub(error: Error) {
        let error = APIError(message: "foo", type: "bar", param: "baz", code: "100")
        let task = DataTaskMock.failed(with: error)
        self.urlSession.dataTask = task
    }
    
    func stub(result: Codable) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(result)
        let task = DataTaskMock.successful(with: data)
        self.urlSession.dataTask = task
    }
}

#endif
