import Qt.labs.platform 1.1 as LabsPlatform
import Qt.labs.qmlmodels 1.1 as LabsModels
import QtQml
import QtQml.Models 2.14 as Models
import QtQuick 2.15 as Quick
import QtQuick.Controls 2.15 as QuickControls
import org.kde.kirigami 2.20 as Kirigami

LabsPlatform.MenuBar {
  id: menuBarRoot

  property alias model: delegateModel.model
  FilterDelegateModel {
    id: delegateModel
    delegate: menuComponent
  }

  // Component {
  //   id: dispatchComponent
  //   Quick.Loader {
  //     required property var modelData
  //     sourceComponent: switch (modelData.menuRole) {
  //       case "menu": return menuComponent;
  //       case "menuItem": return menuItemComponent;
  //     }
  //   }
  // }

  Component {
    id: menuComponent
    LabsPlatform.Menu {
      id: menuRoot

      property string menuRole: "menu"
      required property var modelData

      enabled: modelData.enabled
      font: modelData.font
      icon.name: modelData.icon.name
      icon.source: modelData.icon.source
      title: modelData.title

      // Models.Instantiator {
      //   model: modelData.contentModel
      //   delegate: dispatchComponent
      //   onObjectAdded: (index, object) => {
      //     switch (object.menuRole) {
      //       case "menu": return menuRoot.insertMenu(index, object);
      //       case "menuItem": return menuRoot.insertItem(index, object);
      //     }
      //   }
      //   onObjectRemoved: (index, object) => {
      //     switch (object.menuRole) {
      //       case "menu": return menuRoot.removeMenu(object);
      //       case "menuItem": return menuRoot.removeItem(object);
      //     }
      //   }
      // }
    }
  }

  // Component {
  //   id: menuItemComponent
  //   LabsPlatform.MenuItem {
  //     id: menuItemRoot

  //     property string menuRole: "menuItem"
  //     required property var modelData

  //     enabled: modelData.enabled
  //     text: modelData.text
  //   }
  // }

  LabsPlatform.Menu {
    title: "Test menu"
    LabsPlatform.MenuItem {
      text: "Test item"
    }
  }

  Models.Instantiator {
    id: instantiator
    model: delegateModel
    onObjectAdded: (index, object) => menuBarRoot.insertMenu(index, object)
    onObjectRemoved: (index, object) => menuBarRoot.removeMenu(object)
  }
}
