import Qt.labs.platform 1.1 as LabsPlatform
import QtQml.Models 2.14 as Models

LabsPlatform.MenuBar {
  id: root

  property alias delegate: instantiator.delegate
  property alias model: instantiator.model

  Models.Instantiator {
    id: instantiator
    onObjectAdded: (index, object) => root.insertMenu(index, object)
    onObjectRemoved: (object) => root.removeMenu(object)
  }
}
