// Tema SDDM "windows-classic": a tela de logon clássica do Windows XP
// (diálogo "Fazer logon no Windows" do msgina.dll, diálogo 1500).
//
// Medidas: o diálogo original é definido em DLUs com MS Shell Dlg 8 (Tahoma),
// em que 1 DLU = 1,5 px na horizontal e 1,625 px na vertical. As posições
// abaixo são essas DLUs convertidas e arredondadas (veja o README).

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQml.Models 2.15
import "."

Rectangle {
    id: root
    width: 1024
    height: 768
    color: cfg("color", "#3A6EA5")

    // ---------------------------------------------------------------- config
    function cfg(key, fallback) {
        var v = (typeof config !== "undefined" && config) ? config[key] : undefined
        return (v === undefined || v === null || v === "") ? fallback : String(v)
    }

    // ---------------------------------------------------------------- textos
    readonly property bool pt: Qt.locale().name.indexOf("pt") === 0
    readonly property var tr: pt ? {
        "logonTitle": "Fazer logon no Windows",
        "user": "&Nome de usuário:",
        "password": "&Senha:",
        "session": "Fa&zer logon em:",
        "ok": "OK",
        "cancel": "Cancelar",
        "shutdown": "&Desligar...",
        "optionsMore": "Opções >>",
        "optionsLess": "Opções <<",
        "shutdownTitle": "Desligar o Windows",
        "shutdownQuestion": "&O que você deseja que o computador faça?",
        "powerOff": "Desligar",
        "powerOffDesc": "Desliga o Windows para que você possa desligar o computador com segurança.",
        "reboot": "Reiniciar",
        "rebootDesc": "Desliga o Windows e o inicia novamente.",
        "suspend": "Em espera",
        "suspendDesc": "Mantém o computador ligado com baixo consumo de energia, com os dados na memória. O computador volta quando você toca no mouse ou no teclado.",
        "hibernate": "Hibernar",
        "hibernateDesc": "Salva o conteúdo da memória no disco e desliga o computador. Quando você ligá-lo, o Windows volta ao estado anterior.",
        "messageTitle": "Mensagem de logon",
        "loginFailed": "O sistema não pôde fazer o seu logon. Verifique se o nome de usuário está correto e digite a senha novamente. As letras da senha devem ser digitadas com as maiúsculas e minúsculas corretas.",
        "capsTitle": "Caps Lock ativado",
        "capsMessage": "Com o Caps Lock ativado, você pode digitar a senha incorretamente.\n\nPressione Caps Lock para desativá-lo antes de digitar a senha."
    } : {
        "logonTitle": "Log On to Windows",
        "user": "&User name:",
        "password": "&Password:",
        "session": "&Log on to:",
        "ok": "OK",
        "cancel": "Cancel",
        "shutdown": "&Shut Down...",
        "optionsMore": "Options >>",
        "optionsLess": "Options <<",
        "shutdownTitle": "Shut Down Windows",
        "shutdownQuestion": "&What do you want the computer to do?",
        "powerOff": "Shut down",
        "powerOffDesc": "Shuts down Windows so that you can safely turn off power.",
        "reboot": "Restart",
        "rebootDesc": "Shuts down Windows and then starts Windows again.",
        "suspend": "Stand by",
        "suspendDesc": "Keeps the computer running on low power with data still in memory. The computer wakes up when you touch the mouse or keyboard.",
        "hibernate": "Hibernate",
        "hibernateDesc": "Saves the contents of memory to disk and turns off the computer. When you turn on the computer, Windows restores its previous state.",
        "messageTitle": "Logon Message",
        "loginFailed": "The system could not log you on. Make sure your User name is correct, then type your password again. Letters in passwords must be typed using the correct case.",
        "capsTitle": "Caps Lock is On",
        "capsMessage": "Having Caps Lock on may cause you to enter your password incorrectly.\n\nYou should press Caps Lock to turn it off before entering your password."
    }

    // ---------------------------------------------------------------- estado
    property string dialog: "logon"     // "logon", "shutdown" ou "message"
    property bool busy: false           // logon em andamento
    property bool expanded: false       // "Opções >>"
    property bool capsDismissed: false

    // Os campos começam em 56 DLU (84 px), ou depois do rótulo mais largo
    // (as traduções têm rótulos maiores que o inglês). A borda direita fica
    // em 218 DLU (327 px).
    readonly property int fieldX: Math.max(84, 9 + 6 + Math.max(userLabel.implicitWidth,
        passwordLabel.implicitWidth, sessionLabel.implicitWidth))
    readonly property int fieldWidth: 327 - fieldX

    readonly property rect primaryGeometry: screenModel.geometry(screenModel.primary)

    // Nomes das sessões (o ComboBox usa uma lista de textos)
    property var sessionNames: []
    Instantiator {
        model: sessionModel
        delegate: QtObject { property string sessionName: model.name }
        onObjectAdded: function (index, object) {
            var a = root.sessionNames.slice()
            a.splice(index, 0, object.sessionName)
            root.sessionNames = a
        }
        onObjectRemoved: function (index, object) {
            var a = root.sessionNames.slice()
            a.splice(index, 1)
            root.sessionNames = a
        }
    }

    // Ações do "Desligar o Windows" disponíveis nesta máquina
    readonly property var shutdownActions: {
        var a = [
            { "name": tr.powerOff, "desc": tr.powerOffDesc, "run": function () { sddm.powerOff() } },
            { "name": tr.reboot, "desc": tr.rebootDesc, "run": function () { sddm.reboot() } }
        ]
        if (sddm.canSuspend)
            a.push({ "name": tr.suspend, "desc": tr.suspendDesc, "run": function () { sddm.suspend() } })
        if (sddm.canHibernate)
            a.push({ "name": tr.hibernate, "desc": tr.hibernateDesc, "run": function () { sddm.hibernate() } })
        return a
    }

    function login() {
        if (busy || dialog !== "logon")
            return
        busy = true
        sddm.login(userEdit.text, passwordEdit.text, sessionCombo.currentIndex)
    }

    function cancel() {
        passwordEdit.text = ""
        userEdit.forceActiveFocus()
    }

    function showShutdown() {
        shutdownCombo.currentIndex = 0
        dialog = "shutdown"
        shutdownCombo.forceActiveFocus()
    }

    function closeDialog() {
        dialog = "logon"
        if (userEdit.text === "")
            userEdit.forceActiveFocus()
        else
            passwordEdit.forceActiveFocus()
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false
            passwordEdit.text = ""
            root.dialog = "message"
            messageOk.forceActiveFocus()
        }
    }

    Connections {
        target: keyboard
        function onCapsLockChanged() { root.capsDismissed = false }
    }

    // ---------------------------------------------------------------- fundo
    // Cor sólida (padrão: #3A6EA5, a cor de fundo do esquema Clássico) ou uma
    // imagem em cada monitor.
    Repeater {
        model: screenModel
        Item {
            x: geometry.x
            y: geometry.y
            width: geometry.width
            height: geometry.height
            Image {
                anchors.fill: parent
                visible: source != ""
                source: root.cfg("background", "")
                asynchronous: true
                smooth: true
                fillMode: {
                    var m = root.cfg("backgroundMode", "stretch")
                    if (m === "tile") return Image.Tile
                    if (m === "center") return Image.Pad
                    if (m === "fill") return Image.PreserveAspectCrop
                    if (m === "fit") return Image.PreserveAspectFit
                    return Image.Stretch
                }
            }
        }
    }

    // ---------------------------------------------------- Fazer logon no Windows
    ClassicWindow {
        id: logon
        title: tr.logonTitle
        active: root.dialog === "logon"
        clientWidth: 411
        // Recolhido: só usuário e senha. Expandido: + "Fazer logon em" (sessão).
        clientHeight: root.expanded ? 229 : 201
        // Centralizado pela altura recolhida: "Opções >>" cresce para baixo.
        x: root.primaryGeometry.x + Math.round((root.primaryGeometry.width - width) / 2)
        y: root.primaryGeometry.y + Math.round((root.primaryGeometry.height - (201 + 25)) / 2)
        focus: true

        Keys.onReturnPressed: root.login()
        Keys.onEnterPressed: root.login()
        Keys.onEscapePressed: root.cancel()

        // Faixa "Windows XP Professional" (msgina.dll, bitmap 107)
        Image {
            x: 0; y: 0
            source: "images/banner.png"
            smooth: false
        }
        // Barra colorida (bitmap 103): corre durante o logon
        Item {
            x: 0; y: 88
            width: 411; height: 5
            clip: true
            Row {
                id: bar
                Image { source: "images/bar.png"; smooth: false }
                Image { source: "images/bar.png"; smooth: false }
                NumberAnimation on x {
                    from: -411; to: 0
                    duration: 1500
                    loops: Animation.Infinite
                    running: root.busy
                    onRunningChanged: if (!running) bar.x = 0
                }
            }
        }

        Label {
            id: userLabel
            label: tr.user
            x: 9
            anchors.verticalCenter: userEdit.verticalCenter
        }
        LineEdit {
            id: userEdit
            x: root.fieldX; y: 108; width: root.fieldWidth
            text: userModel.lastUser
            onAccepted: root.login()
        }

        Label {
            id: passwordLabel
            label: tr.password
            x: 9
            anchors.verticalCenter: passwordEdit.verticalCenter
        }
        LineEdit {
            id: passwordEdit
            x: root.fieldX; y: 136; width: root.fieldWidth
            echoMode: TextInput.Password
            onAccepted: root.login()
        }

        Label {
            id: sessionLabel
            label: tr.session
            visible: root.expanded
            x: 9
            anchors.verticalCenter: sessionCombo.verticalCenter
        }
        ComboBox {
            id: sessionCombo
            visible: root.expanded
            x: root.fieldX; y: 163; width: root.fieldWidth
            model: root.sessionNames
            currentIndex: sessionModel.lastIndex
        }

        // Botões: 55, 109, 163 e 217 DLU
        Item {
            y: root.expanded ? 195 : 167
            PushButton {
                id: okButton
                x: 83
                text: tr.ok
                isDefault: true
                onClicked: root.login()
            }
            PushButton {
                x: 164
                text: tr.cancel
                onClicked: root.cancel()
            }
            PushButton {
                id: shutdownButton
                x: 245
                text: tr.shutdown
                onClicked: root.showShutdown()
            }
            PushButton {
                x: 326
                text: root.expanded ? tr.optionsLess : tr.optionsMore
                onClicked: root.expanded = !root.expanded
            }
        }

        Balloon {
            z: 10
            x: passwordEdit.x + 16 - tipX
            y: passwordEdit.y + passwordEdit.height - 4
            visible: root.dialog === "logon" && passwordEdit.activeFocus &&
                     keyboard.capsLock && !root.capsDismissed
            icon: "images/warning.png"
            title: tr.capsTitle
            message: tr.capsMessage
            onDismissed: root.capsDismissed = true
        }
    }

    // Atalhos Alt+letra do diálogo de logon
    Shortcut {
        sequence: "Alt+" + Style.mnemonicKey(tr.user)
        enabled: root.dialog === "logon" && !root.busy
        onActivated: userEdit.forceActiveFocus()
    }
    Shortcut {
        sequence: "Alt+" + Style.mnemonicKey(tr.password)
        enabled: root.dialog === "logon" && !root.busy
        onActivated: passwordEdit.forceActiveFocus()
    }
    Shortcut {
        sequence: "Alt+" + Style.mnemonicKey(tr.session)
        enabled: root.dialog === "logon" && !root.busy && root.expanded
        onActivated: sessionCombo.forceActiveFocus()
    }
    Shortcut {
        sequence: "Alt+" + Style.mnemonicKey(tr.shutdown)
        enabled: root.dialog === "logon" && !root.busy
        onActivated: root.showShutdown()
    }

    // Enquanto há um diálogo por cima (ou o logon está em andamento), o
    // diálogo de logon não recebe cliques.
    MouseArea {
        anchors.fill: parent
        visible: root.dialog !== "logon" || root.busy
        z: 1
    }

    // ---------------------------------------------------- Desligar o Windows
    ClassicWindow {
        id: shutdownWindow
        z: 2
        visible: root.dialog === "shutdown"
        title: tr.shutdownTitle
        clientWidth: 411
        clientHeight: 228
        x: root.primaryGeometry.x + Math.round((root.primaryGeometry.width - width) / 2)
        y: root.primaryGeometry.y + Math.round((root.primaryGeometry.height - height) / 2)

        function accept() {
            var a = root.shutdownActions[shutdownCombo.currentIndex]
            root.closeDialog()
            if (a) a.run()
        }
        Keys.onReturnPressed: accept()
        Keys.onEnterPressed: accept()
        Keys.onEscapePressed: root.closeDialog()

        // Faixa pequena (bitmap 101) e a barra
        Image { x: 0; y: 0; source: "images/banner-small.png"; smooth: false }
        Image { x: 0; y: 72; source: "images/bar.png"; smooth: false }

        Image {
            x: 20; y: 88
            source: "images/shutdown.png"
            smooth: false
        }
        Label {
            label: tr.shutdownQuestion
            x: 66; y: 89
        }
        ComboBox {
            id: shutdownCombo
            x: 66; y: 110; width: 260
            model: root.shutdownActions.map(function (a) { return a.name })
        }
        Label {
            x: 66; y: 142; width: 260; height: 44
            label: {
                var a = root.shutdownActions[shutdownCombo.currentIndex]
                return a ? a.desc.replace(/&/g, "&&") : ""
            }
            wrapMode: Text.WordWrap
        }
        PushButton {
            x: 245; y: 194
            text: tr.ok
            isDefault: true
            onClicked: shutdownWindow.accept()
        }
        PushButton {
            x: 326; y: 194
            text: tr.cancel
            onClicked: root.closeDialog()
        }
    }
    Shortcut {
        sequence: "Alt+" + Style.mnemonicKey(tr.shutdownQuestion)
        enabled: root.dialog === "shutdown"
        onActivated: shutdownCombo.forceActiveFocus()
    }

    // ---------------------------------------------------- Mensagem de logon
    ClassicWindow {
        id: messageWindow
        z: 2
        visible: root.dialog === "message"
        title: tr.messageTitle
        clientWidth: 402
        clientHeight: messageOk.y + messageOk.height + 11
        x: root.primaryGeometry.x + Math.round((root.primaryGeometry.width - width) / 2)
        y: root.primaryGeometry.y + Math.round((root.primaryGeometry.height - height) / 2)

        Keys.onEscapePressed: root.closeDialog()

        Image {
            id: messageIcon
            x: 11; y: 11
            source: "images/information.png"
            smooth: false
        }
        Label {
            id: messageText
            x: 44; y: 11; width: 321
            label: tr.loginFailed
            wrapMode: Text.WordWrap
        }
        PushButton {
            id: messageOk
            x: Math.round((402 - width) / 2)
            y: Math.max(messageText.y + messageText.height, messageIcon.y + messageIcon.height) + 16
            text: tr.ok
            isDefault: true
            onClicked: root.closeDialog()
        }
    }

    Component.onCompleted: {
        if (userEdit.text === "")
            userEdit.forceActiveFocus()
        else
            passwordEdit.forceActiveFocus()
    }
}
