import QtQuick

// A surface. Hairline border, soft fill, one radius -- every panel in the
// shell is one of these so nothing drifts out of alignment with anything else.
Rectangle {
    property bool interactive: false
    property bool hovered: false

    color: interactive && hovered ? Theme.surface2 : Theme.surface
    radius: Theme.radius
    border.width: 1
    border.color: Theme.line

    Behavior on color { ColorAnimation { duration: Theme.quick } }
}
