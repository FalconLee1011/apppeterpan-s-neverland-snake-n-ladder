//
//  Timer.swift
//  hw-gesture
//
//  Created by falcon on 2021/4/10.
//

import Foundation

class xTimer{
  var time: Double
  var interval: Double
  var isCountion: Bool = false
  var timer: Timer = Timer()
  var callback: () -> Any
  var callbackOnTimerDone: (() -> Any)?
  
  var _intervalHasBeen: Double

  init(time: Double, interval: Double, callback: @escaping () -> Any, callbackOnTimerDone: (() -> Any)? = nil){
    self.time = time
    self.interval = interval
    self.callback = callback
    self._intervalHasBeen = 0
    self.callbackOnTimerDone = callbackOnTimerDone ?? nil
  }

  func start(){
    self.timer = Timer.scheduledTimer(timeInterval: self.interval, target: self, selector: #selector(self._callback), userInfo: nil, repeats: true)
  }
  
  func reset(){
    self.timer.invalidate()
    self._intervalHasBeen = 0
  }
  
  func stop() -> Any?{
    self.timer.invalidate()
    self.timer = Timer()
    if(self.callbackOnTimerDone != nil){
      return self.callbackOnTimerDone!()
    }
    return nil
  }
  
  @objc private func _callback() -> Any{
    self._intervalHasBeen += self.interval
    if(self._intervalHasBeen >= self.time){
      self.reset()
      print("TIMER STOP")
      if(self.callbackOnTimerDone != nil){
        return self.callbackOnTimerDone!()
      }
    }
    return self.callback()
  }
}
