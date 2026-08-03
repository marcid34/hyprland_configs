import QtQuick

// A rolling line graph, drawn on a canvas from a fixed-length ring of samples.
//
// This is the "can it actually render things" answer: no image, no chart
// library, no external process -- a few dozen lines of QML repainting a
// gradient-filled path in step with live data.
Item {
    id: root

    property int points: 48
    property color stroke: Theme.ac
    property real maxValue: 100
    property var samples: []

    // push(v) keeps the ring at `points` long so the graph scrolls left.
    function push(v) {
        const s = samples.slice();
        s.push(Math.max(0, Math.min(maxValue, v)));
        while (s.length > points) s.shift();
        samples = s;
        canvas.requestPaint();
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const n = root.samples.length;
            if (n < 2) return;

            const w = width, h = height;
            const stepX = w / (root.points - 1);
            const y = (v) => h - (v / root.maxValue) * (h - 2) - 1;
            // Right-align the ring so a partially filled graph grows from the
            // right edge instead of stretching to fit.
            const x0 = w - (n - 1) * stepX;

            ctx.beginPath();
            ctx.moveTo(x0, y(root.samples[0]));
            for (let i = 1; i < n; i++) {
                const px = x0 + i * stepX, py = y(root.samples[i]);
                const cx = x0 + (i - 0.5) * stepX;
                ctx.bezierCurveTo(cx, y(root.samples[i - 1]), cx, py, px, py);
            }

            // Fill under the curve first, then stroke over it, so the line
            // stays crisp against its own gradient.
            ctx.lineTo(x0 + (n - 1) * stepX, h);
            ctx.lineTo(x0, h);
            ctx.closePath();
            const grad = ctx.createLinearGradient(0, 0, 0, h);
            grad.addColorStop(0, Qt.alpha(root.stroke, 0.34));
            grad.addColorStop(1, Qt.alpha(root.stroke, 0.0));
            ctx.fillStyle = grad;
            ctx.fill();

            ctx.beginPath();
            ctx.moveTo(x0, y(root.samples[0]));
            for (let i = 1; i < n; i++) {
                const px = x0 + i * stepX, py = y(root.samples[i]);
                const cx = x0 + (i - 0.5) * stepX;
                ctx.bezierCurveTo(cx, y(root.samples[i - 1]), cx, py, px, py);
            }
            ctx.strokeStyle = root.stroke;
            ctx.lineWidth = 1.6;
            ctx.lineJoin = "round";
            ctx.stroke();
        }
    }
}
