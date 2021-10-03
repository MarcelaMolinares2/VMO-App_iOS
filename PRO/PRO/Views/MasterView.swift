//
//  MasterView.swift
//  PRO
//
//  Created by VMO on 2/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI

struct MasterView: View {
    
    var subviews = [
        UIHostingController(rootView: SLAIDPanelView()),
        UIHostingController(rootView: DashboardPanelView()),
        UIHostingController(rootView: NotificationPanelView())
    ]
    @State var currentPageIndex = 1
    
    var body: some View {
        PageViewController(viewControllers: subviews, currentPageIndex: $currentPageIndex)
            .background(Color.blue)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                load()
            }
    }
    
    func load() {
        let operationQueue = OperationQueue()
        let syncOperation = SyncOperation()
        operationQueue.addOperations([syncOperation], waitUntilFinished: false)
    }
}

struct MasterView_Previews: PreviewProvider {
    static var previews: some View {
        MasterView()
    }
}
