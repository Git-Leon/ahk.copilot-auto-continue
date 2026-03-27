#Requires AutoHotkey v2.0
#SingleInstance Force
#Include utils.ahk

SendMode("Event")
SetKeyDelay(50, 50)
enabled := false
counter := 0

PasteContinue()
{
    oldClipboard := ClipboardAll()
    A_Clipboard := "Continue"
    ClipWait(1)

    Log("CONTINUE: Clipboard set to Continue")

    LogSendEventSleep("CONTINUE: Ctrl+A", "^{a}", 150)
    LogSendEventSleep("CONTINUE: Ctrl+V", "^{v}", 150)

    A_Clipboard := oldClipboard
    Log("CONTINUE: Clipboard restored")
}

AllowCopilotCommand()
{
    ; PasteContinue()
    ; Use wrapper helpers that log, send and sleep
    LogSendEventSleep("ALLOW: Attempt 1 - SendEvent ^{Enter}", "^{Enter}", 300)
    LogSendInputSleep("ALLOW: Attempt 2 - SendInput ^{Enter}", "^{Enter}", 300)
    LogSendPlaySleep("ALLOW: Attempt 3 - SendPlay ^{Enter}", "^{Enter}", 300)

    Log("ALLOW: Attempt 4 - Explicit Ctrl down/up")
    LogSendEventSleep("ALLOW: Ctrl down", "{Ctrl down}", 100)
    LogSendEventSleep("ALLOW: Enter (with Ctrl down)", "{Enter}", 100)
    LogSendEventSleep("ALLOW: Ctrl up", "{Ctrl up}", 300)
}

^!g::
{
    global enabled
    enabled := !enabled

    if enabled {
        SetTimer(MainLoop, 10000)
        Log("ENABLED")
        TrayTip("Copilot Auto", "Enabled", 2)
    } else {
        SetTimer(MainLoop, 0)
        Log("DISABLED")
        TrayTip("Copilot Auto", "Disabled", 2)
    }
}

MainLoop()
{
    global counter

    if !WinActive("ahk_exe Code.exe") {
        Log("SKIP - VS Code not active")
        return
    }

    counter += 10
    activeWindow := WinGetTitle("A")
    Log("TICK - counter=" counter " - activeWindow=" activeWindow)

    ; Every 90 seconds → Continue flow
    if (counter >= 90) {
        counter := 0

        Log("CONTINUE FLOW START")
        PasteContinue()
        Log("Pasted: Continue")

        Sleep(10000)

        AllowCopilotCommand()
        Log("ALLOW triggered after Continue")

        return
    }

    ; Regular interval → allow attempt
    AllowCopilotCommand()
}


; Set up logging (defines `logDir` and `logFile`)
InitLog()
Log("SCRIPT STARTED")