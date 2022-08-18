//
//  PanelCardView.swift
//  PRO
//
//  Created by VMO on 4/12/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct PanelSummaryView: View {
    var panel: Panel & SyncEntity
    var defaultTab = "CARD"
    
    @StateObject var tabRouter = TabRouter()
    @State var sections = [SectionCard]()
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "") {
                
            }
            switch tabRouter.current {
            case "CONTACTS":
                ContactListView(panel: panel)
            case "RECORD":
                MovementListView()
            default:
                ZStack(alignment: .bottomTrailing) {
                    DetailCardView(sections: sections)
                    FAB(image: "ic-edit") {
                        print(1)
                    }
                }
            }
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Image("ic-info")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / 4, alignment: .center)
                        .foregroundColor(tabRouter.current == "CARD" ? .cPrimary : .cAccent)
                        .onTapGesture {
                            tabRouter.current = "CARD"
                        }
                    Image("ic-map")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / 4, alignment: .center)
                        .foregroundColor(tabRouter.current == "LOCATIONS" ? .cPrimary : .cAccent)
                        .onTapGesture {
                            tabRouter.current = "LOCATIONS"
                        }
                    if panel.type == "F" || panel.type == "C" {
                        Image("ic-client")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / 4, alignment: .center)
                            .foregroundColor(tabRouter.current == "CONTACTS" ? .cPrimary : .cAccent)
                            .onTapGesture {
                                tabRouter.current = "CONTACTS"
                            }
                    }
                    Image("ic-report")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / 4, alignment: .center)
                        .foregroundColor(tabRouter.current == "RECORD" ? .cPrimary : .cAccent)
                        .onTapGesture {
                            tabRouter.current = "RECORD"
                        }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 46, maxHeight: 46)
        }
        .onAppear {
            load()
            tabRouter.current = defaultTab
        }
    }
    
    func load() {
        switch panel.type {
        case "C":
            let client = try! Realm().object(ofType: Client.self, forPrimaryKey: panel.id)
            //print("CT TOTAL: \(client?.contacts.count)")
            if let c = client {
                sections = SectionCard.to(client: c)
            }
        default:
            print("")
        }
    }
}

struct DetailCardView: View {
    var sections: [SectionCard]!
    var body: some View {
        List {
            ForEach(sections, id: \.title) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.details, id: \.title) {  detail in
                        switch detail.type {
                        case .text:
                            DetailCardTextView(detail: detail)
                        case .email:
                            DetailCardEmailView(detail: detail)
                        case .phone:
                            DetailCardPhoneView(detail: detail)
                        case .image:
                            Text("1")
                        case .url:
                            DetailCardURLView(detail: detail)
                        }
                    }
                }
            }
        }
    }
}

struct DetailCardTextView: View {
    var detail: SectionDetail!
    
    var body: some View {
        VStack {
            Text(detail.title)
                .fontWeight(.medium)
                .lineLimit(1)
                .font(.system(size: 14))
                .foregroundColor(.cPrimaryLight)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            Text(detail.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "--" : detail.content)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
        }
        .padding(.vertical, 4)
    }
}

struct DetailCardLocationView: View {
    var detail: SectionDetail!
    var body: some View {
        HStack {
            DetailCardTextView(detail: detail)
                .frame(minWidth: 0, maxWidth: .infinity)
            Image("ic-map")
                .resizable()
                .scaledToFit()
                .foregroundColor(.cPrimary)
                .frame(width: 32, height: 32, alignment: .center)
        }
    }
}

struct DetailCardEmailView: View {
    var detail: SectionDetail!
    var body: some View {
        HStack {
            DetailCardTextView(detail: detail)
                .frame(minWidth: 0, maxWidth: .infinity)
            Image("ic-envelope")
                .resizable()
                .scaledToFit()
                .foregroundColor(.cPrimary)
                .frame(width: 32, height: 32, alignment: .center)
        }
    }
}

struct DetailCardPhoneView: View {
    var detail: SectionDetail!
    var body: some View {
        HStack {
            DetailCardTextView(detail: detail)
                .frame(minWidth: 0, maxWidth: .infinity)
            Image("ic-phone-call")
                .resizable()
                .scaledToFit()
                .foregroundColor(.cPrimary)
                .frame(width: 32, height: 32, alignment: .center)
        }
    }
}

struct DetailCardURLView: View {
    var detail: SectionDetail!
    var body: some View {
        HStack {
            DetailCardTextView(detail: detail)
                .frame(minWidth: 0, maxWidth: .infinity)
            Image("ic-url")
                .resizable()
                .scaledToFit()
                .foregroundColor(.cPrimary)
                .frame(width: 32, height: 32, alignment: .center)
        }
    }
}
