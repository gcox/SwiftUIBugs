import SwiftUI

struct ContentView: View {
  @State var editMode: EditMode = .inactive

  var body: some View {
    NavigationStack {
      ListView()
        .environment(\.editMode, $editMode)
    }
  }
}

struct ListView: View {
  @Environment(\.editMode) var editMode

  @State var data = (0 ..< 25).reduce(into: [String]()) { partialResult, idx in
    partialResult.append("Row \(idx)")
  }

  @State var selection = Set<String>()
  @State var uuid = UUID().uuidString

  var isEditing: Bool {
    editMode?.wrappedValue.isEditing ?? false
  }

  var body: some View {
    VStack {
      Section(header:
        Text("After clicking Edit, delete buttons are show next to rows even though deletion should be disabled. After scrolling, they are removed from visible rows. Tapping Done and tapping Edit again may then show delete buttons next to some unpredictable subset of rows.")
          .font(.subheadline)
          .padding()
          .foregroundColor(.red)
      ) {
        List(selection: $selection) {
          let isEditingText = isEditing ? "Editing" : "Not Editing"
          ForEach(data, id: \.self) {
            Text("\($0) - \(isEditingText)")
              .deleteDisabled(isEditing)
          }
          .onDelete(perform: delete)
        }
        .listStyle(.plain)
      }
    }
    .navigationTitle("Bug Demonstration")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        EditButton()
      }
    }
  }

  func delete(_ indicies: IndexSet) {
    data.remove(atOffsets: indicies)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
