#!/usr/bin/env nix-shell
/*
#! nix-shell -i qml
#! nix-shell -p kdePackages.kirigami kdePackages.qtdeclarative
*/

import QtQml
import QtQuick 2.15 as Quick
import QtQuick.Controls 2.15 as QuickControls
import org.kde.kirigami 2.20 as Kirigami
 
Kirigami.ApplicationWindow {
  id: root

  width: 500
  height: 400

  menuBar: QuickControls.MenuBar {
    property string menuRole: "menuBar"
    id: menuBar
    // visible: !Kirigami.Settings.hasPlatformMenuBar
  
    QuickControls.Menu {
      title: "Level 0"
      property string menuRole: "menu"

      QuickControls.Menu {
        title: "Level 1"
        property string menuRole: "menu"
  
        Kirigami.Action {
          property string menuRole: "menuItem"
          text: "Level 2"
          onTriggered: print("Level 2 action triggered")
        }
      }
    }
    QuickControls.Menu {
      title: "Mutations"
      property string menuRole: "menu"

      Kirigami.Action {
        property string menuRole: "menuItem"
        text: "Add menu"
        onTriggered: {
          const newMenu = menuBar.insertMenu(menuBar.menus.length, Qt.createQmlObject(`
            import QtQml
            import QtQuick 2.15 as Quick
            import QtQuick.Controls 2.15 as QuickControls
            import org.kde.kirigami 2.20 as Kirigami

            QuickControls.Menu {
              id: menuRoot
              required property var parentMenu
              title: "Insertion ${menuBar.menus.length}"

              Kirigami.Action {
                text: "Remove menu"
                onTriggered: parentMenu.removeMenu(menuRoot)
              }
            }
          `, this));
          newMenu.parentMenu = menuBar;
          return newMenu;
        }
      }
    }
    QuickControls.Menu {
      title: "Cyclers"
      property string menuRole: "menu"

      QuickControls.Menu {
        property string menuRole: "menu"
        title: "Cycler A"
      }
      QuickControls.Menu {
        property string menuRole: "menu"
        title: "Cycler B"
      }
      QuickControls.Menu {
        property string menuRole: "menu"
        title: "Cycler C"
      }
    }
    QuickControls.Menu {
      property string menuRole: "menu"
      title: qsTr("&Help")
  
      Kirigami.Action {
        property string menuRole: "menuItem"
        text: qsTr("&About")
        onTriggered: print("About Kirigami.Action triggered")
      }
    }
  }

  Quick.Loader {
    id: platformMenuBar
    active: Kirigami.Settings.hasPlatformMenuBar
    source: Qt.resolvedUrl("PlatformMenuBar.qml")
  }

  Binding {
    target: platformMenuBar.item
    property: "model"
    value: menuBar.contentChildren
  }

  globalDrawer: Kirigami.GlobalDrawer {
    actions: [
      Kirigami.Action {
        text: "View"
        icon.name: "view-list-icons"
        Kirigami.Action {
          text: "action 1"
        }
        Kirigami.Action {
          text: "action 2"
        }
        Kirigami.Action {
          text: "action 3"
        }
      },
      Kirigami.Action {
        text: "action 3"
      },
      Kirigami.Action {
        text: "action 4"
      }
    ]
  }
  contextDrawer: Kirigami.ContextDrawer {
    id: contextDrawer
  }
  pageStack.initialPage: mainPageComponent
  Quick.Component {
    id: mainPageComponent
    Kirigami.ScrollablePage {
      id: page
      title: "Hello"
      actions: [
        Kirigami.Action {
          icon.name: sheet.visible ? "dialog-cancel" : "document-edit"
          text: sheet.visible ? "Show Sheet" : "Hide Sheet"
          onTriggered: {
            print("Action button in buttons page triggered");
            sheet.visible = !sheet.visible
          }
        },
        Kirigami.Action {
          icon.name: "go-previous"
          text: "Left action"
          onTriggered: {
            print("Left action triggered")
          }
        },
        Kirigami.Action {
          icon.name: "go-next"
          text: "Right action"
          onTriggered: {
            print("Right action triggered")
          }
        },
        Kirigami.Action {
          text: "Action for buttons"
          icon.name: "bookmarks"
          onTriggered: print("Action 1 triggered")
        },
        Kirigami.Action {
          text: "Action 2"
          icon.name: "folder"
          enabled: false
        },
        Kirigami.Action {
          text: "Action for Sheet"
          visible: sheet.visible
        }
      ]
      Kirigami.OverlaySheet {
        id: sheet
        QuickControls.Label {
          wrapMode: Quick.Text.WordWrap
          text: "Lorem ipsum dolor sit amet"
        }
      }
      // Page contents...
      Quick.Rectangle {
        anchors.fill: parent
        color: "lightblue"
      }
    }
  }
}
