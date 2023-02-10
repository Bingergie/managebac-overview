//
//  Managebac_OverviewApp.swift
//  Managebac Overview
//
//  Created by Bing He on 2022/11/9.
//

import SwiftUI

@main
struct Managebac_OverviewApp: App {
    let api = ManagebacViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: api)
        }
    }
}
