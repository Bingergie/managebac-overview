//
//  Managebac_OverviewApp.swift
//  Managebac Overview
//
//  Created by Bing He on 2022/12/10.
//

import WebKit

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

class ManagebacDataLoader: NSObject {
    static let shared = ManagebacDataLoader()

    private override init() {
        super.init()
        webView.navigationDelegate = self
    }

    private let webView = WKWebView()
    private var tempCompletion: ((_ data: ManagebacData?) -> Void)?
    //private let url: URL

    private let url = "ibwya.managebac.cn"
    private let email = "#@wya.top"
    private let password = "no"

    public func fetchManagebacData(completion: ((ManagebacData?) -> Void)?) {
        print("-------------fetch mb data--------------")
        print("fetching data...")
        print("checking login status...")
        checkLoginStatus { (isLoggedIn) in
            print("-------------fetch mb data--------------")
            print("login status = \(isLoggedIn)")
            if !isLoggedIn {
                print("loading login...")
                self.tempCompletion = completion
                self.loadLogin()
                return
            }
            self.fetchData { (data) in
                completion?(data)
            }
        }
    }

    private func fetchData(completion: @escaping (ManagebacData) -> Void) {
        print("-------------fetch data--------------")
        var managebacData = ManagebacData(studentName: "", deadlines: [])

        func fetchUpcoming(page: Int = 1) {
            print("-----------fetch upcoming-----------")

            let url = URL(string: "https://\(url)/student/tasks_and_deadlines?upcoming_page=\(page)")!
            print("fetching page \(page)... url = \(url)")

            requestPage(url: url) { data, response, error in
                print("parsing page \(page)...")
                if let error = error {
                    // todo: handle the error
                    print("error: \(error)")
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    // todo: handle the error
                    print("bro, there's not even a response")
                    return
                }

                if !(200...299).contains(httpResponse.statusCode) {
                    print(httpResponse.statusCode)
                }

                guard let data = data, let htmlString = String(data: data, encoding: .utf8) else {
                    // todo: handle the error
                    print("Could not get data or create string from data.")
                    return
                }

                // todo: Parse the response data and update managebacData

                if htmlString.contains("show-more-link") {
                    fetchUpcoming(page: page + 1)
                    return
                }

                print("parsed upcoming tasks: \(page) pages")
                completion(managebacData)
            }
        }

        fetchUpcoming()
    }

    private func checkLoginStatus(completion: @escaping (Bool) -> Void) {
        print("----------check login status-----------")
        print("fetching login status...")
        requestPage(url: URL(string: "https://\(url)/student")!) { data, response, error in
            print("checking login status...")
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                // todo: handle the error
                print("error fetching login status!")
                return
            }

            print("response code = \(httpResponse.statusCode)")

            if httpResponse.statusCode == 200 {
                print("is logged in")
                completion(true)
                return
            } else {
                print("is not logged in")
                completion(false)
                return
            }
        }
    }

    private func grabCookies(completion: @escaping (_ cookieHeaders: String) -> Void) {
        let websiteDataStore = WKWebsiteDataStore.default()
        websiteDataStore.httpCookieStore.getAllCookies { (cookies) in
            let cookieHeaders = cookies.map({ "\($0.name)=\($0.value)" }).joined(separator: "; ")
            completion(cookieHeaders)
        }
    }

    private func requestPage(url: URL, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        let websiteDataStore = WKWebsiteDataStore.default()
        websiteDataStore.httpCookieStore.getAllCookies { (cookies) in
            let cookieHeaders = cookies.map({ "\($0.name)=\($0.value)" }).joined(separator: "; ")
            var request = URLRequest(url: url)
            request.addValue(cookieHeaders, forHTTPHeaderField: "Cookie")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                completion(data, response, error)
            }
            task.resume()
        }
    }
}

extension ManagebacDataLoader: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview has finished loading")
        checkLoginStatus { (isLoggedIn) in
            print("isLoggedIn = \(isLoggedIn)")
            if isLoggedIn {
                print("is already logged in")
                self.fetchManagebacData(completion: self.tempCompletion ?? nil)
                return
            }
            self.fillLogin()
        }
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("loading...")
        print("url: \(webView.url?.absoluteString ?? "no url")")
    }

    private func loadLogin() {
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.webView.load(URLRequest(url: URL(string: "https://ibwya.managebac.cn/login")!))
            }
        }
    }

    private func fillLogin() {
        print("------------fill login------------")
        print("filling login...")
        webView.evaluateJavaScript("document.getElementById('session_login').value = '\(email)';") { (result, error) in
            if error != nil {
                print(error!)
            }
        }

        webView.evaluateJavaScript("document.getElementById('session_password').value = '\(password)';") { (result, error) in
            if error != nil {
                print(error!)
            }
        }

        webView.evaluateJavaScript("document.getElementById('session_form').submit();") { (result, error) in
            if error != nil {
                print(error!)
            }
        }
    }
}