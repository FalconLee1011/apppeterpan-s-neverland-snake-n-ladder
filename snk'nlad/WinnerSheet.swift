//
//  WinnerSheet.swift
//  HwHoldem
//
//  Created by falcon on 2021/3/24.
//

import SwiftUI

struct WinnerSheet: View {
  let screenWidth = UIScreen.main.bounds.width
  
  @State var player: Int
  @State var cb: () -> Any?
  
  @Binding var isGameEnd: Bool
  @Binding var isWinnerDecided: Bool
  @Binding var players: Int
  
  var body: some View {
    if(isWinnerDecided){
      Text("Winner is Player\(player) !")
      Image("player\(player + 1)")
        .resizable()
        .scaledToFit()
        .frame(width: screenWidth / 2)
        .padding(.bottom, 40)
    }
    Button(action: {
      isGameEnd = false
      cb()
    }, label: {
      Image(systemName: (isWinnerDecided) ? "repeat.circle" : "chevron.right.circle")
        .resizable()
        .scaledToFit()
        .frame(width: 35)
        .foregroundColor(.white)
      Text((isWinnerDecided) ? "Replay" : "Play")
        .font(.system(size: 25))
        .foregroundColor(.white)
    })
    Divider()
    HStack{
      Image(systemName: "wrench.and.screwdriver")
        .resizable()
        .scaledToFit()
        .frame(width: 35)
      Text("Settings")
        .font(.system(size: 25))
    }
    HStack{
      ForEach(0..<players, id: \.self){ player in
        VStack{
          Image("player\(player + 1)")
            .resizable()
            .scaledToFit()
            .frame(width: screenWidth / 6)
          Text("Player\(player + 1)")
        }
      }
    }
    .padding(.top, 15)
    .padding(.bottom, 15)
    HStack{
      Button(action: {
        players += 1
      }, label: {
        Image(systemName: "plus.diamond")
          .resizable()
          .scaledToFit()
          .frame(width: 30)
      })
      .disabled(players == 4)
      .foregroundColor((players == 4) ? .gray : .white)
      Button(action: {
        players -= 1
      }, label: {
        Image(systemName: "minus.diamond")
          .resizable()
          .scaledToFit()
          .frame(width: 30)
      })
      .disabled(players == 2)
      .foregroundColor((players == 2) ? .gray : .white)
    }
  }
}
