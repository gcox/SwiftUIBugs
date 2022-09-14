In iOS 16, the `deleteDisabled` modifier does not correctly suppress the delete buttons on `List` rows. 

A common use case of mine is to have a `List` that needs to support swipe-to-delete in non-edit mode and multiple selection while in edit mode. In edit mode, deletion would be facilitated by selecting the rows the user wants to delete, then tapping a button or menu item to apply some action to all those rows (deletion being one of the available actions). 
To save horizontal space, I disable per-row deletion while in edit mode so the delete buttons aren't present. This works fine with a `UITableView`. Unfortunately, for SwiftUI's `List`, there is a bug that prevents the delete buttons from being consistently hidden when the `List` is in edit mode.
The behavior is that rows visible when the `List` enters edit mode include the delete button, but rows that are off screen correctly suppress the delete button. 

Passing `true` to the `deleteDisabled` modifier nor passing `nil` to the `onDelete` modifier causes the list to render correctly. The only solution I've found so far is to completely re-render the list by using the `id` modifier, but that is not a reasonable workaround.
