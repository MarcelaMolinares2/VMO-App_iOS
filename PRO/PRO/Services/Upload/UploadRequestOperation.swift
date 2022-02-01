//
//  SyncRecurrentService.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import Foundation

enum UploadRequestServices {
    case activity, client, doctor, patient, pharmacy, potential
}

class UploadRequestOperation: Operation {
    @objc private enum State: Int {
        case ready
        case executing
        case finished
    }
    
    var step = 0
    var fails: [String: [Int16: String]] = [:]
    
    var prefix = ""
    var services: [UploadRequestServices] = []
    
    
    private var _state = State.ready
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".op.state", attributes: .concurrent)
    
    @objc private dynamic var state: State {
        get { return stateQueue.sync { _state } }
        set { stateQueue.sync(flags: .barrier) { _state = newValue } }
    }
    
    public override var isAsynchronous: Bool { return true }
    open override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    public override var isExecuting: Bool {
        return state == .executing
    }
    
    public override var isFinished: Bool {
        return state == .finished
    }
    
    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady",  "isFinished", "isExecuting"].contains(key) {
            return [#keyPath(state)]
        }
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    public override func start() {
        if isCancelled {
            finish()
            return
        }
        self.state = .executing
        main()
    }
    
    open override func main() {
        fatalError("Implement in sublcass to perform task")
    }
    
    public final func finish() {
        if isExecuting {
            state = .finished
        }
    }
    
}
