//
//  ContentView.swift
//  snk'nlad
//
//  Created by falcon on 2021/6/30.
//

import SwiftUI

struct PortalMoveDirection {
  var offsetX: CGFloat
  var offsetY: CGFloat
}

struct ContentView: View {
  let screenWidth = UIScreen.main.bounds.width
  let playerColors: [Color] = [
    Color.green, Color.blue, Color.red, Color.purple
  ]

  @State private var boardGeometry: CGRect = CGRect.zero
  @State var boardPosition: [(CGFloat, CGFloat)] = [(CGFloat, CGFloat)](repeating: (0.0, 0.0), count: 26)
  
  @State var gridAttr: [Int] = [Int](repeating: 0, count: 26)
  @State var gridGridLocation: [Int] = [Int](repeating: 0, count: 26)
  
  @State var portals: [(Int, Int)] = [
    (3, 4),
    (12, 11),
    (13, -12),
    (24, -4),
  ]
  
  @State var diceTimer: xTimer? = nil
  @State var moveTimer: xTimer? = nil
  
  @State var gameDidInit: Bool = false
  @State var round: Int = 0
  @State var dicePoint: Int = 0
  @State var canDice: Bool = true
  
  @State var players: Int = 4
  
  @State var playerX: [CGFloat] = []
  @State var actualPlayerX: [CGFloat] = []
  @State var playerY: [CGFloat] = []
  @State var actualPlayerY: [CGFloat] = []
  @State var currentPosition: [Int] = []
  @State var targetPosition: [Int] = []
  
  @State var logStr: String = ""
  
  @State var isGameEnd: Bool = true
  @State var isWinnerDecided: Bool = false
  @State var portalMoveDirection: PortalMoveDirection = PortalMoveDirection(offsetX: 0, offsetY: 0)
  
  var body: some View {
    ZStack{
      Image("board")
        .resizable()
        .scaledToFit()
        .overlay(
          GeometryReader(content: { geometry in
            Color.clear.onAppear(perform: {
              boardGeometry = geometry.frame(in: .global)
            })
          })
        )
      Spacer()
      if(gameDidInit){
        ForEach(0..<players){ player in
          Image("player\(player + 1)")
            .resizable()
            .scaledToFit()
            .frame(width: screenWidth / 6)
            .offset(x: playerX[player], y: playerY[player])
        }
      }
    }
    .sheet(isPresented: $isGameEnd, content: {
      WinnerSheet(player: round % players, cb: initGame, isGameEnd: $isGameEnd, isWinnerDecided: $isWinnerDecided, players: $players)
    })
    Spacer()
    HStack{
      Button(action: {
        dice()
      }, label: {
        Image(systemName: "figure.walk.diamond")
          .resizable()
          .scaledToFit()
          .frame(width: 100)
          .foregroundColor((canDice) ? playerColors[round % players] : .gray)
      })
      .disabled(!canDice)
      .padding()
      Text("\(dicePoint)")
        .font(.system(size: 100))
        .padding()
    }
    Text("Log: \(logStr)")
//    Button("ADD"){
//      let player = round % players
//      if(currentPosition[player] + 1 < 26){
//        dicePoint = 1
//      }
//      else{
//        currentPosition[player] = 0
//      }
//      move()
//    }
  }
  
  func initGame(){
    var rowIndexes = [Int]()
    var rowIndex = [Int]()
    var row = 1
    for i in 0...26{
      rowIndex.append(i)
      if(i % 5 == 0){
        if(row % 2 == 0){
          rowIndex.reverse()
        }
        rowIndexes += rowIndex
        rowIndex = []
        row += 1
      }
    }
    rowIndexes.reverse()
    row = 0
    let xUnit = (boardGeometry.maxX) / 5
    let yUnit = (boardGeometry.maxY) / 6
    let xMax = boardGeometry.maxX / 2
    let yMax = boardGeometry.maxY / 2
    for i in 0...5{
      for j in 1...5{
        self.boardPosition[rowIndexes[row]] = (yUnit * CGFloat(j) - yMax, xUnit * CGFloat(i) - xMax)
        row += 1
        if(row == 26){ break }
      }
      if(row == 26){ break }
    }
    
    for portal in portals{
      gridAttr[portal.0] = portal.1
    }
    
    diceTimer = xTimer(time: 0.6, interval: 0.05, callback: self._dice, callbackOnTimerDone: self.move)
    playerX = [CGFloat](repeating: 0, count: players)
    actualPlayerX = [CGFloat](repeating: 0, count: players)
    playerY = [CGFloat](repeating: 0, count: players)
    actualPlayerY = [CGFloat](repeating: 0, count: players)
    currentPosition = [Int](repeating: 0, count: players)
    targetPosition = [Int](repeating: 0, count: players)
    resetGame()
    gameDidInit = true
    canDice = true
  }
  
  func dice(){
    diceTimer?.start()
    canDice = false
  }

  func _dice(){
    dicePoint = Int.random(in: 1...6)
  }
  
  func move(){
//    dicePoint = 25
    let player = round % players
    if(targetPosition[player] + dicePoint < 26){
      targetPosition[player] += dicePoint
//      targetPosition[player] += gridAttr[targetPosition[player]]
      logStr = "Player \(player) move \(targetPosition[player] - currentPosition[player]) blocks!"
      moveTimer = xTimer(time: abs(Double(targetPosition[player] - currentPosition[player]) + 1) * 0.2, interval: 0.2, callback: self._move, callbackOnTimerDone: self.onMoveDone)
      moveTimer?.start()
    }else{
      logStr = "Player \(player) overflow!"
      onMoveDone()
    }
  }
  
  func _move(){
    let player = round % players
    if(currentPosition[player] < targetPosition[player]){
      currentPosition[player] += 1
      playerX[player] = boardPosition[currentPosition[player]].0
      playerY[player] = boardPosition[currentPosition[player]].1
    }
    if(currentPosition[player] > targetPosition[player]){
      currentPosition[player] -= 1
      playerX[player] = boardPosition[currentPosition[player]].0
      playerY[player] = boardPosition[currentPosition[player]].1
    }
  }
  
  func onMoveDone(){
    let player = round % players
    if(gridAttr[currentPosition[player]] != 0){
      targetPosition[player] += gridAttr[targetPosition[player]]
      print("\(playerY[player]) -> \(boardPosition[targetPosition[player]].1), \(playerX[player]) -> \(boardPosition[targetPosition[player]].0)")
      let offsetY = (boardPosition[targetPosition[player]].1 - playerY[player])
      print("offsetY = \(offsetY)")
      portalMoveDirection.offsetY = CGFloat(offsetY / abs(offsetY))
      let offsetX = (boardPosition[targetPosition[player]].0 - playerX[player])
      print("offsetX = \(offsetX)")
      portalMoveDirection.offsetX = CGFloat(offsetX / abs(offsetX))
      
      print(portalMoveDirection)

      logStr = "Player \(player) got into portal, teleporting \(targetPosition[player] - currentPosition[player]) blocks!"
      
      let time = (abs(offsetX) > abs(offsetY)) ? abs(offsetX) : abs(offsetY)
      moveTimer = xTimer(time: Double(time) * 0.01, interval: 0.01, callback: self._portalMove, callbackOnTimerDone: self.onMoveDone)
      
      currentPosition[player] = targetPosition[player]

      moveTimer?.start()
    }else{
      if(currentPosition[player] == 25){
        isWinnerDecided = true
        isGameEnd = true
        gameDidInit = false
        return
      }
      round += 1
      canDice = true
    }
  }
  
  func _portalMove(){
    let player = round % players
    if(playerY[player] != boardPosition[targetPosition[player]].1){
      playerY[player] += portalMoveDirection.offsetY
    }
    if(playerX[player] != boardPosition[targetPosition[player]].0){
      playerX[player] += portalMoveDirection.offsetX
    }
  }
  
  func jump(){
    let player = round % players
    if(currentPosition[player] + dicePoint < 26){
      currentPosition[player] += dicePoint
      currentPosition[player] += gridAttr[currentPosition[player]]
    }
    playerX[player] = boardPosition[currentPosition[player]].0
    playerY[player] = boardPosition[currentPosition[player]].1
    round += 1
  }
  
  func resetGame(){
    currentPosition = [Int](repeating: 0, count: players)
    targetPosition = [Int](repeating: 0, count: players)
    for player in 0..<players{
      currentPosition[player] = 0
      playerX[player] = boardPosition[currentPosition[player]].0 + CGFloat((10 * player))
      playerY[player] = boardPosition[currentPosition[player]].1
    }
    round = 0
  }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
