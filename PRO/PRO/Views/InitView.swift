//
//  InitView.swift
//  PRO
//
//  Created by VMO on 2/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI

struct InitView: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var viewRouter: ViewRouter
    @State var isExecuting = false
    @State var fails: [String: [Int16: String]] = [:]
    
    var body: some View {
        ZStack {
            if #available(iOS 14.0, *) {
                Color.cPrimary.ignoresSafeArea()
            } else {
                Color.cPrimary.edgesIgnoringSafeArea(.all)
            }
            VStack {
                VStack {
                    ZStack(alignment: .topTrailing) {
                        /*
                        KFImage(URL(string: "https://testing.vmocentral.com/assets/images/laboratories/\(UserDefaults.standard.string(forKey: Globals.LABORATORY_PATH) ?? "").png"))
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 140, alignment: .center)
                        */
                        Button(action: {
                            userSettings.successfullLogout()
                        }) {
                            Text("envLogout")
                                .foregroundColor(.cPrimaryDark)
                                .font(.system(size: CGFloat(18)))
                        }
                        .frame(width: 60, height: 30, alignment: .trailing)
                        .background(Color.white)
                        .padding(.trailing, 20)
                    }
                }
                .padding(.top, 40)
                .background(Color.white)
                Text("msgInitInfo")
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 70)
                    .multilineTextAlignment(.center)
                if !self.isExecuting {
                    VStack {
                        Button(action: {
                            doSync()
                        }) {
                            ZStack {
                                Color
                                    .cAccent
                                    .cornerRadius(.infinity)
                                Image("ic-cloud-download")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundColor(.cPrimaryDark)
                                    .frame(minWidth: 40.0, maxWidth: 40.0, minHeight: 40.0, maxHeight: 40.0)
                            }
                        }
                        .frame(minWidth: 50.0, maxWidth: 50.0, minHeight: 50.0, maxHeight: 50.0)
                    }
                    .frame(alignment: .center)
                }
                if self.isExecuting {
                    InlineLoader()
                    Text("msgInitWarning")
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .padding(.horizontal, 70)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                Image("logo-app")
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 70, alignment: .center)
            }
            .padding(.bottom, 30)
            .edgesIgnoringSafeArea(.all)
            if !self.isExecuting && !self.fails.isEmpty {
                GeometryReader { geo in
                    VStack {
                        VStack {
                            Image("logo-header")
                                .resizable()
                                .scaledToFit()
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 40, alignment: .center)
                                .background(Color.cPrimary)
                            Text("msgSyncError")
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                            Button(action: {
                                report()
                            }) {
                                Text("formReport")
                                    .foregroundColor(.cPrimaryDark)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 45, alignment: .center)
                        }
                        .background(Color.white)
                    }
                    .padding(.horizontal, 40)
                    .position(x:geo.frame(in:.global).midX,y:geo.frame(in:.global).midY)
                }
                .background(Color.black.opacity(0.45))
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    self.fails.removeAll()
                }
            }
        }
        .onAppear {
            UIApplication.setStatusBarStyle(.darkContent)
        }
    }
    
    func doSync() {
        isExecuting = true
        let operationQueue = OperationQueue()
        let syncOperation = SyncOperation()
        syncOperation.completionBlock = {
            DispatchQueue.main.async {
                self.viewRouter.currentPage = "MASTER"
            }
            /*
            if syncOperation.fails.isEmpty {
                DispatchQueue.main.async {
                    self.viewRouter.currentPage = "MASTER"
                }
            } else {
                self.fails = syncOperation.fails
            }
             */
            isExecuting = false
        }
        operationQueue.addOperations([syncOperation], waitUntilFinished: false)
    }
    
    func report() {
        print(self.fails)
        Utils.shareText(text: self.fails.description, fileName: "syncError")
    }
}

#if DEBUG
struct InitView_Previews: PreviewProvider {
    static var previews: some View {
        InitView()
    }
}
#endif
