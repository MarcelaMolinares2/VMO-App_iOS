//
//  ActivityListView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct ActivityListView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @ObservedResults(Activity.self, sortDescriptor: SortDescriptor(keyPath: "dateStart", ascending: false)) var activities
    @Binding var searchText: String
    @State var menuIsPresented = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                
            }
            FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                FormEntity(objectId: "").go(path: "DTV-FORM", router: viewRouter)
            }
        }
    }
}
