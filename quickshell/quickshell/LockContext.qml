import Quickshell
import Quickshell.Services.Pam
import QtQuick

Scope {
    id: root

    signal unlocked()
    signal failed()

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    onCurrentTextChanged: showFailure = false

    function tryUnlock() {
        if (currentText.length === 0) return;
        if (unlockInProgress) return;
        unlockInProgress = true;
        pam.start();
    }

    PamContext {
        id: pam
        configDirectory: "pam"
        config: "password.conf"

        onPamMessage: {
            if (responseRequired) this.respond(root.currentText);
        }

        onCompleted: result => {
            root.unlockInProgress = false;
            root.currentText = "";
            if (result === PamResult.Success) {
                root.unlocked();
            } else {
                root.showFailure = true;
                root.failed();
            }
        }
    }
}
