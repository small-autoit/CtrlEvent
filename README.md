# CtrlEvent
Win32 control event handler for AutoIt

## Features

- Hight performance.
- Syntax like Javascript.
- Mouse event: hover, press, release; position.
- Keyboard event: key code, character, control key is pressed, key is down/up.
- Drop files event: file counter, file name.
- Move event: offset x, y.
- Size event: size width, height.

## Event handler

- **Register event handler for control by its handle.**

```au3
$event = CtrlEvent_Reg($handle)
    ; IsDllSctruct($event) == 1 ; -> succeed, 0 is failed
    ; $event == 0 ; -> failed
```

- **Unregister event handler for control by its handle.**

```au3
$result = CtrlEvent_UnReg($handle)
    ; -> 1 : succeed
    ; -> 0 : failed
```

### Mouse event

```au3
$event.onMouse = '__onMouse'

func __onMouse($e)
    $e.x      ; -> mouse x pos on control.
    $e.y      ; -> mouse y pos on control.
    $e.state  ; -> state of mouse
              ;    +> 0 : left.
              ;    +> 1 : just hovered.
              ;    +> 2 : pressed.
              ;    +> 3 : clicked and just release.
    $e.isOver ; -> is mouse over on control.
endfunc
```

### Keyboard event

```au3
$event.onKey = '__onKeyEvent'

func __onKeyEvent($e)
    $e.type     ; -> state of key
                ;    +> 0 : key is down.
                ;    +> 1 : key is up.
    $e.which    ; -> virtual key code.
    $e.key      ; -> char of key.
    $e.isHotkey ; -> key pressed is a hotkey ($e.type be down).
    $e.ctrlKey  ; -> ctrl key is pressed.
    $e.altKey   ; -> alt key is pressed.
    $e.shiftKey ; -> shift key is pressed.
endfunc
```

### Scroll event

```au3
$event.onScroll = '__onScroll'

func __onScroll($e)
    $e.min    ; -> minimium position.
    $e.max    ; -> maximium position.
    $e.page   ; -> range page of scrolling.
    $e.pos    ; -> position of scrolling.
    $e.type   ; -> type of scrollbar
              ;    +> 0 : horizontal scrollbar.
              ;    +> 1 : vertical scrollbar.    
    $e.action ; -> user's action on scrollbar
              ;    +> 0 : scrolls left/top by one unit.
              ;    +> 1 : scrolls right/down by one unit.
              ;    +> 2 : scrolls left/top by the width/height of the window.
              ;    +> 3 : scrolls right/down by the width/height of the window.
              ;    +> 4 : the user has dragged the scroll box (thumb) and released the mouse button
              ;    +> 5 : the user is dragging the scroll box; 
              ;        this message is sent repeatedly until the user releases the mouse button.
              ;    +> 6 : scrolls to the upper left/top.
              ;    +> 7 : scrolls to the upper right/bottom.
              ;    +> 8 : ends scroll.
endfunc

```




## Example

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
