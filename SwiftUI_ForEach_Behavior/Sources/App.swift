import SwiftUI

@main
struct SwiftUI_ForEach_BehaviorApp: App {
  var body: some Scene {
    WindowGroup {
      ListView(type: .forEach)
        .border(.red)
      ListView(type: .listForEach)
        .border(.green)
      ListView(type: .listSectionForEach)
        .border(.blue)
    }
  }
}
