//
//  ActivityFormView.swift
//  PRO
//
//  Created by VMO on 9/12/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import CoreLocation

struct ActivityFormView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    @ObservedObject var locationService = LocationService()
    
    
    @State private var dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_OTHER_FORM_ADDITIONAL").complement ?? "")
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "movement", op: "")
    @State var mainTabs = [[String: Any]]()
    @State var bb = ""
    @State private var showDayAuth = false
    @State private var dateStart = Date()
    @State private var dateEnd = Date()
    @State var percentageValue = Double(100)
    
    var body: some View {
        VStack {
            HeaderToggleView(couldSearch: false, title: "modDifferentToVisit", icon: Image("ic-activity"), color: Color.cPanelActivity)
        
            VStack{
                Button(action: {
                    print("ffff")
                }, label: {
                    HStack{
                        VStack{
                            Text("Ciclo")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            Text("cccc")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 16))
                        }
                        Spacer()
                        Image("ic-arrow-expand-more")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                            .foregroundColor(.cTextMedium)
                    }
                    .padding(10)
                    .background(Color.white)
                    .frame(alignment: Alignment.center)
                    .clipped()
                    .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                })
                VStack{
                    HStack{
                        VStack{
                            Text("Desde")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            DatePicker("", selection: $dateStart, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .clipped()
                                .accentColor(.cTextHigh)
                                .background(Color.white)
                        }
                        Spacer()
                        Image("ic-day-request")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 35)
                            .foregroundColor(.cTextMedium)
                    }
                    .padding(10)
                    HStack{
                        VStack{
                            Text("Hasta")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            DatePicker("", selection: $dateEnd, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .clipped()
                                .accentColor(.cTextHigh)
                                .background(Color.white)
                        }
                        Spacer()
                        Image("ic-day-request")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 35)
                            .foregroundColor(.cTextMedium)
                    }
                    .padding(10)
                }
                    .background(Color.white)
                    .frame(alignment: Alignment.center)
                    .clipped()
                    .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                /*
                HStack{
                    HStack{
                        VStack{
                            Text("Desde")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            Text("cccc")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 16))
                        }
                        Spacer()
                        Image("ic-activity")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                            .foregroundColor(.cTextMedium)
                    }
                    .padding(10)
                    Button(action: {
                        print("ffff")
                    }, label: {
                        HStack{
                            VStack{
                                Text("Hasta")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))
                                Text("cccc")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 16))
                            }
                            Spacer()
                            Image("ic-activity")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35)
                                .foregroundColor(.cTextMedium)
                        }
                        .padding(10)
                    })
                }
                    .background(Color.white)
                    .frame(alignment: Alignment.center)
                    .clipped()
                    .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                */
                TextField("escribir", text: $bb)
                    .cornerRadius(CGFloat(4))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(10)
            VStack{
                HStack{
                    Toggle(isOn: $showDayAuth){
                        Text("Solicitar dias autorizados")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextMedium)
                            .font(.system(size: 18))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .onChange(of: showDayAuth, perform: { value in
                        print(value)
                    })
                    .toggleStyle(SwitchToggleStyle(tint: .cBlueDark))
                }
                if showDayAuth {
                    Text("Porcentaje del dia solicitado (Num)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 14))
                    Slider(value: $percentageValue, in: 0.0...100, step: 10)
                    Button(action: {
                        print("ffff")
                    }, label: {
                        HStack{
                            VStack{
                                Text("Motivo de dia autorizado")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))
                                Text("selecciona")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 16))
                            }
                            Spacer()
                            Image("ic-arrow-expand-more")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35)
                                .foregroundColor(.cTextMedium)
                        }
                        .padding(10)
                        .background(Color.white)
                        .frame(alignment: Alignment.center)
                        .clipped()
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                    })
                }
            }
            .padding(10)
            
            ForEach(form.tabs, id: \.id) { tab in
                DynamicFormView(form: $form, tab: $form.tabs[0], options: options)
            }
            Spacer()
            GeometryReader { geometry in
                HStack{
                    Image("ic-signature-paper")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / 2, alignment: .center)
                        .foregroundColor(.cPrimary)
                        .onTapGesture {
                            print("www1")
                            print("___________")
                            print(geometry.size.width / 2)
                        }
                    Image("ic-client")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / 2, alignment: .center)
                        .foregroundColor(.cAccent)
                        .onTapGesture {
                            print("www2")
                            print("___________")
                            print(geometry.size.width / 2)
                        }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 46, maxHeight: 46)
        }.onAppear{
            initView()
            //CICLO CYCLE
            //MOTIVO DIA AUTORIZADO PENDIENTE
        }
    }
    
    func initView(){
        form.tabs = DynamicUtils.initForm(data: dynamicData).sorted(by: { $0.key > $1.key })
    }
}
