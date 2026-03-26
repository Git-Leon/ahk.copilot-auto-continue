#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode("Event")
SetKeyDelay(50, 50)

enabled := false
counter := 0

logDir := A_ScriptDir "\..\..\target"
DirCreate(logDir)
logFile := logDir "\copilot-auto.log"

Log(msg)
{
    global logFile
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    FileAppend("[" timestamp "] " msg "`n", logFile, "UTF-8")
}

AllowCopilotCommand()
{
    Log("ALLOW: Attempt 1 - SendEvent ^{Enter}")
    SendEvent("^{Enter}")
    Sleep(300)

    Log("ALLOW: Attempt 2 - SendInput ^{Enter}")
    SendInput("^{Enter}")
    Sleep(300)

    Log("ALLOW: Attempt 3 - SendPlay ^{Enter}")
    SendPlay("^{Enter}")
    Sleep(300)

    Log("ALLOW: Attempt 4 - Explicit Ctrl down/up")
    SendEvent("{Ctrl down}")
    Sleep(100)
    SendEvent("{Enter}")
    Sleep(100)
    SendEvent("{Ctrl up}")
    Sleep(300)
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

    ; Every 300 seconds → Continue flow
    if (counter >= 300) {
        counter := 0

        Log("CONTINUE FLOW START")
        SendText("Continue")
        Log("Typed: Continue")

        Sleep(10000)

        AllowCopilotCommand()
        Log("ALLOW triggered after Continue")

        return
    }

    ; Regular interval → allow attempt
    AllowCopilotCommand()
}

; Manual test: Allow command
^!t::
{
    Log("MANUAL TEST - AllowCopilotCommand")
    AllowCopilotCommand()
}

; Manual test: Continue flow
^!y::
{
    Log("MANUAL TEST - Continue flow start")
    SendText("Continue")
    Sleep(10000)
    AllowCopilotCommand()
    Log("MANUAL TEST - Continue flow complete")
}

Log("SCRIPT STARTED")