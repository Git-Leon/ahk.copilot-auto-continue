; utils.ahk - wrapper helpers for sending keystrokes with logging and sleep
; Placed as a sibling include to copilot-auto-continue.ahk

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
