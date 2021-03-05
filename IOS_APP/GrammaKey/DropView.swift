//
//  DropView.swift
//  GrammaKey
//
//  Created by German Zvezdin on 19.02.2021.
//

import SwiftUI

struct DropView: View {
    @Binding var mod: String
    @State var expand = false
    //список моделей
    @State var target = ["Russian"]
    
    var body: some View {
        Menu {
            Button {
                let tmp = self.mod
                self.mod = target[0]
                target[0] = tmp
            } label: {
                Text("\(target[0])")
            }
        } label: {
             Text("\(mod)")
                .foregroundColor(.white)
                .font(.system(size: 20))
                .bold()
                .frame(width: 75)
             Image(systemName: "chevron.down")
                .foregroundColor(.white)
                .font(.system(size: 20))
                
        }
        .padding()
        
    }
}

struct DropView_Previews: PreviewProvider {
    static var previews: some View {
        DropView(mod: .constant("Russia"))
            .background(Color.init(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
    }
}
