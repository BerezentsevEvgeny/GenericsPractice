//
//  ViewController.swift
//  GenericsPractice
//
//  Created by Евгений Березенцев on 22.05.2021.
//

import UIKit

// Протокол для реализации запросов
protocol requestAPI {
    associatedtype Response
    
    var url: URLRequest { get }
    
    func decode(data: Data) throws -> Response
}

// MARK: - Стартовый контроллер
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Отправляем запрос при старте приложения и выводим данные в консоль
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
    
    // Формируем необходимую для получения структуру
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
    
    // Готовим запрос для отправки
    struct PhotoInfoRequest: requestAPI {
        
        var apiKey: String
        
        var url: URLRequest {
            var urlComponents = URLComponents(string: "https://api.nasa.gov/planetary/apod")!
            urlComponents.queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
            return URLRequest(url: urlComponents.url!)
        }
        
        func decode(data: Data) throws -> PhotoInfo {
            let photoInfo = try JSONDecoder().decode(PhotoInfo.self, from: data)
            return photoInfo
        }
    }
    
    

    
    




}

