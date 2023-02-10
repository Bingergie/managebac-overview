//
//  Managebac_OverviewApp.swift
//  Managebac Overview
//
//  Created by Bing He on 2022/12/10.
//

import Foundation

struct Deadline {
    let dueDate: Date
    let title: String
    let course: String
    let description: String
}

struct ManagebacData {
    private(set) var studentName: String
    private(set) var deadlines: [Deadline]
}