//
//  ContentView.swift
//  Managebac Overview
//
//  Created by Bing He on 2022/11/9.
//

import SwiftUI
import WebKit

// this is to monitor the hidden webview in NetworkManager
struct WebBrowserView: NSViewRepresentable {
    private let webView = NetworkManager.shared.webView

    public typealias NSViewType = WKWebView

    public func makeNSView(context: NSViewRepresentableContext<WebBrowserView>) -> WKWebView {
        webView
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<WebBrowserView>) {

    }
}

struct TaskView: View {
    var task: Task
    var body: some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return ZStack {
            RoundedRectangle(cornerRadius: 20)//.foregroundColor(Color(hex: 0xEFEFEF))
                    .foregroundColor(task.type == .formative ? Color(hex: 0x11BE0D) : .blue)
                    .opacity(0.3)
            VStack {
                HStack {
                    Text(task.type == .formative ? "f" : "S").font(.body).italic().minimumScaleFactor(0.5)
                            .foregroundColor(task.type == .formative ? Color(hex: 0x11BE0D) : .blue)
                            .fontWeight(.heavy)
                    Text(task.title).font(.body).bold().minimumScaleFactor(0.5)
                }
                Text("\(formatter.string(from: task.dueDate)), \(task.dueTime)").font(.body).italic().minimumScaleFactor(0.5)
                Text(task.course).font(.body).italic().minimumScaleFactor(0.5)
            }
                    .padding()
        }
    }
}

struct TaskListView: View {
    var title: String
    var tasks: [Task]
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
            ForEach(tasks) { task in
                TaskView(task: task)
            }
        }
                .fixedSize(horizontal: false, vertical: true)
    }
}

// loginView
struct LoginView: View {
    var viewModel: ManagebacViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                    .padding()
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                viewModel.login(email: email, password: password) { success in
                    if success {
                        viewModel.refreshData()
                    }
                }
            }) {
                Text("Log in")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
            }
        }
                .padding()
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ManagebacViewModel

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous).onTapGesture {
                viewModel.refreshData()
            }
            if viewModel.isLoggedIn {
                WebBrowserView()
            } else {
                LoginView(viewModel: viewModel)
            }

        }
        OverviewView(data: viewModel.data)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let data = ManagebacViewModel()
        ContentView(viewModel: data)
    }
}
