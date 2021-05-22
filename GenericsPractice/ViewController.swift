//
//  ViewController.swift
//  GenericsPractice
//
//  Created by Евгений Березенцев on 22.05.2021.
//

import UIKit

protocol requestAPI {
    associatedtype Response
    
    var url: URLRequest { get }
    
    func decode(data: Data) throws -> Response
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let infoRequest = PhotoInfoRequest(apiKey: "DEMO_KEY")
        parseJSON(request: infoRequest) { (result) in
            switch result {
            case .success(let myInfo):
                print(myInfo)
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
    // Дженерик функция
    func parseJSON<Request: requestAPI >(request: Request, complition: @escaping (Result<Request.Response,Error>) -> Void ) {
        let task = URLSession.shared.dataTask(with: request.url) { (data, response, error) in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            do {
                let decodedData = try request.decode(data: data)
                complition(.success(decodedData))
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    // Запрашиваемая информация
    struct PhotoInfo: Codable {
        var title: String
        var description: String
        var url: URL
        var copyright: String?

        enum CodingKeys: String, CodingKey {
            case title
            case description = "explanation"
            case url
            case copyright
        }
    }
    
    // Готовим запрос
    struct PhotoInfoRequest: requestAPI {
        typealias Response = PhotoInfo
        
        var apiKey: String
        
        var url: URLRequest {
            var urlComponents = URLComponents(string: "https://api.nasa.gov/planetary/apod")!
            urlComponents.queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
            return URLRequest(url: urlComponents.url!)
        }
        
        func decode(data: Data) throws -> Response {
            let photoInfo = try JSONDecoder().decode(PhotoInfo.self, from: data)
            return photoInfo
        }
    }

    
    




}

