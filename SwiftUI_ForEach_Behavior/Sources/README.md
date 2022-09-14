In iOS 16, the laziness of `ForEach` differs depending on what it is contained in. 

This demo shows statistics about how `ForEach` behaves in 3 different scenerios:
1. In a `ScrollView` -> `LazyVStack`
2. In a `List`
3. In a `List` -> `Section`

The statistics indicate how many times elements are accessed, how often the `ForEach` body is entered, how often it's content view is initialized, and how often it's content view's body property is accessed. 

The behavior of `ForEach` in the first two scenarios is mostly expected (*). In the 3rd scenario, however, the behavior is far from lazy. In that scenario, every data element is accessed at least twice and the `ForEach` body is entered at least once, which also means the content view is initialized at least once for every data element. The only part of this scenario that is lazy is invocation of the content view's body property. Better than nothing, I guess.

This could cause serious problems for very large lists. 

* Scenario 2 seems to suffer from the same problem as Scenario 3, but this appears to only occur the first time the app is run on a device. It's not clear why that would make a difference.
