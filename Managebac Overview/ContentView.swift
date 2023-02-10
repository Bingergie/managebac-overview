//
//  ContentView.swift
//  Managebac Overview
//
//  Created by Bing He on 2022/11/9.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject var viewModel: ManagebacViewModel
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous).onTapGesture { viewModel.refreshData() }
        }
    }
}

struct CardView: View {
    var title: String
    let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
    var body: some View {
        ZStack {
            shape.fill().foregroundColor(.white)
            shape.stroke().foregroundColor(.accentColor)
            Text(title)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let data = ManagebacViewModel()
        ContentView(viewModel: data)
    }
}
