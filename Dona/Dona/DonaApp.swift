//
//  DonaApp.swift
//  Dona
//
//  Created by Aniket Kumar on 18/07/24.
//

import SwiftUI
import SwiftData

@main
struct DonaApp: App {
    var body: some Scene {
          WindowGroup {
              ContentView()
                  .preferredColorScheme(.dark)
          }
          .modelContainer(for: [Item.self])
      }
}
