import Qt.labs.platform as LabsPlatform
import QtQml.Models 2.14 as Models

LabsPlatform.Menu {
  id: root
  readonly property string menuRole: "menu"

  property alias delegate: instantiator.delegate
  property alias model: instantiator.model

  Models.Instantiator {
    id: instantiator
    onObjectAdded: (index, object) => object.menuRole === "menu" ? root.insertMenu(index, object) : root.insertItem(index, object)
    onObjectRemoved: (object) => object.menuRole === "menu" ? root.removeMenu(object) : root.removeItem(object)
  }
}
