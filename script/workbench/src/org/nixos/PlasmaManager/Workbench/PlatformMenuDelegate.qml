import Qt.labs.platform 1.1 as LabsPlatform
import Qt.labs.qmlmodels 1.1 as LabsModels
import QtQml
import QtQml.Models 2.14 as Models
import QtQuick 2.15 as Quick
import QtQuick.Controls 2.15 as QuickControls

LabsPlatform.Menu {
  id: root
  property string menuRole: "menu"

  required property var menuModel

  enabled: menuModel.enabled
  font: menuModel.font
  icon.name: menuModel.icon.name
  icon.source: menuModel.icon.source
  title: menuModel.title
  visible: menuModel.visible

  Models.Instantiator {
    id: instantiator
    delegate: LabsModels.DelegateChooser {
      role: "menuRole"
      LabsModels.DelegateChoice {
        roleValue: "menu"
        delegate: Quick.Loader {
          source: Qt.resolvedUrl("PlatformMenuDelegate.qml")
          property var menuModel: modelData
        }
      }
      LabsModels.DelegateChoice {
        roleValue: "menuItem"
        delegate: LabsPlatform.MenuItem {
          property string menuRole: "menuItem"
          text: modelData.text
        }
      }
    }
    model: menuModel.contentModel
    onObjectAdded: (index, object) => object.menuRole === "menu" ? root.insertMenu(index, object) : root.insertItem(index, object)
    onObjectRemoved: (object) => object.menuRole === "menu" ? root.removeMenu(object) : root.removeItem(object)
  }
}
