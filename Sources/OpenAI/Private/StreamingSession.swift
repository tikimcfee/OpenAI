//
//  StreamingSession.swift
//  
//
//  Created by Sergii Kryvoblotskyi on 18/04/2023.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class StreamingSession<ResultType: Codable>: NSObject, Identifiable, URLSessionDelegate, URLSessionDataDelegate {
    
    enum StreamingError: Error {
        case unknownContent
        case emptyContent
    }
    
    var onReceiveContent: ((StreamingSession, ResultType) -> Void)?
    var onProcessingError: ((StreamingSession, Error) -> Void)?
    var onComplete: ((StreamingSession, Error?) -> Void)?
    
    private let streamingCompletionMarker = "[DONE]"
    private let urlRequest: URLRequest
    private lazy var urlSession: URLSession = {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        return session
    }()
    
    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
    func perform() {
        self.urlSession
            .dataTask(with: self.urlRequest)
            .resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        onComplete?(self, error)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let stringContent = String(data: data, encoding: .utf8) else {
            onProcessingError?(self, StreamingError.unknownContent)
            return
        }
        let jsonObjects = stringContent
            .components(separatedBy: "data:")
            .filter { $0.isEmpty == false }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        guard jsonObjects.isEmpty == false, jsonObjects.first != streamingCompletionMarker else {
            onProcessingError?(self, StreamingError.emptyContent)
            return
        }
        jsonObjects.forEach { jsonContent  in
            guard jsonContent != streamingCompletionMarker else {
//                onComplete?(self, nil)
                return
            }
            guard let jsonData = jsonContent.data(using: .utf8) else {
                onProcessingError?(self, StreamingError.unknownContent)
                return
            }
            
            var apiError: Error? = nil
            do {
                let decoded = try JSONDecoder().decode(ResultType.self, from: jsonData)
                onReceiveContent?(self, decoded)
            } catch {
                apiError = error
            }

            if let apiError = apiError {
                do {
                    let decoded = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                    onProcessingError?(self, decoded)
                } catch {
                    onProcessingError?(self, apiError)
                }
            }
        }
    }
}
