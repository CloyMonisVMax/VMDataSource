//
//  MarvelClient.swift
//  Marvel
//
//  Created by Cloy Vserv on 01/12/22.
//

import Foundation
import CryptoKit

enum MarvelClientError: Error {
    case badURL
    case unknownError
    case errorHttpResponse
    case notFound
    case unknownResponseCode
    case invalidData
}

class MarvelClient {
    var endPoint = "https://gateway.marvel.com:443/v1/public/characters?"
    let privateKey = "f416461a42f5b768c06ceb40ce2e200c35cde56b"
    let publicKey = "c40d792a72af498d04533a2c37b63f96"
    func fetch(offset: Int, limit: Int, completionHandler: @escaping (Result<ClientResponse,Error>) -> Void) {
        let ts = String(Date().timeIntervalSince1970)
        let hash = MD5(string:"\(ts)\(privateKey)\(publicKey)")
        endPoint += "apikey=\(publicKey)"
        endPoint += "&hash=\(hash)"
        endPoint += "&ts=\(ts)"
        endPoint += "&offset=\(offset)"
        endPoint += "&limit=\(limit)"
        guard let url = URL(string: endPoint) else {
            completionHandler(.failure(MarvelClientError.badURL))
            return
        }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = Double(3.0)
        let urlSessionDataTask = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            guard error == nil else {
                completionHandler(.failure(MarvelClientError.unknownError))
                return
            }
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                completionHandler(.failure(MarvelClientError.errorHttpResponse))
                return
            }
            if httpResponse.statusCode == 404 {
                completionHandler(.failure(MarvelClientError.notFound))
                return
            }
            if httpResponse.statusCode != 200 {
                completionHandler(.failure(MarvelClientError.unknownResponseCode))
                return
            }
            guard let data = data else {
                completionHandler(.failure(MarvelClientError.invalidData))
                return
            }
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(ClientResponse.self, from: data)
                // print("response:\(response)")
                response.data?.results?.forEach{ print("\(String(describing: $0.name))") }
                completionHandler(.success(response))
            } catch let error {
                print("error:\(error)")
                completionHandler(.failure(MarvelClientError.unknownError))
            }
        }
        urlSessionDataTask.resume()
    }
}

extension MarvelClient {
    func MD5(string: String) -> String {
        if #available(iOS 13.0, *) {
            let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
            return digest.map {
                String(format: "%02hhx", $0)
            }.joined()
        } else {
            return ""
        }
    }
}
