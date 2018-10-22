#include 'CtrlEvent.au3'

GUICreate('CtrlEvent - Drop files', 400, 300)
GUISetBkColor(0x808080)

local $label = GUICtrlCreateLabel('Drop files here', 20, 20, 350, 200, 0x1, 0x00000010)
GUICtrlSetFont(-1, 12)

local $label_handle = GUICtrlGetHandle($label)

local $label_event = CtrlEvent_Reg($label_handle)
$label_event.onDrop = 'label_onDrop'

GUISetState()

do
    sleep(10)
until (GuiGetMsg() == -3)

CtrlEvent_UnReg($label)

func label_onDrop($e)
    local $files = StringReplace($e.files, ';', @crlf)

    local $text = 'Count: ' & $e.count & @crlf & $files

    GUICtrlSetData($label, $text)
endfunc