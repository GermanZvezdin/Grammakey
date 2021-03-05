//
//  LoadView.swift
//  GrammaKey
//
//  Created by German Zvezdin on 20.02.2021.
//

import SwiftUI

struct LoadView: View {
    @State private var isLoading = false
     
    var body: some View {
        ZStack {
            //серая окружность внутри которой вращаются цветные
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 14)
                .frame(width: 100, height: 100)
            Section{
                //цветные сегменты окружности и их анимация
                Circle()
                    .trim(from: 0, to: 00.4)
                    .stroke(Color.init(#colorLiteral(red: 0.323702693, green: 0.6174282432, blue: 0.9964571595, alpha: 1)), lineWidth: 7)
                    .frame(width: 100, height: 100)
                    .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                    .onAppear() {
                        self.isLoading = true
                }
                
            }
        }
        
    }
}

struct LoadView_Previews: PreviewProvider {
    static var previews: some View {
        LoadView()
    }
}
