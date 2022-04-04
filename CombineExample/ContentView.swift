//
//  ContentView.swift
//  CombineExample
//
//  Created by Fernando's Mac on 04/04/22.
//


// MVVM Model-View-ViewModel

import SwiftUI
import Combine

// Model:

struct User: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String
    
}

// ViewModel:

final class ViewModel: ObservableObject {
   @Published var time = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var users = [User]()
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .medium
        return df
    }()
    
    init() {
        setupPublishers()
    }
    
    private func setupPublishers() {
        setupTimer()
        setupDataTaskPublisher()
    }
    
    private func setupDataTaskPublisher() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
                
            }
            .decode(type: [User].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {_ in}) { users in
                self.users = users
            }
            .store(in: &cancellables)
    }
    
    private func setupTimer() {
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .receive(on: RunLoop.main)
            .sink { value in
                self.time = self.formatter.string(from: value)
            }
            .store(in: &cancellables)
    }
}


struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
