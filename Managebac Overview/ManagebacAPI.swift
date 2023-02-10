//
//  ManagebacAPI.swift
//  Managebac Overview
//
//  Created by Bing He on 2022/11/26.
//

import Foundation

class ManagebacViewModel: ObservableObject {

    @Published private var managebacData: ManagebacData
    var studentName: String {
        managebacData.studentName
    }
    var deadlines: [Deadline] {
        managebacData.deadlines
    }

    init() {
        managebacData = ManagebacData(studentName: "", deadlines: [])
    }

    func refreshData() {
        ManagebacDataLoader.shared.fetchManagebacData { [weak self] (data: ManagebacData?) in
            print("-----------refresh data-----------")
            guard let data = data else {
                print("no data")
                return
            }
            print("updated data: \(data)")
            self?.managebacData = data
        }
    }
}