//
//  GDSilentDetector.swift
//  GDSilentDetector
//
//  Created by Gwyn Durbridge on 16/9/17.
//
//
//  Adapated from https://github.com/fopina/MuteDetector
//

import Foundation
import AudioToolbox

public protocol GDSilentDetectorDelegate {
    func gotSilentStatus(isSilent: Bool)
}

@available(iOS 9.0, *)
public class GDSilentDetector {
    
    public var delegate: GDSilentDetectorDelegate?
    let soundURL = NSURL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Caches/silent.wav")
    
    public init() {
        
    }
    
    fileprivate func createSound() {
        print("creating sound file...")
        
        let sampleRate = 44000.0
        let samples = 0.2
        var length = Int(sampleRate * samples * 2.0) //two bytes per sample
        var temp = 0
        
        // initialize with room for RIFF chunk (36) + "data" header from data chunk + actual sound dataa
        
        var data = Data(capacity: length + 36 + 4)
        data.append("RIFF".data(using: String.Encoding.ascii)!)
        temp = length + 36
        data.append(Data(bytes: &temp, count: 4))
        data.append("WAVE".data(using: String.Encoding.ascii)!)
        data.append("fmt ".data(using: String.Encoding.ascii)!)
        temp = 16
        data.append(Data(bytes: &temp, count: 4))
        temp = 1
        data.append(Data(bytes: &temp, count: 2))
        data.append(Data(bytes: &temp, count: 2))
        temp = Int(sampleRate)
        data.append(Data(bytes: &temp, count: 4))
        temp = temp * 2
        data.append(Data(bytes: &temp, count: 4))
        temp = 2
        data.append(Data(bytes: &temp, count: 2))
        temp = 16
        data.append(Data(bytes: &temp, count: 2))
        data.append("data".data(using: String.Encoding.ascii)!)
        data.append(Data(bytes: &length, count: 4))
        temp = 0
        
        let nullByte = Data(bytes: &temp, count: 1)
        for _ in 0...length { data.append(nullByte) }
        
        //Save the generated sound file
        do { try data.write(to: soundURL!, options: .atomic) }
        catch { print("Error saving sound file.") }
    }
    
    public func checkSilent() {
        if (FileManager.default.fileExists(atPath: (soundURL!.path))) {
            //Sound file exists, create system sound
            
            var soundID: SystemSoundID = 0
            var yes: UInt32 = 1
            AudioServicesCreateSystemSoundID(soundURL! as CFURL, &soundID)
            AudioServicesSetProperty(kAudioServicesPropertyIsUISound, UInt32(MemoryLayout.size(ofValue: soundID)), &soundID, UInt32(MemoryLayout.size(ofValue: yes)), &yes)
            
            let start = Date.timeIntervalSinceReferenceDate
            
            AudioServicesPlaySystemSoundWithCompletion(soundID) {
                let end = Date.timeIntervalSinceReferenceDate
                let elapsed = end - start
                //                print("elapsed: \(elapsed)")
                //If the sound played too quickly then we know the device is muted
                self.delegate?.gotSilentStatus(isSilent: elapsed < 0.2)
                AudioServicesRemoveSystemSoundCompletion(soundID)
                AudioServicesDisposeSystemSoundID(soundID)
            }
        }
        else {
            //Sound file does not exist
            //Create then recheck
            createSound()
            checkSilent()
        }
    }
}

