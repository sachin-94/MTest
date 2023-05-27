//
//  HomeViewModel.swift
//  MTest
//
//  Created by Sachin George on 27/05/23.
//

import Foundation
import Combine

class HomeViewModel {
    
    let homeDataSubject = PassthroughSubject<Result<HomeData,Error>, Never>()
    let jsonCoder = JSONDecoder()
    
    func fetchHomeData() {
        guard let homeUrl = URL(string: homeUrlString) else { return }
        var urlRequest = URLRequest(url: homeUrl)
        urlRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let errorData = error {
                self.homeDataSubject.send(.failure(errorData))
            }
            
            guard let responseData = data else { return }
            do {
                // Parsing the json response using Codable
                let homeData = try self.jsonCoder.decode(HomeData.self, from: responseData)
                self.homeDataSubject.send(.success(homeData))
                
            } catch {
                self.homeDataSubject.send(.failure(error))
            }
        }
        task.resume()
    }
}
