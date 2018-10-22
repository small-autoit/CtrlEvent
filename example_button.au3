#include "CtrlEvent.au3"

GUICreate("CtrlEvent - Button", 400, 200)

$button = GUICtrlCreateButton('Hover and click me', 30, 30, 150, 40)

$button_handle = GUICtrlGetHandle($button)

$button_event = CtrlEvent_Reg($button_handle)
$button_event.onMouse = 'button_onMouse'

$label = GUICtrlCreateLabel("", 50, 80, 300, 100)
GUICtrlSetFont(-1, 11)

GUISetState()

do
	sleep(10)
until (GuiGetMsg() == -3)

func button_onMouse($e)
	local $info = '', $text = ''

	switch ($e.state)
		case 0
			$info = 'mouse just left'
		case 1
			$info = 'mouse is hovered'
		case 2
			$info = 'mouse is pressed'
		case 3
			$info = 'mouse is clicked and just release'
	endswitch
	$text  = StringFormat( _
				'Status: ' & $info & '\n' & _
				'Mouse is over: ' & ($e.isOver == 1) & '\n' & _
				'Position: ' & $e.x & ' - ' & $e.y _
			)

	GUICtrlSetData($label, $text)
endfunc