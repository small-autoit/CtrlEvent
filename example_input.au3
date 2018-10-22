#include "CtrlEvent.au3"

GUICreate("CtrlEvent - Input", 250, 200)

$input = GUICtrlCreateInput("Text here and Enter", 30, 30, 150, 23)
$input_handle = GUICtrlGetHandle($input)

$input_event = CtrlEvent_Reg($input_handle)
$input_event.onKey = 'input_onKey'

$label = GUICtrlCreateLabel("", 30, 60, 100, 100)
GUICtrlSetFont(-1, 11)

GUISetState()

do
	sleep(10)
until (GuiGetMsg() == -3)

func input_onKey($e)
	; enter key code
	if ($e.which == 13) then
		local $data = GuiCtrlRead($input)
		GUICtrlSetData($input, '')
		GUICtrlSetData($label, $data)
	else
		GUICtrlSetData($label, 'writing...')
	endif
endfunc