//
//  DiaryFormView.swift
//  PRO
//
//  Created by VMO on 25/08/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

class DiaryActivityModel: ObservableObject {
    @Published var date: Date = Date()
    @Published var hourFrom: Date = Date()
    @Published var hourTo: Date = Date()
    @Published var comment: String = ""
}

enum DiaryFormLayout {
case main, selection, map
}

struct DiaryFormView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var layout: DiaryFormLayout = .main
    @State private var date: Date = Date()
    @State private var startTime: Date = Date()
    @State private var interval: Int = 30
    
    @State private var modalActivity: Bool = false
    @State private var modalMainMenu: Bool = false
    @State private var modalSelectionMenu: Bool = false
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "envDiary") {
                viewRouter.currentPage = "MASTER"
            }
            ZStack(alignment: .bottom) {
                VStack {
                    VStack {
                        HStack {
                            Button(action: {
                                
                            }) {
                                Image("ic-smart")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .padding(8)
                            }
                            .frame(width: 44, height: 44, alignment: .center)
                            HStack {
                                Button(action: {
                                    var dateComponent = DateComponents()
                                    dateComponent.day = -1
                                    date = Calendar.current.date(byAdding: dateComponent, to: date) ?? Date()
                                }) {
                                    Image("ic-double-arrow-left")
                                        .resizable()
                                        .foregroundColor(.cIcon)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .padding(8)
                                }
                                .frame(width: 44, height: 44, alignment: .center)
                                Spacer()
                                DatePicker(selection: $date, displayedComponents: .date) {}
                                    .labelsHidden()
                                    .id(date)
                                    .onChange(of: date) { d in
                                        refresh()
                                    }
                                Spacer()
                                Button(action: {
                                    var dateComponent = DateComponents()
                                    dateComponent.day = 1
                                    date = Calendar.current.date(byAdding: dateComponent, to: date) ?? Date()
                                }) {
                                    Image("ic-double-arrow-right")
                                        .resizable()
                                        .foregroundColor(.cIcon)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .padding(8)
                                }
                                .frame(width: 44, height: 44, alignment: .center)
                            }
                            .padding(.horizontal, 10)
                            Button(action: {
                                layout = layout == .selection ? .main : .selection
                            }) {
                                Image("ic-selection")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .padding(8)
                            }
                            .frame(width: 44, height: 44, alignment: .center)
                        }
                        HStack {
                            Text("Start at \(Utils.dateFormat(date: startTime, format: "HH:mm"))")
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("Time interval: \(interval)")
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    ZStack(alignment: .bottom) {
                        ScrollView {
                            
                        }
                        HStack(alignment: .bottom) {
                            VStack {
                                if layout == .selection {
                                    FAB(image: "ic-done-all") {
                                        
                                    }
                                } else {
                                    FAB(image: "ic-timer") {
                                        
                                    }
                                }
                            }
                            Spacer()
                            VStack {
                                FAB(image: "ic-more") {
                                    if layout == .selection {
                                        modalSelectionMenu = true
                                    } else {
                                        modalMainMenu = true
                                    }
                                }
                            }
                        }
                        .padding(.bottom, Globals.UI_FAB_VERTICAL)
                        .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
                    }
                    if layout != .selection {
                        HStack {
                            Button(action: {
                                layout = .map
                            }) {
                                Image("ic-map")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .padding(8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                            EmptyView()
                                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
                            Button(action: {
                                modalActivity = true
                            }) {
                                Image("ic-activity")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .padding(8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                        }
                    }
                }
                if layout != .selection {
                    VStack {
                        FAB(image: "ic-plus", size: 60, margin: 32) {
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .partialSheet(isPresented: $modalActivity) {
            DiaryActivityFormView()
        }
        .partialSheet(isPresented: $modalMainMenu) {
            VStack(spacing: 20) {
                VStack {
                    Button {
                        
                    } label: {
                        Text("envIntervalToSchedule")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        
                    } label: {
                        Text("envHourStart")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        
                    } label: {
                        Text("envSaveAsGroup")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                }
                .background(Color.cBackground1dp)
                .cornerRadius(5)
                VStack {
                    Button {
                        
                    } label: {
                        Text("envMoveAll")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        
                    } label: {
                        Text("envDeleteAll")
                            .foregroundColor(.cDanger)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                }
                .background(Color.cBackground1dp)
                .cornerRadius(5)
            }
            .padding()
        }
        .partialSheet(isPresented: $modalSelectionMenu) {
            VStack(spacing: 20) {
                VStack {
                    Button {
                        
                    } label: {
                        Text("envContactType")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        
                    } label: {
                        Text("envContactPoint")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                }
                .background(Color.cBackground1dp)
                .cornerRadius(5)
                VStack {
                    Button {
                        
                    } label: {
                        Text("envMove")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        
                    } label: {
                        Text("envDelete")
                            .foregroundColor(.cDanger)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                }
                .background(Color.cBackground1dp)
                .cornerRadius(5)
            }
            .padding()
        }
    }
    
    func refresh() {
        
    }
    
}

struct DiaryActivityFormView: View {
    @State private var model: DiaryActivityModel = DiaryActivityModel()
    
    var body: some View {
        VStack {
            CustomSection {
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        DatePicker("envDate", selection: $model.date, displayedComponents: [.date])
                            .id(model.date)
                        Image("ic-calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 26)
                            .foregroundColor(.cIcon)
                    }
                    HStack {
                        VStack{
                            Text(NSLocalizedString("envFrom", comment: "From"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                            DatePicker("", selection: $model.hourFrom, displayedComponents: [.hourAndMinute])
                                .fixedSize()
                        }
                        .frame(maxWidth: .infinity)
                        VStack{
                            Text(NSLocalizedString("envTo", comment: "To"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                            DatePicker("", selection: $model.hourTo, in: model.hourFrom..., displayedComponents: [.hourAndMinute])
                                .fixedSize()
                        }
                        .frame(maxWidth: .infinity)
                        Image("ic-clock")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 26)
                            .foregroundColor(.cIcon)
                    }
                    VStack {
                        Text("envDTVComment")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor((model.comment.isEmpty) ? .cDanger : .cTextMedium)
                            .font(.system(size: 14))
                        VStack{
                            TextEditor(text: $model.comment)
                                .frame(height: 80)
                        }
                    }
                }
            }
            Button(action: {
                
            }) {
                Text("envSave")
                    .foregroundColor(.cTextHigh)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
        }
        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
    }
    
}
