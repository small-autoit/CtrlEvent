# CtrlEvent
Win32 control event handler for AutoIt

### Features

- Hight performance.
- Syntax like Javascript.
- Mouse event: hover, press, release; position.
- Keyboard event: key code, character, control key is pressed, key is down/up.
- Drop files event: file counter, file name.
- Move event: offset x, y.
- Size event: size width, height.

## Syntax

- **Register event handler for control by its handle.**

    ```au3
    $event = CtrlEvent_Reg($handle)
    ```

- **Unregister event handler for control by its handle.**

    ```au3
    $result = CtrlEvent_UnReg($handle)
    ```

### Mouse event

```au3
$event.onMouse = func($e)
```

- `$e.x` -> x.
- `$e.y` -> y.
- `$e.state` -> 0 is left, 1 is just hovered, 2 is pressed, 3 is release.
- `$e.isOver` -> mouse is over on control/window.

### Keyboard event

```au3
$event.onKey = func($e)
```

- `$e.type` -> 0 is down, 1 is up.
- `$e.which`-> virtual key code.
- `$e.key` -> char of key.
- `$e.ctrlKey` -> ctrl key is pressed.
- `$e.altKey` -> alt key is pressed.
- `$e.shiftKey` -> shift key is pressed.

### Example

```au3
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
```
