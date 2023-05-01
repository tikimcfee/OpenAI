//
//  ChatResult.swift
//  
//
//  Created by Sergii Kryvoblotskyi on 02/04/2023.
//

import Foundation

public struct ChatResult: Codable, Equatable, Hashable {
    
    public struct Choice: Codable, Equatable, Hashable{
        public struct Delta: Codable, Equatable, Hashable {
            public let content: String?
            public let role: Chat.Role?
            
            public init(content: String?, role: Chat.Role?) {
                self.content = content
                self.role = role
            }
        }
        
        public let index: Int
        /// Exists only if it is a complete message.
        public var message: Chat?
        /// Exists only if it is a partial message obtained throught a streaming query.
        public var delta: Delta?
        /// Exists only if it is a complete message.
        public let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case index
            case message
            case delta
            case finishReason = "finish_reason"
        }
        
        public init(index: Int, message: Chat? = nil, delta: Delta? = nil, finishReason: String?) {
            self.index = index
            self.message = message
            self.delta = delta
            self.finishReason = finishReason
        }
    }
    
    public struct Usage: Codable, Equatable, Hashable {
        public let promptTokens: Int
        public let completionTokens: Int
        public let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
        
        public init(promptTokens: Int = 0, completionTokens: Int = 0, totalTokens: Int = 0) {
            self.promptTokens = promptTokens
            self.completionTokens = completionTokens
            self.totalTokens = totalTokens
        }
    }
    
    public let id: String
    public let object: String
    public let created: TimeInterval
    public let model: Model
    public var choices: [Choice]
    public let usage: Usage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case model
        case choices
        case usage
    }
    
    public init(id: String, object: String, created: TimeInterval, model: Model, choices: [Choice], usage: Usage) {
        self.id = id
        self.object = object
        self.created = created
        self.model = model
        self.choices = choices
        self.usage = usage
    }
}
