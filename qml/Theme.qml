pragma Singleton
import QtQuick

QtObject {
    // Color scheme inspired by crystal/aura
    readonly property color bg: "#0e0e0e"
    readonly property color bgAlt: "#1a1a1a"
    readonly property color fg: "#e0e0e0"
    readonly property color fgAlt: "#9ca0b0"
    
    readonly property color accent: "#7aa2f7"
    readonly property color accentAlt: "#7dcfff"
    
    readonly property color red: "#f7768e"
    readonly property color orange: "#ff9e64"
    readonly property color yellow: "#e0af68"
    readonly property color green: "#9ece6a"
    readonly property color cyan: "#7dcfff"
    readonly property color blue: "#7aa2f7"
    readonly property color purple: "#bb9af7"
    readonly property color magenta: "#c678dd"
    
    readonly property color transparent: "#00000000"
    readonly property color shadow: "#aa000000"
    
    // Widget specific colors
    readonly property color workspaceActive: accent  // Blue (#7aa2f7) for active
    readonly property color workspaceInactive: "#555555"  // Darker gray for empty
    readonly property color workspaceOccupied: "#7a7a7a"  // Medium gray for occupied
    
    readonly property color volumeHigh: green
    readonly property color volumeMid: yellow
    readonly property color volumeLow: orange
    readonly property color volumeMuted: red
    
    readonly property color batteryHigh: green
    readonly property color batteryMid: yellow
    readonly property color batteryLow: orange
    readonly property color batteryCritical: red
    
    // Sizing
    readonly property int barHeight: 48
    readonly property int widgetHeight: 32
    readonly property int widgetSpacing: 8
    readonly property int borderRadius: 8
    readonly property int iconSize: 20
    readonly property int fontSize: 12
    readonly property int fontSizeSmall: 10
    
    // Fonts
    readonly property string fontFamily: "Inter"
    readonly property string fontFamilyMono: "JetBrainsMono Nerd Font"
}
