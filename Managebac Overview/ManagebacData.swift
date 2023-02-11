//
//  Managebac_OverviewApp.swift
//  Managebac Overview
//
//  Created by Bing He on 2022/12/10.
//

import Foundation

enum TaskType {
    case formative
    case summative
}

struct Task: Identifiable {
    let id: String
    let dueDate: Date
    let title: String
    //let type: TaskType
    let course: String
    let description: String
}

struct Event: Identifiable {
    let id: String
    let dueDate: Date
    let title: String
    let course: String
    let description: String
}

struct ManagebacData {
    var studentName: String
    var tasks: [Task]
    var events: [Event]

    static func +(lhs: ManagebacData, rhs: ManagebacData) -> ManagebacData {
        if lhs.studentName != rhs.studentName {
            print("bro the two student names aren't the same, overriding")
            // todo: handle this error
        }
        return ManagebacData(studentName: rhs.studentName, tasks: lhs.tasks + rhs.tasks, events: lhs.events + rhs.events)
    }

    static func +(lhs: ManagebacData, rhs: Task) -> ManagebacData {
        ManagebacData(studentName: lhs.studentName, tasks: lhs.tasks + [rhs], events: lhs.events)
    }

    static func +(lhs: ManagebacData, rhs: [Task]) -> ManagebacData {
        ManagebacData(studentName: lhs.studentName, tasks: lhs.tasks + rhs, events: lhs.events)
    }

    static func +(lhs: ManagebacData, rhs: Event) -> ManagebacData {
        ManagebacData(studentName: lhs.studentName, tasks: lhs.tasks, events: lhs.events + [rhs])
    }

    static func +(lhs: ManagebacData, rhs: [Event]) -> ManagebacData {
        ManagebacData(studentName: lhs.studentName, tasks: lhs.tasks, events: lhs.events + rhs)
    }
}