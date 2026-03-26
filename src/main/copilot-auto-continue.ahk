#Requires AutoHotkey v2.0
#SingleInstance Force

enabled := false

^!g::
{
    global enabled
    enabled := !enabled

    if enabled {
        SetTimer(MainLoop, 10000)
        TrayTip("Copilot Auto", "Enabled", 2)
    } else {
        SetTimer(MainLoop, 0)
        TrayTip("Copilot Auto", "Disabled", 2)
    }
}

counter := 0

MainLoop()
{
    global counter

    if !WinActive("ahk_exe Code.exe")
        return

    counter += 10

    ; Every 300 seconds → Continue flow
    if (counter >= 300) {
        counter := 0

        SendText("Continue")
        Sleep(10000)
        Send("^`n")
        return
    }

    ; Otherwise → just Ctrl+Enter
    Send("^`n")
}