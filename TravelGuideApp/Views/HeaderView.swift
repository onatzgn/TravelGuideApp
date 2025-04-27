//
//  HeaderView.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 9.03.2025.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        ZStack{
            Text("Login")
                .font(.system(size:50))
                .fontWeight(.bold)
                .padding(.bottom, 30)
        }.padding(.top,250)
    }
}

#Preview {
    HeaderView()
}
