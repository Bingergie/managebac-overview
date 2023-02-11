//
//  ManagebacViewModel.swift
//  Managebac Overview
//
//  Created by Bing He on 2022/11/26.
//

import Foundation

class ManagebacViewModel: ObservableObject {

    @Published private var managebacData: ManagebacData

    init() {
        managebacData = ManagebacData(studentName: "", tasks: [], events: [])
    }

    func refreshData() {
        print("checking login status....")
        NetworkManager.shared.checkLoginStatus{ isLoggedIn in
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
                    self.managebacData = data
                }
            }
        }
    }
}
