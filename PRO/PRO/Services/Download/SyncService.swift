//
//  SyncService.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import BackgroundTasks

enum SyncOperationLevel {
    case onDemand, recurrent, primary, secondary, tertiary, quaternary
}

class SyncOperation: Operation {
    var fails: [String: [Int16: String]] = [:]
    let intervals: [SyncOperationLevel: Int] = [
        .onDemand: 0,
        .recurrent: 120,
        .primary: 360,
        .secondary: 720,
        .tertiary: 1440,
        .quaternary: 3360
    ]
    
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
        self.syncQuaternary()
    }
    
    public final func finish() {
        if isExecuting {
            state = .finished
        }
    }
    
    func syncRecurrent() {
        if validateInterval(level: .recurrent) {
            let operationQueue = OperationQueue()
            let syncRecurrent = SyncRecurrentService()
            syncRecurrent.completionBlock = {
                self.fails.merge(dict: syncRecurrent.fails)
                SyncUtils.updateInterval(level: .recurrent)
                self.finish()
            }
            operationQueue.addOperations([syncRecurrent], waitUntilFinished: true)
        } else {
            self.finish()
        }
    }
    
    func syncPrimary() {
        if validateInterval(level: .primary) {
            let operationQueue = OperationQueue()
            let syncPrimary = SyncPrimaryService()
            syncPrimary.completionBlock = {
                self.fails.merge(dict: syncPrimary.fails)
                SyncUtils.updateInterval(level: .primary)
                self.syncRecurrent()
            }
            operationQueue.addOperations([syncPrimary], waitUntilFinished: true)
        } else {
            self.syncRecurrent()
        }
    }
    
    func syncSecondary() {
        if validateInterval(level: .secondary) {
            let operationQueue = OperationQueue()
            let syncSecondary = SyncSecondaryService()
            syncSecondary.completionBlock = {
                self.fails.merge(dict: syncSecondary.fails)
                SyncUtils.updateInterval(level: .secondary)
                self.syncPrimary()
            }
            operationQueue.addOperations([syncSecondary], waitUntilFinished: true)
        } else {
            self.syncPrimary()
        }
    }
    
    func syncTertiary() {
        if validateInterval(level: .tertiary) {
            let operationQueue = OperationQueue()
            let syncTertiary = SyncTertiaryService()
            syncTertiary.completionBlock = {
                self.fails.merge(dict: syncTertiary.fails)
                SyncUtils.updateInterval(level: .tertiary)
                self.syncSecondary()
            }
            operationQueue.addOperations([syncTertiary], waitUntilFinished: true)
        } else {
            self.syncSecondary()
        }
    }
    
    func syncQuaternary() {
        if validateInterval(level: .quaternary) {
            let operationQueue = OperationQueue()
            let syncQuaternary = SyncQuaternaryService()
            syncQuaternary.completionBlock = {
                self.fails.merge(dict: syncQuaternary.fails)
                SyncUtils.updateInterval(level: .quaternary)
                self.syncTertiary()
            }
            operationQueue.addOperations([syncQuaternary], waitUntilFinished: true)
        } else {
            self.syncTertiary()
        }
    }
    
    func validateInterval(level: SyncOperationLevel) -> Bool {
        guard let interval = intervals[level] else { return false }
        if interval <= 0 {
            return true
        }
        
        guard let key = SyncUtils.keys[level] else { return false }
        let last = UserDefaults.standard.double(forKey: key)
        if last <= 0 {
            return true
        } else {
            let timestamp: Double = NSDate().timeIntervalSince1970
            return (Int(timestamp - last) / 60) > interval
        }
    }
    
}
