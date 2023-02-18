//
//  ManagebacViewModel.swift
//  Managebac Overview
//
//  Created by Bing He on 2022/11/26.
//

import Foundation
import SwiftUI

class ManagebacViewModel: ObservableObject {

    @Published private(set) var data: ManagebacData
    @Published private(set) var isLoggedIn: Bool

    init() {
        data = ManagebacData(studentName: "", tasks: [], events: [])
        isLoggedIn = false
        NetworkManager.shared.login {
            NetworkManager.shared.checkLoginStatus { isLoggedIn in
                self.isLoggedIn = isLoggedIn
                if isLoggedIn {
                    print("logged in!")
                    self.refreshData()
                } else {
                    print("not logged in!")
                }
            }
        }
    }

    func login(url: String, email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        if isLoggedIn {
            print("is already logged in!")
            completion(true)
            return
        }
        // check if url is valid
        if !url.contains(".managebac.") {
            print("invalid url!")
            completion(false)
            return
        }
        NetworkManager.shared.login(url: url, email: email, password: password) {
            NetworkManager.shared.checkLoginStatus { isLoggedIn in
                if isLoggedIn {
                    print("login successful")
                } else {
                    print("login failed")
                    // todo: handle error
                }
                self.isLoggedIn = isLoggedIn
                completion(isLoggedIn)
            }
        }

    }

    func refreshData() {
        print("checking login status....")
        NetworkManager.shared.checkLoginStatus { isLoggedIn in
            if !isLoggedIn {
                print("not logged in yet! logging in...")
                NetworkManager.shared.login {
                    self.refreshData()
                }
                return
            }

            NetworkManager.shared.fetchManagebacData { (data, error) in
                print("-----------refresh data-----------")
                if let error {
                    print("error fetching data: \(error)")
                }

                guard let data = data else {
                    print("no data")
                    return
                }

                print("updated data: \(data)")
                DispatchQueue.main.async {
                    self.data = data
                }
            }
        }
    }
}
