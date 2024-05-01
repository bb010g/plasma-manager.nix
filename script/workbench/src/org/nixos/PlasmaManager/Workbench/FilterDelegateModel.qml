// Begining of code from <https://github.com/stephenquan/qt5-qml-toolkit> {{{
// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2022 Stephen Quan
import QtQml
import QtQml.Models as Models

Models.DelegateModel {
  property var filter: null
  readonly property bool running: !filtered
  readonly property bool filtered: updateIndex >= allItems.count
  readonly property int progress: filtered ? 100 : Math.floor(100 * updateIndex / allItems.count)
  property int updateIndex: 0
  onFilterChanged: Qt.callLater(update)
  groups: [
    Models.DelegateModelGroup {
      id: allItems
      name: "all"
      includeByDefault: true
      onChanged: (removed, inserted) => {
        print(`count: ${JSON.stringify(count)}`);
        print(`removed: ${JSON.stringify([...removed])}`);
        print(`inserted:  ${JSON.stringify([...inserted])}`);
      }
    },
    Models.DelegateModelGroup {
      id: visibleItems
      name: "visible"
    }
  ]
  filterOnGroup: "visible"

  function update(startIndex) {
    startIndex = startIndex ?? 0;
    if (startIndex < 0) startIndex = 0;
    if (startIndex >= allItems.count) {
      updateIndex = allItems.count;
      return;
    }
    updateIndex = startIndex;
    if (updateIndex === 0) {
      allItems.setGroups(0, allItems.count, ["all"]);
    }
    for (; updateIndex < allItems.count; updateIndex++) {
      let visible = !filter || filter(allItems.get(updateIndex).model);
      if (!visible) continue;
      allItems.setGroups(updateIndex, 1, ["all", "visible"]);
    }
    if (updateIndex < allItems.count) Qt.callLater(update, updateIndex);
  }

  Component.onCompleted: Qt.callLater(update)
}
// End of code from <https://github.com/stephenquan/qt5-qml-toolkit> }}}
