import QtQuick

// A ring gauge. The arc animates to its new value rather than jumping, which
// is the difference between a dashboard that feels alive and one that flickers.
Item {
    id: root

    property real value: 0          // 0..1
    property color tint: Theme.ac
    property string label: ""
    property string caption: ""
    property int thickness: 5

    // The canvas repaints from this, and this is what gets animated -- so the
    // easing curve drives the drawing, not a timer.
    property real shown: 0
    Behavior on shown { NumberAnimation { duration: Theme.slow; easing.type: Theme.easing } }
    onValueChanged: shown = value
    Component.onCompleted: shown = value
    onShownChanged: arc.requestPaint()
    onTintChanged: arc.requestPaint()

    Canvas {
        id: arc
        anchors.fill: parent
        antialiasing: true
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const cx = width / 2, cy = height / 2;
            const r = Math.min(width, height) / 2 - root.thickness / 2 - 1;
            const start = -Math.PI * 0.75, sweep = Math.PI * 1.5;

            ctx.lineCap = "round";
            ctx.lineWidth = root.thickness;

            ctx.beginPath();
            ctx.arc(cx, cy, r, start, start + sweep);
            ctx.strokeStyle = Theme.line;
            ctx.stroke();

            if (root.shown > 0.001) {
                ctx.beginPath();
                ctx.arc(cx, cy, r, start, start + sweep * root.shown);
                ctx.strokeStyle = root.tint;
                ctx.stroke();
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 0
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.caption !== ""
            text: root.caption
            color: Theme.faint
            font.family: Theme.font
            font.pixelSize: 10
            font.letterSpacing: 0.6
        }
    }
}
