import SwiftUI

enum ContentViewType: String, CaseIterable {
  case forEach
  case listForEach
  case listSectionForEach
}

struct ViewModel: Identifiable {
  var id: String
  var title: String

  init(uuid: UUID, title: String) {
    self.id = uuid.uuidString
    self.title = title
  }
}

class ViewModelCollection: RandomAccessCollection {
  private var sourceObjects: [UUID] = (0 ..< 250).map { _ in UUID() }
  private var cache = [ViewModel.ID: ViewModel]()
  private var statistics: Statistics

  init(statistics: Statistics) {
    self.statistics = statistics
  }

  var count: Int { sourceObjects.count }
  var startIndex: Int { 0 }
  var endIndex: Int { count }

  subscript(position: Int) -> ViewModel {
    statistics.accessedSubscript(at: position)

    let source = sourceObjects[position]
    if let vm = cache[source.uuidString] {
      statistics.elementCacheHit(forID: vm.id)
      return vm
    }

    let vm = ViewModel(uuid: source, title: "Row Title: \(source.uuidString)")
    cache[vm.id] = vm
    return vm
  }
}

struct ListView: View {
  let type: ContentViewType
  let collection: ViewModelCollection

  init(type: ContentViewType) {
    self.type = type

    self.collection = ViewModelCollection(
      statistics: Statistics.byContentType[type]!
    )
  }

  var statistics: Statistics {
    Statistics.byContentType[type]!
  }

  var body: some View {
    switch type {
    case .forEach:
      ScrollView {
        LazyVStack(alignment: .leading) {
          Section {
            ForEach(collection) { vm in
              let _ = statistics.enteredForEachBody(forID: vm.id)
              RowView(viewModel: vm, statistics: statistics)
            }
          }
        }
      }
    case .listForEach:
      List {
        ForEach(collection) { vm in
          let _ = statistics.enteredForEachBody(forID: vm.id)
          RowView(viewModel: vm, statistics: statistics)
        }
      }
    case .listSectionForEach:
      List {
        Section {
          ForEach(collection) { vm in
            let _ = statistics.enteredForEachBody(forID: vm.id)
            RowView(viewModel: vm, statistics: statistics)
          }
        }
      }
    }
  }
}

struct RowView: View {
  var viewModel: ViewModel
  var statistics: Statistics

  init(viewModel: ViewModel, statistics: Statistics) {
    self.viewModel = viewModel
    self.statistics = statistics
    self.statistics.calledRowViewInit(forID: viewModel.id)
  }

  var body: some View {
    let _ = statistics.accessedRowViewBody(forID: viewModel.id)
    Text(viewModel.title)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ListView(type: .forEach)
  }
}
