import Combine
import Foundation

extension Sequence where Element == Int {
  var sum: Int {
    reduce(into: 0, +=)
  }
}

class Statistics: CustomStringConvertible, ObservableObject {
  static let byContentType = ContentViewType.allCases
    .reduce(into: [ContentViewType: Statistics]()) { acc, type in
      acc[type] = Statistics(name: type.rawValue)
    }

  private let name: String
  private var elementAccesses = [Int: Int]()
  private var elementCacheHits = [ViewModel.ID: Int]()
  private var forEachBodyEntries = [ViewModel.ID: Int]()
  private var rowViewInitCalls = [ViewModel.ID: Int]()
  private var rowViewBodyAccesses = [ViewModel.ID: Int]()

  private let touched = PassthroughSubject<Void, Never>()
  private var cancellables = Set<AnyCancellable>()

  init(name: String) {
    self.name = name
    touched
      .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
      .sink { _ in
        print(self.description)
      }
      .store(in: &cancellables)
  }

  private func perKeyAvg<ID>(for collection: [ID: Int]) -> Float where ID: Hashable {
    guard collection.count > 0 else {
      return 0
    }
    return Float(collection.values.sum) / Float(collection.count)
  }

  private func cacheHitRate() -> Float {
    let accessSum = elementAccesses.values.sum
    guard accessSum > 0 else {
      return 0
    }
    return Float(elementCacheHits.values.sum) / Float(elementAccesses.values.sum)
  }

  var description: String {
    """

    STATISTICS SUMMARY: \(name)
    ----------------------------------------------
    Element access count/perKeyAvg:          \(elementAccesses.values.sum)/\(perKeyAvg(for: elementAccesses))
    Element cache hit count/perKeyAvg/rate:  \(elementCacheHits.values.sum)/\(perKeyAvg(for: elementCacheHits))/\(cacheHitRate())
    Number of unique elements accessed:      \(elementAccesses.keys.count)
    Least number of accesses for any key:    \(elementAccesses.values.min() ?? 0)
    ForEach body entry count/perKeyAvg:      \(forEachBodyEntries.values.sum)/\(perKeyAvg(for: forEachBodyEntries))
    RowView init calls count/perKeyAvg:      \(rowViewInitCalls.values.sum)/\(perKeyAvg(for: rowViewInitCalls))
    RowView body calls count/perKeyAvg:      \(rowViewBodyAccesses.values.sum)/\(perKeyAvg(for: rowViewBodyAccesses))
    ----------------------------------------------

    """
  }

  func accessedSubscript(at position: Int) {
    elementAccesses[position] = (elementAccesses[position] ?? 0) + 1
    touched.send(())
  }

  func elementCacheHit(forID id: ViewModel.ID) {
    elementCacheHits[id] = (elementCacheHits[id] ?? 0) + 1
    touched.send(())
  }

  func enteredForEachBody(forID id: ViewModel.ID) {
    forEachBodyEntries[id] = (forEachBodyEntries[id] ?? 0) + 1
    touched.send(())
  }

  func calledRowViewInit(forID id: ViewModel.ID) {
    rowViewInitCalls[id] = (rowViewInitCalls[id] ?? 0) + 1
    touched.send(())
  }

  func accessedRowViewBody(forID id: ViewModel.ID) {
    rowViewBodyAccesses[id] = (rowViewBodyAccesses[id] ?? 0) + 1
    touched.send(())
  }
}
