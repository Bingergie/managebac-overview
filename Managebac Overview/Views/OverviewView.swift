//
// Created by Bing He on 2023/2/15.
//

import SwiftUI

struct OverviewView: View {
    var viewModel: ManagebacViewModel
    var data: ManagebacData
    var body: some View {
        var taskLists: [(String, [Task])] = []
        taskLists.append(("All Upcoming Summative", data.tasks.filter { $0.type == .summative }))
        taskLists.append(("Today & Tomorrow", data.tasks.filter {
            Calendar.current.isDateInToday($0.dueDate) || Calendar.current.isDateInTomorrow($0.dueDate)
        }))
        taskLists.append(("In 2 Weeks", data.tasks.filter {
            Calendar.current.isDateInThisWeek($0.dueDate) || Calendar.current.isDateInNextWeek($0.dueDate)
        }))
        return ScrollView {
            VStack {
                HStack {
                    Text(data.studentName).padding()
                    ZStack {
                        // login button
                        RoundedRectangle(cornerRadius: 20, style: .continuous).foregroundColor(.white).opacity(0.9)
                                .onTapGesture {
                                    viewModel.refreshData()
                                }
                        Image(systemName: "arrow.clockwise").foregroundColor(.black)
                    }
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous).foregroundColor(.white).opacity(0.9)
                    HStack(alignment: .top) {
                        ForEach(taskLists, id: \.0) { taskList in
                            TaskListView(title: taskList.0, tasks: taskList.1)
                                    .padding()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                        }
                    }.padding()
                }.padding()
            }
        }.background(Color(hex: 0xE3EDFD))
    }
}