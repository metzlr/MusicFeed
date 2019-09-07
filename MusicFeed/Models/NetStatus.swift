//
//  NetStatus.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 9/2/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import Network

class NetStatus {
    
    // MARK: - Properties
    
    static let shared = NetStatus()
    
    var monitor: NWPathMonitor?
    
    var isMonitoring = false
    
    var didStartMonitoringHandler: (() -> Void)?
    
    var didStopMonitoringHandler: (() -> Void)?
    
    var netStatusChangeHandler: (() -> Void)?
    
    
    var isConnected: Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }
    
    // MARK: - Init & Deinit
    
    private init() {
        
    }
    
    
    deinit {
        stopMonitoring()
    }
    
    
    // MARK: - Method Implementation
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetStatus_Monitor")
        monitor?.start(queue: queue)
        
        monitor?.pathUpdateHandler = { _ in
            self.netStatusChangeHandler?()
        }
        
        isMonitoring = true
        didStartMonitoringHandler?()
    }
    
    
    func stopMonitoring() {
        guard isMonitoring, let monitor = monitor else { return }
        monitor.cancel()
        self.monitor = nil
        isMonitoring = false
        didStopMonitoringHandler?()
    }
    
}
