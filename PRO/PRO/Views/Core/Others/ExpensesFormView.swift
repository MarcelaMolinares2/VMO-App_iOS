//
//  ExpensesFormView.swift
//  PRO
//
//  Created by Fernando Garcia on 19/01/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import UIKit

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
                HStack {
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
                    VStack {
                        Text("envtotalPurchase")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextHigh)
                            .font(.system(size: 14))
                        TextField("...", text: $total)
                            .cornerRadius(CGFloat(4))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: total, perform: { value in
                                expenses.total = Float(total)
                            })
                        Text("envTotalKm")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextHigh)
                            .font(.system(size: 14))
                        TextField("...", text: $kmExpense)
                            .cornerRadius(CGFloat(4))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: kmExpense, perform: { value in
                                expenses.kmExpense = Float(kmExpense)
                            })
                    }
                }
                .padding(15)
                CustomForm{
                    CustomSection{
                        VStack{
                            VStack {
                                Text(NSLocalizedString("envConcept", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor((concept == "") ? .cDanger : .cTextHigh)
                                    .font(.system(size: 14))
                                VStack{
                                    TextEditor(text: $concept)
                                        .frame(height: 80)
                                        .onChange(of: concept, perform: { value in
                                            expenses.verification = concept
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
                            VStack {
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
                            }
                        }
                        .padding([.top, .bottom], 10)
                    }
                    CustomSection{
                        VStack{
                            ForEach(array, id: \.id) { item in
                                ExpensesFormCardView(conceptExpenses: item)
                            }
                        }
                    }
                    CustomSection{
                        VStack{
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
                        }
                    }
                    
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
        
        let appServer = AppServer()
        appServer.getRequest(path: "vm/config/expense/concept") { (bool, int, any) in
            let requestAny = any as? Array<String> ?? []
            requestAny.forEach{ value in
                let decoded = try! JSONDecoder().decode(ConceptExpensesApi.self, from: value.data(using: .utf8)!)
                let cc = ConceptExpenses()
                cc.id = decoded.id_concepto
                cc.name = decoded.concepto ?? ""
                array.append(cc)
                print("*", decoded)
            }
            print("arrayTotal", array)
        }
    }
}


struct ExpensesFormCardView: View {
    var conceptExpenses: ConceptExpenses
    
    @State private var options = DynamicFormFieldOptions(table: "expenses", op: "")
    @State private var isActionSheet = false
    @State private var isSheet = false
    @State private var selectedPhoto = ""
    @State private var selectedPhotoMode = ""
    @State private var uiImage: UIImage?
    @State private var sheetLayout: SheetLayout = .picker
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        VStack{
            let bindingValue = Binding<String>(get: {
                conceptExpenses.value ?? ""
            }, set: {
                conceptExpenses.value = $0
            })
            let bindingDNI = Binding<String>(get: {
                conceptExpenses.companyDNI ?? ""
            }, set: {
                conceptExpenses.companyDNI = $0
            })
            let bindingName = Binding<String>(get: {
                conceptExpenses.companyName ?? ""
            }, set: {
                conceptExpenses.companyName = $0
            })
            VStack{
                Text(conceptExpenses.name ?? "")
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
                        if selectedPhoto == "OK" {
                            isSheet = true
                        } else {
                            self.isActionSheet = true
                            print("add photo value")
                        }
                    }, label: {
                        Image("ic-photo-add")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 25)
                            .foregroundColor((selectedPhoto == "OK") ? .cToggleActive : .cTextHigh)
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
        .sheet(isPresented: $isSheet) {
            if selectedPhoto == "OK" {
                ExpensePhotoBottomMenu(onEdit: onEdit, onDelete: onDelete, uiImage: uiImage!)
            } else {
                CustomImagePickerView(sourceType: sourceType, uiImage: self.$uiImage, onSelectionDone: onSelectionDone)
            }
        }
        .actionSheet(isPresented: self.$isActionSheet) {
            ActionSheet(title: Text("envSelect"), message: Text(""), buttons: [
                .default(
                    Text((selectedPhoto == "OK") ? "envViewPhto" : "envCamera")
                    , action: {
                    self.sourceType = .camera
                    sheetLayout = .picker
                    isSheet = true
                }),
                .default(Text((selectedPhoto == "OK") ? "envEditPhto" : "envGallery"), action: {
                    self.sourceType = .photoLibrary
                    sheetLayout = .picker
                    isSheet = true
                }),
                .cancel()
            ])
        }
    }
    
    func onSelectionDone(_ done: Bool) {
        self.isSheet = false
        if selectedPhoto == "EDIT" {
            if done {
                MediaUtils.store(uiImage: uiImage, table: options.table, field: conceptExpenses.objectId.description, id: options.item, localId: options.objectId?.stringValue ?? "")
            }
            selectedPhoto = "OK"
        } else {
            if done {
                MediaUtils.store(uiImage: uiImage, table: options.table, field: conceptExpenses.objectId.description, id: options.item, localId: options.objectId?.stringValue ?? "")
                selectedPhoto = "OK"
            }
        }
    }
    
    func onEdit(_ uiImage: UIImage) {
        selectedPhoto = "EDIT"
    }
    
    func onDelete(_ uiImage: UIImage) {
        isSheet = false
        selectedPhoto = ""
    }
    
}

struct ExpensesFormView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesFormView()
    }
}
