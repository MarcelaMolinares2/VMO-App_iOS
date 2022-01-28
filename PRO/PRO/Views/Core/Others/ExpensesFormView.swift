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
import Combine

struct ExpensesFormView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var expense: Expense = Expense()
    
    @State private var conceptsExpensesSimple: [ConceptExpenseSimple] = []
    
    @ObservedResults(ConceptExpense.self) var conceptsExpenses
    
    @State private var dateStart = Date()
    @State private var concept: String = ""
    @State private var total: String = ""
    @State private var originDestiny: String = ""
    @State private var km: String = ""
    @State private var kmExpense: String = ""
    @State private var observations: String = ""
    
    @State private var valueTotalExpense: Bool = false
    
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
                                expense.expenseDate = Utils.dateFormat(date: dateStart)
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
                            .disabled(true)
                            .onChange(of: total, perform: { value in
                                expense.total = Float(total)
                            })
                        Text("envTotalKm")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextHigh)
                            .font(.system(size: 14))
                        TextField("...", text: $kmExpense)
                            .cornerRadius(CGFloat(4))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true)
                            .onChange(of: kmExpense, perform: { value in
                                expense.kmExpense = Float(kmExpense)
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
                                            expense.verification = concept
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
                                        expense.originDestination = originDestiny
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
                                    .keyboardType(.numberPad)
                                    .onReceive(Just(km)) { newValue in
                                        let filtered = newValue.filter{ "0123456789".contains($0) }
                                        if filtered != newValue{
                                            km = filtered
                                        }
                                        expense.km = Float(km)
                                    }
                            }
                        }
                        .padding([.top, .bottom], 10)
                    }
                    CustomSection{
                        VStack{
                            ForEach(conceptsExpensesSimple, id: \.id) { item in
                                ExpensesFormCardView(conceptExpenseSimple: item, valueTotalExpense: $valueTotalExpense)
                                    .padding(5)
                                    
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
                                        expense.observations = observations
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
                        save()
                    }
                }
            }
        }
        .onAppear{
            initView()
        }
    }
    
    func initView() {
        print(ExpenseDao(realm: try! Realm()).all())
        
        
        expense.expenseDate = Utils.dateFormat(date: dateStart)
        conceptsExpenses.forEach{ value in
            let temp = ConceptExpenseSimple()
            temp.id = value.id
            temp.name = value.concept ?? ""
            conceptsExpensesSimple.append(temp)
        }
    }
    
    func save() {
        var fullData: [String] = []
        conceptsExpensesSimple.forEach{ value in
            var tmp: [String] = []
            tmp.append(value.name ?? "")
            tmp.append(value.value ?? "")
            tmp.append(value.companyDNI ?? "")
            tmp.append(value.companyName ?? "")
            tmp.append(value.photo ?? "")
            fullData.append(tmp.joined(separator: ","))
        }
        expense.conceptData = fullData.joined(separator: "::")
        print(expense)
        ExpenseDao(realm: try! Realm()).store(expense: expense)
        self.goTo(page: "MASTER")
    }
    
    func goTo(page: String) {
        viewRouter.currentPage = page
    }
}


struct ExpensesFormCardView: View {
    @State var conceptExpenseSimple: ConceptExpenseSimple
    @Binding var valueTotalExpense: Bool
    
    @State private var options = DynamicFormFieldOptions(table: "expenses", op: "")
    @State private var isActionSheet = false
    @State private var isSheet = false
    @State private var selectedPhoto = ""
    @State private var selectedPhotoMode = ""
    @State private var uiImage: UIImage?
    @State private var sheetLayout: SheetLayout = .picker
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    @State private var valueExpense = ""
    @State private var dniExpense = ""
    @State private var nameExpense = ""
    
    var body: some View {
        VStack{
            VStack{
                Text(conceptExpenseSimple.name ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.cTextHigh)
                    .font(.system(size: 16))
                HStack{
                    VStack {
                        Text("envValue")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextHigh)
                            .font(.system(size: 12))
                        TextField("envValue...", text: $valueExpense)
                            .cornerRadius(CGFloat(4))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .onReceive(Just(valueExpense)) { newValue in
                                let filtered = newValue.filter{ "0123456789".contains($0) }
                                if filtered != newValue{
                                    valueExpense = filtered
                                }
                                conceptExpenseSimple.value = valueExpense
                                valueTotalExpense.toggle()
                            }
                    }
                    Spacer()
                    Button(action: {
                        if selectedPhoto == "OK" {
                            isSheet = true
                        } else {
                            self.isActionSheet = true
                        }
                    }, label: {
                        Image("ic-photo-add")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 25)
                            .foregroundColor((selectedPhoto == "OK") ? .cToggleActive : .cTextHigh)
                    })
                }
                VStack {
                    VStack{
                        Text("envCompanyDNI")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextHigh)
                            .font(.system(size: 12))
                        TextField("envCompanyDNI...", text: $dniExpense)
                            .cornerRadius(CGFloat(4))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: dniExpense, perform:  { value in
                                conceptExpenseSimple.companyDNI = dniExpense
                            })
                    }
                    VStack{
                        Text("envCompanyName")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextHigh)
                            .font(.system(size: 12))
                        TextField("envCompanyName...", text: $nameExpense)
                            .cornerRadius(CGFloat(4))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: nameExpense, perform:  { value in
                                conceptExpenseSimple.companyName = nameExpense
                            })
                    }
                }
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
                MediaUtils.store(uiImage: uiImage, table: options.table, field: conceptExpenseSimple.objectId.description, id: options.item, localId: options.objectId?.stringValue ?? "")
            }
            selectedPhoto = "OK"
        } else {
            if done {
                MediaUtils.store(uiImage: uiImage, table: options.table, field: conceptExpenseSimple.objectId.description, id: options.item, localId: options.objectId?.stringValue ?? "")
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
