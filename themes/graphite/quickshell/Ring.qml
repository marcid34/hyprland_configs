import QtQuick

// A circular meter, drawn on a Canvas.
//
// Animating `value` directly would step the canvas in whatever increments the
// sampler happens to produce, which looks like stuttering rather than change.
// So the arc reads `shown`, and `shown` is what gets the Behavior — the
// repaint is then always smooth regardless of how coarsely the source ticks.
Item {
    id: ring

    property real value: 0        // 0..1, set by the sampler
    property color tint: Theme.accent
    property string label: ""
    property string caption: ""

    implicitWidth: 78
    implicitHeight: 78

    property real shown: 0
    onValueChanged: shown = value
    Behavior on shown {
        NumberAnimation { duration: Theme.slow; easing.type: Theme.enter }
    }
    onShownChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            const ctx = getContext("2d");
            const w = width, h = height;
            const cx = w / 2, cy = h / 2;
            const r = Math.min(w, h) / 2 - 5;
            ctx.reset();

            ctx.lineWidth = 5;
            ctx.lineCap = "round";

            ctx.beginPath();
            ctx.arc(cx, cy, r, 0, Math.PI * 2);
            ctx.strokeStyle = Theme.bg3;
            ctx.stroke();

            if (ring.shown > 0.001) {
                ctx.beginPath();
                // Start at 12 o'clock, sweep clockwise.
                ctx.arc(cx, cy, r, -Math.PI / 2,
                        -Math.PI / 2 + Math.PI * 2 * Math.min(1, ring.shown));
                ctx.strokeStyle = ring.tint;
                ctx.stroke();
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: ring.label
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: ring.caption
            color: Theme.faint
            font.family: Theme.font
            font.pixelSize: 9
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 0.8
        }
    }
}
