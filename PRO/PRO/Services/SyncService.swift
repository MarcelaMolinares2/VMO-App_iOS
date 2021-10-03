//
//  SyncService.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import BackgroundTasks

class SyncOperation: Operation {
    var fails: [String: [Int16: String]] = [:]
    
    @objc private enum State: Int {
        case ready
        case executing
        case finished
    }
    
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
    
    override func main() {
        guard !dependencies.contains(where: { $0.isCancelled }), !isCancelled else {
            return
        }
        self.syncTertiary()
    }
    
    public final func finish() {
        if isExecuting {
            state = .finished
        }
    }
    
    func syncPrimary() {
        let operationQueue = OperationQueue()
        let syncPrimary = SyncPrimaryService()
        syncPrimary.completionBlock = {
            self.fails.merge(dict: syncPrimary.fails)
            self.finish()
        }
        operationQueue.addOperations([syncPrimary], waitUntilFinished: true)
    }
    
    func syncSecondary() {
        let operationQueue = OperationQueue()
        let syncSecondary = SyncSecondaryService()
        syncSecondary.completionBlock = {
            self.fails.merge(dict: syncSecondary.fails)
            self.syncPrimary()
        }
        operationQueue.addOperations([syncSecondary], waitUntilFinished: true)
    }
    
    func syncTertiary() {
        let operationQueue = OperationQueue()
        let syncTertiary = SyncTertiaryService()
        syncTertiary.completionBlock = {
            self.fails.merge(dict: syncTertiary.fails)
            self.syncSecondary()
        }
        operationQueue.addOperations([syncTertiary], waitUntilFinished: true)
    }
    
}
