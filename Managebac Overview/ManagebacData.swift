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
    var studentName: String
    var deadlines: [Deadline]

    static func +(lhs: ManagebacData, rhs: ManagebacData) -> ManagebacData {
        if lhs.studentName != rhs.studentName {
            print("bro the two student names aren't the same")
            // todo: handle this error
        }
        return ManagebacData(studentName: lhs.studentName, deadlines: lhs.deadlines + rhs.deadlines)
    }
}