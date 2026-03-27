#Requires AutoHotkey v2.0
#SingleInstance Force
#Include utils.ahk

SendMode("Event")
SetKeyDelay(50, 50)

global enabled := false
global counter := 0
global timerRunning := false
global isCoolingDown := false
global nextRunAt := 0

; =========================
; Tunables
; =========================
global MIN_INTERVAL_MS := 20000        ; minimum delay between sends
global MAX_INTERVAL_MS := 45000        ; maximum delay between sends
global BURST_LIMIT := 8                ; max sends before long cooldown
global BURST_COOLDOWN_MIN_MS := 180000 ; 3 min
global BURST_COOLDOWN_MAX_MS := 420000 ; 7 min

global WINDOW_EXE := "ahk_exe Code.exe"

; =========================
; Helpers
; =========================
ScheduleNextRun(reason := "scheduled")
{
    global enabled, nextRunAt
    if !enabled {
        return
    }

    delay := RandomRange(MIN_INTERVAL_MS, MAX_INTERVAL_MS)
    nextRunAt := A_TickCount + delay
    Log("NEXT RUN: " delay " ms (" reason ")")
    SetTimer(MainLoop, -delay)
}

StartCooldown(minMs, maxMs, reason := "cooldown")
{
    global isCoolingDown, counter, nextRunAt
    cooldown := RandomRange(minMs, maxMs)
    isCoolingDown := true
    counter := 0
    nextRunAt := A_TickCount + cooldown
    Log("COOLDOWN START: " cooldown " ms (" reason ")")
    TrayTip("Copilot Auto", "Cooling down: " Round(cooldown / 1000) "s", 2)

    SetTimer(() => EndCooldown(reason), -cooldown)
}

EndCooldown(reason := "")
{
    global enabled, isCoolingDown
    isCoolingDown := false
    Log("COOLDOWN END" (reason != "" ? ": " reason : ""))
    if enabled {
        ScheduleNextRun("post-cooldown")
    }
}

PasteContinue()
{
    oldClipboard := ClipboardAll()
    A_Clipboard := "Continue"
    if !ClipWait(1) {
        Log("ERROR: ClipWait failed while setting clipboard to Continue")
    } else {
        Log("CONTINUE: Clipboard set to Continue")
    }

    LogSendEventSleep("CONTINUE: Ctrl+A", "^{a}", 150)
    LogSendEventSleep("CONTINUE: Ctrl+V", "^{v}", 150)

    A_Clipboard := oldClipboard
    Log("CONTINUE: Clipboard restored")
}

AllowCopilotCommand()
{
    PasteContinue()

    ; Try multiple send methods conservatively
    LogSendEventSleep("ALLOW: Attempt 1 - SendEvent ^{Enter}", "^{Enter}", 300)
    LogSendInputSleep("ALLOW: Attempt 2 - SendInput ^{Enter}", "^{Enter}", 300)
    LogSendPlaySleep("ALLOW: Attempt 3 - SendPlay ^{Enter}", "^{Enter}", 300)
    Log("ALLOW: Attempt 4 - Explicit Ctrl down/up")
    LogSendEventSleep("ALLOW: Ctrl down", "{Ctrl down}", 100)
    LogSendEventSleep("ALLOW: Enter (with Ctrl down)", "{Enter}", 100)
    LogSendEventSleep("ALLOW: Ctrl up", "{Ctrl up}", 300)
}

MainLoop()
{
    global enabled, counter, isCoolingDown, WINDOW_EXE, BURST_LIMIT

    if !enabled {
        Log("SKIP - disabled")
        return
    }

    if isCoolingDown {
        Log("SKIP - currently cooling down")
        return
    }

    if !WinActive(WINDOW_EXE) {
        Log("SKIP - VS Code not active")
        ScheduleNextRun("window-not-active")
        return
    }

    ; Safety: only operate if Copilot/chat area is likely focused by user beforehand.
    ; This script does not inspect response text. It only rate-limits behavior.
    AllowCopilotCommand()

    counter += 1
    Log("LOOP COUNT: " counter)

    if counter >= BURST_LIMIT {
        StartCooldown(BURST_COOLDOWN_MIN_MS, BURST_COOLDOWN_MAX_MS, "burst-limit-reached")
        return
    }

    ScheduleNextRun("normal")
}

ShowStatus()
{
    global enabled, counter, isCoolingDown, nextRunAt

    status := "Enabled: " (enabled ? "Yes" : "No")
        . "`nCooling down: " (isCoolingDown ? "Yes" : "No")
        . "`nBurst count: " counter

    if nextRunAt > 0 {
        remainingMs := nextRunAt - A_TickCount
        if (remainingMs < 0) {
            remainingMs := 0
        }
        status .= "`nNext run in: " Round(remainingMs / 1000) "s"
    }

    MsgBox(status, "Copilot Auto Status")
}

ResetBurstCounter()
{
    global counter
    counter := 0
    Log("MANUAL: Burst counter reset")
    TrayTip("Copilot Auto", "Burst counter reset", 2)
}

; =========================
; Hotkeys
; =========================

; Ctrl+Alt+G => toggle automation
^!g::
{
    global enabled, counter, isCoolingDown, nextRunAt

    enabled := !enabled

    if enabled {
        counter := 0
        isCoolingDown := false
        Log("ENABLED")
        TrayTip("Copilot Auto", "Enabled", 2)
        ScheduleNextRun("enabled")
    } else {
        SetTimer(MainLoop, 0)
        nextRunAt := 0
        Log("DISABLED")
        TrayTip("Copilot Auto", "Disabled", 2)
    }
}

; Ctrl+Alt+P => immediate pause / stop
^!p::
{
    global enabled, nextRunAt
    enabled := false
    SetTimer(MainLoop, 0)
    nextRunAt := 0
    Log("MANUAL PAUSE")
    TrayTip("Copilot Auto", "Paused", 2)
}

; Ctrl+Alt+C => force a manual cooldown
^!c::
{
    Log("MANUAL: Cooldown requested")
    StartCooldown(300000, 900000, "manual-cooldown") ; 5-15 min
}

; Ctrl+Alt+R => reset burst counter
^!r::
{
    ResetBurstCounter()
}

; Ctrl+Alt+S => show status
^!s::
{
    ShowStatus()
}

InitLog()
Log("SCRIPT STARTED")