import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Shapes 1.15
import "./StyleComponent"

Window {
    id: root
    property bool enableBorderShadow: true
    property bool darkMode: false // system_palette.window.hslLightness < 0.5
    property int safeAreaOrigin: Item.TopLeft // Item.TopLeft | Item.TopRight
    property Item safeAreaRect: Item {
        x: 0
        y: 0
        width: 0
        height: 0
    }
    property string backgroundColor: "#ffffff"
    // property Item toolBarButton: mac_system_button

    // Qt.platform.os === 'windows' || Qt.platform.os==="winrt"
    // 除了mac，其他都按照win的方式渲染
    property string systemType: Qt.platform.os === 'osx' ? "mac" : "win"

   default property alias children: bg_container.children



    flags: Qt.WindowMinimizeButtonHint | Qt.WA_TranslucentBackground | Qt.FramelessWindowHint | (enableBorderShadow ? 0 : Qt.NoDropShadowWindowHint)
    color: "transparent"


    // SystemPalette {
    //     id: system_palette
    // }

    onVisibilityChanged: {
        // mac全平后，退出全屏背景色有问题，重置窗口背景色
        if (Qt.platform.os === 'osx') {
            if (root.visibility !== Window.FullScreen) {
                root.flags = 0
                root.flags = Qt.WindowMinimizeButtonHint | Qt.WA_TranslucentBackground | Qt.FramelessWindowHint | (enableBorderShadow ? 0 : Qt.NoDropShadowWindowHint)
            }
        }
    }


    MPaper {
        id: bg_container
        anchors.fill: parent
        radius: systemType == "mac" ? (root.visibility !== Window.FullScreen ? 10 : 0) : (root.visibility !== Window.Maximized ? 6 : 0)
        elevation: 0

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: bg_container.width
                height: bg_container.height
                radius: bg_container.radius
            }
        }

        color: root.backgroundColor

        // 窗口拖动区域
        MouseArea {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 40

            onPressed: {
                startSystemMove()
            }
        }

        // win下的系统按钮
        MFramelessWindowButtonsWin {
            visible: systemType !== "mac"
            darkMode: root.darkMode
            target: root
        }

        // mac下的系统按钮
        MFramelessWindowButtonsMac {
            visible: systemType === "mac" && root.visibility !== Window.FullScreen
            darkMode: root.darkMode
            target: root
        }

        // 窗口调整大小区域
        MWindowResizeHandler {
            anchors.fill: parent
            target: root
        }
    }
}

