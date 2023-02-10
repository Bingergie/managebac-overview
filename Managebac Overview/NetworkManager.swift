//
// Created by Bing He on 2023/2/10.
//

import WebKit

class NetworkManager: NSObject {
    static let shared = NetworkManager()

    private override init() {
        super.init()
        webView.navigationDelegate = self
    }

    private let webView = WKWebView()

    private let url = "ibwya.managebac.cn"
    private let email = "#@wya.top"
    private let password = "no"

    public func fetchManagebacData(completion: ((_ data: ManagebacData?, _ error: Error?) -> Void)?) {
        print("-------------fetch mb data--------------")
        print("fetching data...")
        fetchData { (data, error) in
            completion?(data, error)
        }
    }

    public func checkLoginStatus(completion: @escaping (_ isLoggedIn: Bool) -> Void) {
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

    // TODO!! important! this function should only be used for testing purposes
    public func login(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: URL(string: "https://\(self.url)/login")!))
        }

        completion()
    }

    public func login(url: String, email: String, password: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: URL(string: "https://\(url)/login")!))
        }

        completion()
    }

    private func fetchData(completion: @escaping (_ data: ManagebacData?, _ error: Error?) -> Void) {
        print("-------------fetch data--------------")
        var managebacData = ManagebacData(studentName: "", deadlines: [])

        func fetchUpcoming(page: Int = 1) {
            print("-----------fetch upcoming-----------")

            let url = URL(string: "https://\(url)/student/tasks_and_deadlines?upcoming_page=\(page)")!
            print("fetching page \(page)... url = \(url)")

            requestPage(url: url) { data, response, error in
                print("parsing page \(page)...")

                parseTasks(data: data, response: response, error: error) { (shouldContinue) in
                    if shouldContinue {
                        fetchUpcoming(page: page + 1)
                        return
                    }

                    print("parsed upcoming tasks: \(page) pages")
                    completion(managebacData, nil)
                }
            }
        }

        func fetchCompleted(page: Int = 1) {
            print("-----------fetch completed-----------")

            let url = URL(string: "https://\(url)/student/tasks_and_deadlines?completed_page=\(page)")!
            print("fetching page \(page)... url = \(url)")

            requestPage(url: url) { data, response, error in
                print("parsing page \(page)...")

                parseTasks(data: data, response: response, error: error) { (shouldContinue) in
                    if shouldContinue {
                        fetchCompleted(page: page + 1)
                        return
                    }

                    print("parsed completed tasks: \(page) pages")
                    completion(managebacData, nil)
                }
            }
        }

        func parseTasks(data: Data?, response: URLResponse?, error: Error?, _ completion: @escaping (_ shouldContinue: Bool) -> Void) {
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
            completion(htmlString.contains("show-more-link"))

        }

        // only use one, if you use both, it breaks (maybe)
        fetchUpcoming()
        //fetchCompleted()
    }

    private func grabCookies(completion: @escaping (_ cookieHeaders: String) -> Void) {
        let websiteDataStore = WKWebsiteDataStore.default()
        websiteDataStore.httpCookieStore.getAllCookies { (cookies) in
            let cookieHeaders = cookies.map({ "\($0.name)=\($0.value)" }).joined(separator: "; ")
            completion(cookieHeaders)
        }
    }

    private func requestPage(url: URL, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        DispatchQueue.main.async {
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
}

extension NetworkManager: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview has finished loading")
        if let url = webView.url, url.absoluteString.contains("login") {
            fillLogin()
        }
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("loading page: \(webView.url?.absoluteString ?? "no url")")
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
