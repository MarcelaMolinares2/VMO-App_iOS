//
//  RecordExpenseView.swift
//  PRO
//
//  Created by VMO on 4/08/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast

class ExpenseReportModel: ObservableObject, Identifiable {
    @Published var date: Date = Date()
    @Published var originDestiny: String = ""
    @Published var observations: String = ""
}

class ExpenseReportDetailModel: ObservableObject, Identifiable {
    var objectId = ObjectId.generate()
    var conceptId: Int = 0
    @Published var total: Float = 0
    @Published var companyNIT: String = ""
    @Published var companyName: String = ""
    @Published var supportingDocument: Bool = false
    @Published var uiImage: UIImage?
    @Published var modalImageOpen = false
}

struct RecordExpenseView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var selected = [String]()
    @State private var expenseReportModel = ExpenseReportModel()
    @State private var details = [ExpenseReportDetailModel]()
    @State private var modalOpen = false
    @State private var showToast = false
    @State private var savedToast = false
    @State private var errorToast = ""
    
    var realm = try! Realm()
    
    var body: some View {
        ZStack(alignment: .bottom)  {
            VStack {
                HeaderToggleView(title: "modRecordExpense")
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("envDate")
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                            DatePicker("", selection: $expenseReportModel.date, displayedComponents: .date)
                                .fixedSize()
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("envTotal")
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                            Text(String(format: NSLocalizedString("envCurrency", comment: "%@: %@"), "COP", String(getTotal())))
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 25))
                        }
                    }
                    CustomCard {
                        Text("envOriginDestiny")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(expenseReportModel.originDestiny.isEmpty ? Color.cDanger : .cTextMedium)
                        TextField("envOriginDestiny", text: $expenseReportModel.originDestiny)
                            .cornerRadius(CGFloat(4))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("envObservations")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextMedium)
                        TextField("envObservations", text: $expenseReportModel.observations)
                            .cornerRadius(CGFloat(4))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal, Globals.UI_FORM_PADDING_HORIZONTAL)
                ScrollView {
                    ForEach($details) { $detail in
                        let concept = ExpenseConceptDao(realm: realm).by(id: detail.conceptId)
                        VStack {
                            CustomCard {
                                HStack {
                                    Text(concept?.name ?? "")
                                        .foregroundColor(.cTextHigh)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(2)
                                    Button(action: {
                                        delete(detail: detail)
                                    }) {
                                        Image("ic-delete")
                                            .resizable()
                                            .foregroundColor(.cDanger)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 22, height: 22, alignment: .center)
                                            .padding(8)
                                    }
                                    .frame(width: 44, height: 44, alignment: .center)
                                }
                                Text("envValue")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor((detail.total < 0) ? Color.cDanger : .cTextMedium)
                                TextField("envValue", value: $detail.total, formatter: NumberFormatter())
                                    .cornerRadius(CGFloat(4))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Text("envCompanyNIT")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                TextField("envCompanyNIT", text: $detail.companyNIT)
                                    .cornerRadius(CGFloat(4))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Text("envCompanyName")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                TextField("envCompanyName", text: $detail.companyName)
                                    .cornerRadius(CGFloat(4))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                RecordExpenseConceptResourceView(detail: detail)
                            }
                        }
                        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
                    }
                    ScrollViewFABBottom()
                }
            }
            HStack {
                FAB(image: "ic-plus") {
                    modalOpen = true
                }
                Spacer()
                if !savedToast {
                    FAB(image: "ic-cloud") {
                        validate()
                    }
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .sheet(isPresented: $modalOpen) {
            DialogSourcePickerView(selected: $selected, key: "EXPENSE-CONCEPT", multiple: true, title: NSLocalizedString("envConcept", comment: "Concept")) { selected in
                onSelectionDone(selected)
            }
        }
        .toast(isPresenting: $showToast){
            AlertToast(type: .error(.cError), title: NSLocalizedString(errorToast, comment: ""))
        }
        .toast(isPresenting: $savedToast) {
            AlertToast(type: .complete(.cDone), title: NSLocalizedString("envSuccessfullySaved", comment: ""))
        }
    }
    
    func validate() {
        if expenseReportModel.originDestiny.isEmpty {
            showToast = true
            errorToast = "errFormEmpty"
            return
        }
        if details.isEmpty {
            showToast = true
            errorToast = "errRecordExpenseEmpty"
            return
        }
        save()
    }
    
    func save() {
        let expenseReport = ExpenseReport()
        expenseReport.date = Utils.dateFormat(date: expenseReportModel.date)
        expenseReport.originDestiny = expenseReportModel.originDestiny
        expenseReport.observations = expenseReportModel.observations
        details.forEach { d in
            let detail = ExpenseReportDetail()
            detail.objectId = d.objectId
            detail.conceptId = d.conceptId
            detail.total = d.total
            detail.companyNIT = d.companyNIT
            detail.companyName = d.companyName
            detail.supportingDocument = d.supportingDocument
            expenseReport.details.append(detail)
        }
        ExpenseReportDao(realm: realm).store(expenseReport: expenseReport)
        goTo(page: "MASTER")
    }
    
    func goTo(page: String) {
        savedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Globals.ENV_SAVE_DELAY) {
            viewRouter.currentPage = page
        }
    }
    
    func getTotal() -> Float {
        var total: Float = 0
        details.forEach { d in
            total += d.total
        }
        return total
    }
    
    func delete(detail: ExpenseReportDetailModel) {
        selected = selected.filter { $0 != String(detail.conceptId) }
        details = details.filter { $0.conceptId != detail.conceptId }
    }
    
    func onSelectionDone(_ selected: [String]) {
        modalOpen = false
        selected.forEach { s in
            if details.filter({ d in
                d.conceptId == Utils.castInt(value: s)
            }).count <= 0 {
                let detail = ExpenseReportDetailModel()
                detail.conceptId = Utils.castInt(value: s)
                details.append(detail)
            }
        }
    }
}


struct RecordExpenseConceptResourceView: View {
    @ObservedObject var detail: ExpenseReportDetailModel
    
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var source: MediaSource = .canvas
    @State private var showActionSheet = false
    
    var body: some View {
        VStack {
            if detail.supportingDocument {
                VStack {
                    if let uiImage = detail.uiImage {
                        Button(action: {
                            showActionSheet = true
                        }) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 200, alignment: .center)
                                .padding(8)
                        }
                    }
                    Button(action: {
                        detail.supportingDocument = false
                        MediaUtils.remove(
                            table: "expense_report_detail",
                            field: "supporting_document",
                            localId: detail.objectId
                        )
                    }) {
                        Text("envRemoveResource")
                            .foregroundColor(.cError)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    }
                }
            } else {
                Button(action: {
                    showActionSheet = true
                }) {
                    Image("ic-photo-camera")
                        .resizable()
                        .foregroundColor(.cIcon)
                        .aspectRatio(contentMode: .fit)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 30, maxHeight: 30, alignment: .center)
                        .padding(8)
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: 244, alignment: .center)
        .sheet(isPresented: $detail.modalImageOpen, content: {
            CustomImagePickerView(sourceType: sourceType, uiImage: $detail.uiImage) { done in
                detail.modalImageOpen = false
                if done {
                    detail.supportingDocument = true
                    MediaUtils.store(
                        uiImage: detail.uiImage,
                        table: "expense_report_detail",
                        field: "supporting_document",
                        id: detail.conceptId,
                        localId: detail.objectId
                    )
                }
            }
        })
        .actionSheet(isPresented: self.$showActionSheet) {
            ActionSheet(title: Text("envSelect"), message: Text(""), buttons: [
                .default(Text("envCamera"), action: {
                    self.sourceType = .camera
                    self.source = .camera
                    self.detail.modalImageOpen = true
                }),
                .default(Text("envGallery"), action: {
                    self.sourceType = .photoLibrary
                    self.source = .gallery
                    self.detail.modalImageOpen = true
                }),
                .cancel()
            ])
        }
    }
    
}
