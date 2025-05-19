//
//  NFCModel.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 14/05/25.
//

import Foundation
import CoreNFC

class NFCReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var scannedMessage: String = ""
    private var session: NFCNDEFReaderSession?
    var onScan: (() -> Void)?
    
    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC not available")
            return
        }
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Kalem anying scan dulu"
        session?.begin()
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate Methods
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC Session invalidated: \(error.localizedDescription)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            for message in messages {
                for record in message.records {
                    if let text = String(data: record.payload, encoding: .utf8) {
                        self.scannedMessage = text
                        
                        if let onScan = self.onScan {
                            onScan()
                        }
                    }
                }
            }
        }
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        
    }
    
    func assignOnScan(_ closure: @escaping () -> Void) {
        self.onScan = closure
    }
}
