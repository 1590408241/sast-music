import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import FluentUI
import sast_music
import "../component"

BlurRectangle {
    id: navigationBar
    readonly property color backgroundColor: Qt.rgba(209 / 255, 209 / 255,
                                                     214 / 255, 0.28)
    readonly property color activeColor: "#335eea"
    readonly property string homePageUrl: "qrc:///ui/page/Home.qml"
    readonly property string explorePageUrl: "qrc:///ui/page/Explore.qml"
    readonly property string libraryPageUrl: "qrc:///ui/page/Library.qml"
    property Item stackView
    property string topPageUrl
    height: 60
    blurRadius: 100
    target: stackView

    MouseArea {
        anchors.fill: parent
        onClicked: {
            forceActiveFocus()
        }
    }

    Row {
        spacing: 5
        anchors {
            left: parent.left
            leftMargin: 65
            verticalCenter: parent.verticalCenter
        }
        IconButton {
            id: btn_back
            width: 40
            height: 40
            hoverColor: backgroundColor
            iconWidth: 22
            iconHeight: 22
            iconUrl: "qrc:///res/img/arrow-left.svg"
            onClicked: stackView.popPage()
        }
        IconButton {
            id: btn_redo
            width: 40
            height: 40
            hoverColor: backgroundColor
            iconWidth: 22
            iconHeight: 22
            iconUrl: "qrc:///res/img/arrow-right.svg"
            onClicked: stackView.redoPage()
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 30

        TextButton {
            id: btn_home
            text: "HOME"
            textColor: topPageUrl === homePageUrl ? activeColor : "#000"
            onClicked: stackView.pushPage(homePageUrl)
        }

        TextButton {
            id: btn_explore
            text: "EXPLORE"
            textColor: topPageUrl === explorePageUrl ? activeColor : "#000"
            onClicked: stackView.pushPage(explorePageUrl)
        }

        TextButton {
            id: btn_library
            text: "LIBRARY"
            textColor: topPageUrl === libraryPageUrl ? activeColor : "#000"
            onClicked: UserProfileViewModel.isLogin ? stackView.pushPage(
                                                          libraryPageUrl) : stackView.pushPage(
                                                          "qrc:///ui/page/Login.qml")
        }
    }

    SearchBox {
        anchors {
            right: avatar.left
            rightMargin: 15
            verticalCenter: parent.verticalCenter
        }
        onCommit: content => {// TODO: post search request
                  }
    }

    FluClip {
        id: avatar
        anchors {
            right: parent.right
            rightMargin: 65
            verticalCenter: parent.verticalCenter
        }
        width: 30
        height: 30
        radius: [15, 15, 15, 15]
        Image {
            anchors.fill: parent
            source: UserProfileViewModel.avatarUrl
            fillMode: Image.PreserveAspectFit
            cache: true
        }

        Rectangle {
            anchors.fill: parent
            color: item_mouse.containsMouse ? Qt.rgba(46 / 255,
                                                      46 / 255, 41 / 255,
                                                      0.28) : "transparent"
        }

        MouseArea {
            id: item_mouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                menu.popup()
            }
        }
    }

    RadiusMenu {
        id: menu
        radius: 15
        RadiusMenuItem {
            iconSize: 20
            iconUrl: "qrc:///res/img/settings.svg"
            text: "Settings"
            font.family: "MiSans"
            font.bold: true
            onClicked: {
                stackView.pushPage("qrc:///ui/page/Settings.qml")
            }
        }
        RadiusMenuItem {
            iconSize: 20
            iconUrl: UserProfileViewModel.isLogin ? "qrc:///res/img/logout.svg" : "qrc:///res/img/login.svg"
            text: UserProfileViewModel.isLogin ? "Logout" : "Login"
            font.family: "MiSans"
            font.bold: true
            onClicked: {
                if (!UserProfileViewModel.isLogin) {
                    stackView.pushPage("qrc:///ui/page/Login.qml")
                    return
                }
                logout_dialog.open()
            }
        }
        MenuSeparator {}
        RadiusMenuItem {
            iconSize: 20
            iconUrl: "qrc:///res/img/github.svg"
            text: "GitHub Repo"
            font.family: "MiSans"
            font.bold: true
            onClicked: {
                Qt.openUrlExternally(
                            "https://github.com/NJUPT-SAST-Cpp/sast-music")
            }
        }
    }

    FluContentDialog {
        id: logout_dialog
        title: "Confirm logout?"
        positiveText: "Ok"
        negativeText: "Cancel"
        onPositiveClicked: {
            LoginViewModel.logout()
        }
    }

    Connections {
        target: LoginViewModel
        function onLogoutSuccess() {
            UserProfileViewModel.isLogin = false
            UserProfileViewModel.loadUserProfile()
            showSuccess("Logout success")
        }
    }

    Connections {
        target: LoginViewModel
        function onLogoutFailed(message) {
            showError(message)
        }
    }

}
