//
//  NetworkManager.swift
//  Networking
//
//  Created by Vasichko Anna on 20.06.2023.
//  Copyright © 2023 Alexey Efimov. All rights reserved.
//

import Foundation
enum Link {
    case imageURL
    case courseURL
    case coursesURL
    case aboutUsURL
    case aboutUsURL2
    case postRequest
    case courseImageURL
    
    var url: URL {
        switch self {
        case .imageURL:
            return URL(string: "https://applelives.com/wp-content/uploads/2016/03/iPhone-SE-11.jpeg")!
        case .courseURL:
            return URL(string: "https://swiftbook.ru//wp-content/uploads/api/api_course")!
        case .coursesURL:
            return URL(string: "https://swiftbook.ru//wp-content/uploads/api/api_courses")!
        case .aboutUsURL:
            return URL(string: "https://swiftbook.ru//wp-content/uploads/api/api_website_description")!
        case .aboutUsURL2:
            return URL(string: "https://swiftbook.ru//wp-content/uploads/api/api_missing_or_wrong_fields")!
        case .postRequest:
            return URL(string: "https://jsonplaceholder.typicode.com/posts")!
        case .courseImageURL:
            return URL(string: "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png")!
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init () {}
    
    func fetchImage(from url: URL, completion: @escaping(Result<Data, NetworkError>) -> Void) {
        
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else {
                completion(.failure(.noData))
                return
            }
            DispatchQueue.main.async {
                completion(.success(imageData))
            }
        }
    }
    
    func fetch<T: Decodable>(_ type: T.Type, from url: URL, completion: @escaping(Result<T, NetworkError>) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let dataModel = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(dataModel))
                }
            } catch {
                completion(.failure(.decodingError))
            }
            
        }.resume()
    }
    
 
    func postRequest(with data: [String: Any], to url: URL, completion: @escaping(Result<Any, NetworkError>) -> Void) {
        let serializedData = try? JSONSerialization.data(withJSONObject: data)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = serializedData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data, let response else {
                completion(.failure(.noData))
                return
            }
            
            print(response)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                completion(.success(json))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func postRequest(with data: Course, to url: URL, completion: @escaping(Result<Any, NetworkError>) -> Void) {
        
        guard let courseData = try? JSONEncoder().encode(data) else {
            completion(.failure(.noData))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = courseData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data else {
                completion(.failure(.noData))
                return
            }
        
            do {
                let course = try JSONDecoder().decode(Course.self, from: data)
                completion(.success(course))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
        
    }
}
