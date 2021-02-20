//
//  ContentView.swift
//  GrammaKey
//
//  Created by German Zvezdin on 20.02.2021.
//

import SwiftUI

struct ContentView: View {
    @State private var TextToRec = ""
    @State private var ResText = ""
    init() {
            UITextView.appearance().backgroundColor = .clear
    }
    var body: some View {
        VStack {
            ZStack{
                Rectangle()
                    .frame(height: 52)
                    .foregroundColor(Color.init(#colorLiteral(red: 0.5269275308, green: 0.7350733876, blue: 0.9972892404, alpha: 1)))
                
                HStack{
                    
                }
                
            }
            .padding(.bottom, 24)
            
            ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(UIColor.secondarySystemBackground))
                        
                        if TextToRec.isEmpty {
                            Text("Placeholder Text")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }
                        
                        TextEditor(text: $TextToRec)
                            .padding(4)
                        
                    }
                    .frame(width: 327, height: 204)
                    .font(.body)
            
            Spacer()
            
            
        }
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
