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
                    Text(task.type == .formative ? "f" : "S")
                            .font(.body.weight(.heavy)).italic().minimumScaleFactor(0.5)
                            .foregroundColor(task.type == .formative ? Color(hex: 0x11BE0D) : .blue)
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
    @State private var url = ""
    @State private var email = ""
    @State private var password = ""
    @State private var loginFailed = false

    var body: some View {
        VStack {
            HStack {
                TextField("URL eg. example.managebac.com", text: $url)
                        .padding()
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            TextField("Email", text: $email)
                    .padding()
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                print("login button pressed")
                viewModel.login(url: url, email: email, password: password) { success in
                    print("login success: \(success)")
                    self.loginFailed = !success
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
            }.alert(isPresented: $loginFailed) {
                        Alert(title: Text("Login failed"), message: Text("Please check your email and password"), dismissButton: .default(Text("OK")))
                    }
        }
                .padding()
        // hidden failed login alert

    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ManagebacViewModel

    var body: some View {
        WebBrowserView()
        if viewModel.isLoggedIn {
            OverviewView(viewModel: viewModel, data: viewModel.data).foregroundColor(.black)
        } else {
            LoginView(viewModel: viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let data = ManagebacViewModel()
        ContentView(viewModel: data)
    }
}
