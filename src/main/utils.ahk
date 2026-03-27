; utils.ahk - wrapper helpers for sending keystrokes with logging and sleep
; Placed as a sibling include to copilot-auto-continue.ahk

Log(msg)
{
    global logFile
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    FileAppend("[" timestamp "] " msg "`n", logFile, "UTF-8")
}

LogSendEventSleep(logMessage, keyStroke, sleepTime := 300)
{
    Log(logMessage)
    SendEvent(keyStroke)
    Sleep(sleepTime)
}

LogSendInputSleep(logMessage, keyStroke, sleepTime := 300)
{
    Log(logMessage)
    SendInput(keyStroke)
    Sleep(sleepTime)
}

LogSendPlaySleep(logMessage, keyStroke, sleepTime := 300)
{
    Log(logMessage)
    SendPlay(keyStroke)
    Sleep(sleepTime)
}

RandomRange(minValue, maxValue)
{
    if (maxValue < minValue) {
        temp := minValue
        minValue := maxValue
        maxValue := temp
    }
    return Random(minValue, maxValue)
}

InitLog()
{
    global logDir, logFile
    logDir := A_ScriptDir "\..\..\target"
    DirCreate(logDir)

    ; Create a unique, enumerated log filename: copilot-auto-1.log, copilot-auto-2.log, ...
    logFile := ""
    Loop 1000 {
        candidate := logDir . "\copilot-auto-" . A_Index . ".log"
        if !FileExist(candidate) {
            logFile := candidate
            break
        }
    }

    if (!logFile) {
        logFile := logDir . "\copilot-auto.log"
    }
}