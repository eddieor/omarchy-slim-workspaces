import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "eddieor.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }
    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }
    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  implicitWidth: row.implicitWidth + Style.space(8)
  implicitHeight: barSize

  Row {
    id: row
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: Style.space(4)
    spacing: Style.space(7)

    Repeater {
      model: root.workspaceIds()

      Item {
        id: dot
        required property int modelData
        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        width: focused ? Style.space(14) : Style.space(6)
        height: Style.space(6)

        Rectangle {
          anchors.centerIn: parent
          width: parent.width
          height: parent.height
          radius: height / 2
          color: root.bar ? root.bar.barForeground : Color.foreground
          opacity: focused ? 1 : (occupied ? 0.55 : 0.22)

          Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
          Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        }

        MouseArea {
          anchors.fill: parent
          anchors.margins: -4
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.focusWorkspace(dot.modelData)
          onEntered: if (root.bar) root.bar.showTooltip(dot, "Workspace " + dot.modelData)
          onExited: if (root.bar) root.bar.hideTooltip(dot)
        }
      }
    }
  }
}
