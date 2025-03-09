//
//  LoginView.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 9.03.2025.
//

import SwiftUI

struct LoginView: View {
    
    @State var email =  ""
    @State var password = ""
    
    var body: some View {
        NavigationStack{
            VStack{
                //Header
                HeaderView()

                //Login Form
                Form {
                    TextField("Email Adresiniz", text:$email)
                    SecureField("Şifreniz",text: $password)
                }
                .frame(height: 150)
                .scrollDisabled(true)
                Button(action: {}, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.primary)
                        Text("Giriş Yap")
                            .foregroundStyle(.white)
                    }
                })
                .frame(height: 50)
                .padding(.horizontal)
                Spacer()
                
                //Register
                VStack{
                    Text("Hesabın Yok Mu?")
                    NavigationLink("Yeni Hesap Oluştur",destination: RegisterView())
                }.padding(.bottom,200)
            }
        }
    }
}

#Preview {
    LoginView()
}
