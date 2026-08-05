import QtQuick

// A drag-and-click slider.
//
// Two details make it feel like hardware rather than a form control:
//
//   The track grows from 6px to 10px on hover, so the target announces itself
//   before you commit to it.
//
//   The fill follows the pointer with no animation *while dragging* (any
//   easing there reads as the control lagging your hand), and animates only
//   when something else moves it — a volume key, another app. `pressed` is
//   what switches between the two.
Item {
    id: slider

    property real value: 0        // 0..1
    property color tint: Theme.accent
    property string icon: ""

    signal moved(real v)

    implicitHeight: 26
    implicitWidth: 200

    function setFromX(px) {
        const usable = track.width;
        if (usable <= 0) return;
        slider.moved(Math.max(0, Math.min(1, px / usable)));
    }

    Row {
        anchors.fill: parent
        spacing: 10

        Text {
            visible: slider.icon !== ""
            text: slider.icon
            color: slider.tint
            font.family: Theme.fontMono
            font.pixelSize: 14
            width: 18
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: parent.width - (slider.icon !== "" ? 28 : 0)
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: ma.containsMouse || ma.pressed ? 10 : 6
                radius: height / 2
                color: Theme.bg3

                Behavior on height {
                    NumberAnimation { duration: Theme.fast; easing.type: Theme.enter }
                }

                Rectangle {
                    height: parent.height
                    width: Math.max(parent.height, parent.width * Math.max(0, Math.min(1, slider.value)))
                    radius: height / 2
                    color: slider.tint

                    // No easing under the pointer; easing everywhere else.
                    Behavior on width {
                        enabled: !ma.pressed
                        NumberAnimation { duration: Theme.base; easing.type: Theme.enter }
                    }
                }
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                anchors.topMargin: -6
                anchors.bottomMargin: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressed: (m) => slider.setFromX(m.x)
                onPositionChanged: (m) => { if (pressed) slider.setFromX(m.x) }
            }
        }
    }
}
