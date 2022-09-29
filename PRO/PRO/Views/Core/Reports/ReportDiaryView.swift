//
//  ReportDiaryView.swift
//  PRO
//
//  Created by VMO on 19/09/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct ReportDiaryView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var date: Date = Date()
    @State private var userSelected = 0
    @State private var isProcessing = false
    
    @State private var diaries: [Diary] = []
    
    let realm = try! Realm()
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "envDiaryReport") {
                viewRouter.currentPage = "REPORTS-VIEW"
            }
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
            if isProcessing {
                VStack {
                    Spacer()
                    LottieView(name: "sync_animation", loopMode: .loop, speed: 1)
                        .frame(width: 300, height: 200)
                    Spacer()
                }
            } else {
                CustomReportListView(realm: realm, hasMap: true, userSelected: $userSelected) {
                    ForEach($diaries, id: \.objectId) { $diary in
                        VStack {
                            switch diary.type {
                                case "A":
                                    DiaryActivityItemView(diary: diary)
                                default:
                                    DiaryPanelItemView(realm: realm, diary: diary)
                            }
                        }
                    }
                } map: {
                    VStack {
                        DiaryListMapView(items: $diaries) { diary in
                        }
                    }
                } onAgentChanged: {
                    refresh()
                }
            }
        }
        .onAppear {
            refresh()
        }
    }
    
    func refresh() {
        isProcessing = true
        diaries.removeAll()
        let dateFormat = Utils.dateFormat(date: date)
        let userId = userSelected > 0 ? userSelected : JWTUtils.sub()
        AppServer().getRequest(path: "vm/diary/by/user/\(userId)/\(dateFormat)/\(dateFormat)/p") { success, code, data in
            if success {
                if let rs = data as? [String] {
                    for item in rs {
                        let decoded = try! JSONDecoder().decode(Diary.self, from: item.data(using: .utf8)!)
                        diaries.append(decoded)
                    }
                }
            }
            DispatchQueue.main.async {
                isProcessing = false
            }
        }
    }
    
}
