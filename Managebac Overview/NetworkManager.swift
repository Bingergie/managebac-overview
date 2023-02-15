//
// Created by Bing He on 2023/2/10.
//

import WebKit
import SwiftSoup

class NetworkManager: NSObject {
    static let shared = NetworkManager()

    private override init() {
        super.init()
        webView.navigationDelegate = self
    }

    public let webView = WKWebView()

    private var tempCompletion: (() -> Void)?
    private let url = "ibwya.managebac.cn"
    private let email = "#@wya.top"
    private let password = "no"

    public func fetchManagebacData(completion: ((_ data: ManagebacData?, _ error: Error?) -> Void)?) {
        print("-------------fetch mb data--------------")
        print("fetching data...")
        fetchTasks(type: .upcoming) { data, error in
            completion?(data, error)
        }
    }

    // TODO!! important! this function should only be used for testing purposes
    public func login(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: URL(string: "https://\(self.url)/login")!))
        }

        tempCompletion = completion
    }

    public func login(url: String, email: String, password: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: URL(string: "https://\(url)/login")!))
        }

        tempCompletion = completion
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

    private enum TaskTypeByDate {
        case upcoming
        case completed
    }

    private func fetchTasks(type: TaskTypeByDate, from page: Int = 1, to limit: Int? = nil, completion: @escaping (ManagebacData?, Error?) -> Void) {
        print("-----------fetch tasks of type: \(type) -----------")
        var managebacData = ManagebacData(studentName: "", tasks: [], events: [])

        func fetchPage(type: TaskTypeByDate, from page: Int = 1, to limit: Int? = nil) {
            let url: URL
            switch type {
            case .upcoming:
                url = URL(string: "https://\(self.url)/student/tasks_and_deadlines?upcoming_page=\(page)")!
            case .completed:
                url = URL(string: "https://\(self.url)/student/tasks_and_deadlines?completed_page=\(page)")!
            }
            print("fetching page \(page)... url = \(url)")

            requestPage(url: url) { data, response, error in
                print("parsing page \(page)...")

                // handle errors and set variables
                if let error = error {
                    // todo: handle the error
                    print("error: \(error)")
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    // todo: handle the error
                    print("bad response")
                    return
                }

                guard let data = data, let htmlString = String(data: data, encoding: .utf8) else {
                    // todo: handle the error
                    print("Could not get data or create string from data.")
                    return
                }

                // scrape the html to get tasks
                print("scraping tasks")
                var studentName = ""
                var tasksArray: [Task] = []
                var eventsArray: [Event] = []
                // todo: Parse the response data and update managebacData
                do {
                    let doc: Document = try SwiftSoup.parse(htmlString)
                    let results: Element = try doc.select(".upcoming-tasks").first()!

                    studentName = try String(doc.select("title").text().split(separator: "| ")[1])

                    let tasks: Elements = try results.select(".line.task-node.anchor.js-presentation")
                    let deadlines: Elements = try results.select(".line")

                    for i in (0...tasks.size()-1) {
                        let task = tasks[i]
                        let day: String = try task.select(".day").text()
                        let month: String = try task.select(".month").text()
                        let timeString: String = try task.select(".due.regular").text()
                        let components = timeString.components(separatedBy: " at ")
                        let dayOfWeek = components[0]
                        let time = components[1]
                        let title: String = try task.select("h4.title a").text()
                        let course: String = try doc.select("div.group-name a").get(i).text()
                        let labels: String = try task.select(".label").text()
                        let type: String = labels.components(separatedBy: " ")[0]
                        print(title)
                        print(type)
                        print(course)
                        let link: String = try task.select("a[href]").attr("href")
                        let id: String = String(link.split(separator: "core_tasks/")[1])

                        let formatter = DateFormatter()
                        formatter.dateFormat = "d MM y"
                        let dueDate = formatter.date(from: "\(day) \(month) \(Calendar.current.component(.year, from: .now))")
                        print(formatter.string(from: dueDate!))

                        let newTask = Task(id: id, dueDate: dueDate!, dueTime: timeString, title: title, type: TaskType(rawValue: type)!, course: course, description: "")
                        tasksArray.append(newTask)
                    }

                } catch {
                    print(error)
                }
                managebacData = managebacData + ManagebacData(studentName: studentName, tasks: tasksArray, events: eventsArray)

                // loop stuff
                let shouldContinue = htmlString.contains("show-more-link")
                if (limit == nil || (limit != nil && page < limit!)) && shouldContinue {
                    fetchPage(type: type, from: page + 1, to: limit)
                    return
                }

                // end of loop
                print("parsed \(type) tasks: \(page) pages")
                completion(managebacData, nil)
            }
        }

        fetchPage(type: type, from: page, to: limit)
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
        } else if tempCompletion != nil {
            tempCompletion!()
            tempCompletion = nil
        }
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("loading page: \(webView.url?.absoluteString ?? "no url")")
        if let url = webView.url, !url.absoluteString.contains("login"), tempCompletion != nil {
            tempCompletion!()
            tempCompletion = nil
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
