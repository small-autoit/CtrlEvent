#include 'CtrlEvent.au3'

GUICreate('Test')

local $Btn = GUICtrlCreateButton('text', 20, 20, 100, 35, -1, 0x00000010)
local $hBtn = GUICtrlGetHandle($Btn)

local $Btn_event = CtrlEvent_Reg($hBtn)
$Btn_event.onKey = 'Btn_onKey'
$Btn_event.onMouse = 'Btn_onMouse'
$Btn_event.onDrop = 'Btn_onDrop'

GUISetState()

while 1
	switch GUIGetMsg()
		case -3
			CtrlEvent_UnReg($hBtn)
			exit

		case $Btn ; cannot use this

	endswitch
wend

func Btn_onKey($e)
	ConsoleWrite('type: ' & $e.type & ', which: ' & $e.which & ', key: ' & $e.key & _
		', ctrl: ' & $e.ctrlKey & ', alt: ' & $e.altKey & ', shift: ' & $e.shiftKey & @crlf)
endfunc

func Btn_onMouse($e)
	ConsoleWrite('mouse state: ' & $e.state & ', isOver: ' & $e.isOver & ', position: ' & $e.x & ' - '& $e.y & @crlf)
endfunc

func Btn_onDrop($e)
	ConsoleWrite('file counted: ' & $e.count & ', name: ' & $e.files & @crlf)
endfunc