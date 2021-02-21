//
//  ContentView.swift
//  GrammaKey
//
//  Created by German Zvezdin on 20.02.2021.
//

import SwiftUI



struct ContentView: View {
    @State private var TextToRec = ""
    @State var Mod = "English"
    @State private var ShowLoader = false
    @State private var ShowEmptyStringAlert = false
    @State private var Show2Buttons = false
    @ObservedObject var GApi: GrammaKeyApi = GrammaKeyApi()
    init() {
            UITextView.appearance().backgroundColor = .clear
    }
    var body: some View {
        VStack {
            ZStack{
                Rectangle()
                    .frame(height: 52)
                    .foregroundColor(Color.init(#colorLiteral(red: 0.323702693, green: 0.6174282432, blue: 0.9964571595, alpha: 1)))
                HStack{
                    DropView(mod: $Mod)
                    Spacer()
                }
                
            }
            .padding(.bottom, 24)
            
            if !ShowLoader {
            
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(UIColor.secondarySystemBackground))
            
                            if TextToRec.isEmpty {
                                Text("Key words")
                                    .foregroundColor(Color(UIColor.placeholderText))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 8)
                            }
                            TextEditor(text: $TextToRec)
                                .frame(width: 327, height: 204)
                                
                            
                }
                    .keyboardAdaptive()
                    .frame(width: 327, height: 204)
                    .font(.body)
                    .padding(.bottom, 32)
            } else {
                LoadView()
                    .padding(.top, 40)
                    .padding(.bottom, 96)
            }
                HStack(spacing: 35){
                    
                    Button(action: {
                        if TextToRec.isEmpty {
                            ShowEmptyStringAlert.toggle()
                        } else {
                            GApi.Send(text: self.TextToRec)
                            ShowLoader = true
                            
                            GApi.GetRes() {
                                (res) in
                                self.TextToRec = res
                                self.ShowLoader = false
                                self.Show2Buttons = true
                            }
                            
                        }
                    }, label: {
                        HStack(spacing: 3){
                            Text("Generate")
                                .font(.system(size: 23))
                                .bold()
                                .foregroundColor(Color.init(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                
                            
                        }
                        .frame(width: 146, height: 52, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(
                            Rectangle()
                                .foregroundColor(Color.init(#colorLiteral(red: 0.323702693, green: 0.6174282432, blue: 0.9964571595, alpha: 1)))
                                .cornerRadius(6.0)
                            
                        )
                    })
                    .alert(isPresented: $ShowEmptyStringAlert) {
                                Alert(title: Text("ERROR"), message: Text("Empty string"), dismissButton: .default(Text("Ok")))
                    }
                    
                    Button(action: {
                        self.Show2Buttons = false
                        self.TextToRec = ""
                    }, label: {
                        
                        HStack(spacing: 3){
                            Text("Download")
                                .font(.system(size: 23))
                                .bold()
                                .foregroundColor(Color.init(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                                .opacity(0.5)
                            
                        }
                        .frame(width: 146, height: 52, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.init(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)), lineWidth: 0.5)
                                
                        )
                            
                        
                    })
                    
                    
                }
                
                
                Spacer()
            
            
            
        }
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
