//
//  LoginView.swift
//  SnagIt
//
//  Created by Misha Causur on 04.02.2026.
//

import Combine

struct LoginViewModel {

    struct Bindings {
        let username: AsyncPublisher<Published<String>.Publisher>
        let password: AsyncPublisher<Published<String>.Publisher>
        let didLogin: AsyncStream<Void>
    }

    let canLogin: AsyncStream<Bool>
    let error: AsyncStream<Error>
    let isLoading: AsyncStream<Bool>
    let didLogin: AsyncStream<Void>
    let tasks: [Task<Void, Error>]  // disposables

    func makeBindings(_ bindings: Bindings) -> Self {
        
        let loginTask = Task {
            for await _ in bindings.didLogin. {
                
            }
        }

        return Self(
            canLogin: <#T##AsyncStream<Bool>#>,
            error: <#T##AsyncStream<any Error>#>,
            isLoading: <#T##AsyncStream<Bool>#>,
            didLogin: <#T##AsyncStream<Void>#>,
            tasks: <#T##[Task<Void, any Error>]#>
        )
    }
}
