//
//  File.swift
//  
//
//  Created by Sergii Kryvoblotskyi on 12/19/22.
//

import Foundation

public enum Model: String, Codable, Identifiable, Hashable, Equatable, CaseIterable {
    public var id: String { rawValue }
    
    case textDavinci_003 = "text-davinci-003"
    case textDavinci_002 = "text-davinci-002"
    case textDavinci_001 = "text-davinci-001"
    case curie = "text-curie-001"
    case babbage = "text-babbage-001"
    case textSearchBabbadgeDoc = "text-search-babbage-doc-001"
    case textSearchBabbageQuery001 = "text-search-babbage-query-001"
    case ada = "text-ada-001"
    case textEmbeddingAda = "text-embedding-ada-002"
    case gpt3_5Turbo = "gpt-3.5-turbo"
    case gpt3_5Turbo0301 = "gpt-3.5-turbo-0301"
    
    case gpt4 = "gpt-4"
    case gpt4_0134 = "gpt-4-0314"
    case gpt4_32k = "gpt-4-32k"
    case gpt4_32k_0314 = "gpt-4-32k-0314"
}
