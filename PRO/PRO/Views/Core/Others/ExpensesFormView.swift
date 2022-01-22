//
//  ExpensesFormView.swift
//  PRO
//
//  Created by Fernando Garcia on 19/01/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift


struct ConceptExpensesApi: Codable {
    var id_concepto: Int
    var concepto: String?
    var cuenta: Int?
    var departamento:String?
    var reembolsable:Int?
}

struct ExpensesFormView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var expenses: Expenses = Expenses()
    
    @State private var array: [ConceptExpenses] = []
    
    @State private var dateStart = Date()
    @State private var concept: String = ""
    @State private var total: String = ""
    @State private var originDestiny: String = ""
    @State private var km: String = ""
    @State private var kmExpense: String = ""
    @State private var observations: String = ""
    
    var body: some View {
        ZStack{
            VStack{
                HeaderToggleView(couldSearch: false, title: "modExpenses", icon: Image("ic-expense"), color: Color.cPanelRequestDay)
                Form{
                    VStack{
                        HStack{
                            VStack{
                                Text(NSLocalizedString("envDate", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextHigh)
                                    .font(.system(size: 14))
                                DatePicker("", selection: $dateStart, in: Date()..., displayedComponents: [.date])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                    .clipped()
                                    .accentColor(.cTextHigh)
                                    .background(Color.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .onChange(of: dateStart, perform: { value in
                                        expenses.expenseDate = Utils.dateFormat(date: dateStart)
                                    })
                            }
                            Spacer()
                            Image("ic-day-request")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 35)
                                .foregroundColor(.cTextHigh)
                        }
                        .padding(10)
                        .background(Color.white)
                        .frame(alignment: Alignment.center)
                        .clipped()
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        VStack {
                            Text(NSLocalizedString("envConcept", comment: ""))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor((concept == "") ? .cDanger : .cTextHigh)
                                .font(.system(size: 14))
                            VStack{
                                TextEditor(text: $concept)
                                    .frame(height: 80)
                                    .onChange(of: concept, perform: { value in
                                        expenses.concept = concept
                                    })
                            }
                            .background(Color.white)
                            .frame(alignment: Alignment.center)
                            .clipped()
                            .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        }
                        VStack{
                            Text(NSLocalizedString("envOriginDestiny", comment: ""))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                            TextField("...", text: $originDestiny)
                                .cornerRadius(CGFloat(4))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: originDestiny, perform: { value in
                                    expenses.originDestination = originDestiny
                                })
                        }
                    }
                    .padding([.top, .bottom], 10)
                    Section{
                        
                        List{
                            ForEach(array, id: \.id) { item in
                                //MaterialDeliveryListCardView(item: item)
                                let bindingValue = Binding<String>(get: {
                                    item.value ?? ""
                                }, set: {
                                    item.value = $0
                                })
                                let bindingDNI = Binding<String>(get: {
                                    item.companyDNI ?? ""
                                }, set: {
                                    item.companyDNI = $0
                                })
                                let bindingName = Binding<String>(get: {
                                    item.companyName ?? ""
                                }, set: {
                                    item.companyName = $0
                                })
                                VStack{
                                    Text(item.name ?? "")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.cTextHigh)
                                    Text("envValue")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.cTextHigh)
                                        .font(.system(size: 14))
                                    HStack{
                                        TextField("...", text: bindingValue)
                                            .cornerRadius(CGFloat(4))
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        Spacer()
                                        Button(action: {
                                            print("add photo value")
                                        }, label: {
                                            Image("ic-photo-add")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 25)
                                                .foregroundColor(.cTextHigh)
                                        })
                                    }
                                    TextField("envCompanyDNI...", text: bindingDNI)
                                        .cornerRadius(CGFloat(4))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    TextField("envCompanyName...", text: bindingName)
                                        .cornerRadius(CGFloat(4))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                .padding(10)
                                .background(Color.white)
                                .clipped()
                                .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                            }
                        }
                        /*
                        VStack{
                            Text("envTravel")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                            Text("envValue")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                            HStack{
                                TextField("...", text: $originDestiny)
                                    .cornerRadius(CGFloat(4))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Spacer()
                                Button(action: {
                                    print("add photo value")
                                }, label: {
                                    Image("ic-photo-add")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 25)
                                        .foregroundColor(.cTextHigh)
                                })
                            }
                            TextField("...", text: $originDestiny)
                                .cornerRadius(CGFloat(4))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("...", text: $originDestiny)
                                .cornerRadius(CGFloat(4))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(10)
                        .background(Color.white)
                        .clipped()
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        */
                    }
                    .padding([.top, .bottom], 10)
                    Section{
                        VStack{
                            Text("envPurchasetotal")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                            TextField("...", text: $total)
                                .cornerRadius(CGFloat(4))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: total, perform: { value in
                                    expenses.total = Float(total)
                                })
                            Text("envKm")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                            TextField("...", text: $km)
                                .cornerRadius(CGFloat(4))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: km, perform: { value in
                                    expenses.km = Float(km)
                                })
                            TextField("...", text: $kmExpense)
                                .cornerRadius(CGFloat(4))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: kmExpense, perform: { value in
                                    expenses.kmExpense = Float(kmExpense)
                                })
                            Text("envObservations")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                            VStack{
                                TextEditor(text: $observations)
                                    .frame(height: 80)
                                    .onChange(of: observations, perform: { value in
                                        expenses.observations = observations
                                    })
                            }
                            .background(Color.white)
                            .frame(alignment: Alignment.center)
                            .clipped()
                            .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                            
                            /*
                            TextField("...", text: $originDestiny)
                                .cornerRadius(CGFloat(4))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            */
                        }
                    }
                    .padding([.top, .bottom], 10)
                    
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                        print("_________________")
                        var fullData: [String] = []
                        array.forEach{ value in
                            var tmp: [String] = []
                            tmp.append(value.name ?? "")
                            tmp.append(value.value ?? "")
                            tmp.append(value.companyDNI ?? "")
                            tmp.append(value.companyName ?? "")
                            tmp.append(value.photo ?? "")
                            fullData.append(tmp.joined(separator: ","))
                        }
                        expenses.conceptData = fullData.joined(separator: "::")
                        print(expenses)
                        print("_________________")
                    }
                }
            }
        }
        .onAppear{
            load()
        }
    }
    
    func load() {
        if !viewRouter.data.objectId.isEmpty {
            if let expensesItem = try? ExpensesDao(realm: try! Realm()).by(objectId: ObjectId(string: viewRouter.data.objectId)) {
                expenses = Expenses(value: expensesItem)
            }
        } else {
            expenses.expenseDate = Utils.dateFormat(date: dateStart)
        }
        
        /*
        print(expenses)
        print("__________________________")
        print(ExpensesDao(realm: try! Realm()).all())
        
        print("__________________")
        */
        
        let appServer = AppServer()
        appServer.getRequest(path: "vm/config/expense/concept") { (bool, int, any) in
            let requestAny = any as? Array<String> ?? []
            requestAny.forEach{ value in
                print(value)
                
                let decoded = try! JSONDecoder().decode(ConceptExpensesApi.self, from: value.data(using: .utf8)!)
                //let setstock = [setStock(lot: decoded.lote, quantity: decoded.cantidad)]
                //array.append(Stock(name: decoded.material.nombre, set: setstock, date: decoded.fecha))
                let cc = ConceptExpenses()
                cc.id = decoded.id_concepto
                cc.name = decoded.concepto ?? ""
                array.append(cc)
                print("*", decoded)
            }
            print("arrayTotal", array)
        }
        
        
        //waitLoad = true
    }
}

struct ExpensesFormView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesFormView()
    }
}
