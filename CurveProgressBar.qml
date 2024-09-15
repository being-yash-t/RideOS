// CircularTachometerProgress.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Canvas {
    id: progressCanvas
    width: radius * 2 + strokeWidth
    height: radius * 2 + strokeWidth

    property alias primaryColor: primaryColorInput.color
    property alias secondaryColor: secondaryColorInput.color
    property real radius: 90
    property real strokeWidth: 20
    property real percentage: 0.0 // Value between 0 and 1 (0% to 100% progress)

    // Colors for the gradient
    Rectangle {
        id: primaryColorInput
        visible: false
        color: "green"
    }

    Rectangle {
        id: secondaryColorInput
        visible: false
        color: "yellow"
    }

    onPercentageChanged: requestPaint()
    onPrimaryColorChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height); // Clear previous drawings

        var centerX = width / 2;
        var centerY = height / 2;

        // Define the start angle from 8 o'clock (bottom-left)
        var startAngle = Math.PI * 0.8; // 8 o'clock position
        // Define the end angle based on percentage, covering from 8AM (1.25*PI) to 4PM (1.75*PI)
        var endAngle = startAngle + (percentage * (Math.PI * 1.4)); // Goes up to 4PM

        // Draw the background arc (full arc for tachometer background from start to end)
        ctx.beginPath();
        ctx.lineWidth = strokeWidth;
        ctx.strokeStyle = "lightgray"; // Gray background for the tachometer
        // Full arc for the entire track (always draw the entire arc, regardless of progress)
        ctx.arc(centerX, centerY, radius, startAngle, startAngle + (Math.PI * 1.4), false); // Background from 8 o'clock to 4 o'clock
        ctx.stroke();

        // Gradient for the progress bar from bottom to top
        var gradient = ctx.createLinearGradient(0, height, 0, 0);

        // Primary color should occupy the first 80% (bottom 80%)
        gradient.addColorStop(0, primaryColor);
        gradient.addColorStop(0.95, primaryColor);

        // Secondary color should start at 80% (top 20%)
        gradient.addColorStop(0.95, secondaryColor);
        gradient.addColorStop(1, secondaryColor);

        ctx.strokeStyle = gradient;

        // Draw the progress arc based on the percentage
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius, startAngle, endAngle, false);
        ctx.stroke();
    }
}
