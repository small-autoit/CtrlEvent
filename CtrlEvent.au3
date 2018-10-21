global $__user32 = dllopen('user32.dll')
global $__shell32 = dllopen('shell32.dll')
global $__msvcrt = dllopen('msvcrt.dll')

global $__CtrlEvent__SubProc = dllcallbackregister('__CtrlEvent__SubProc', 'lresult', 'hwnd;uint;wparam;lparam')
global $__pCtrlEvent__SubProc = dllcallbackgetptr($__CtrlEvent__SubProc)

global $__MAXPATH = 256

global $__tagCtrlEvent = _
	'hwnd hwnd;' 			& _
	'ptr oldproc;' 			& _
	'int timer;bool click;' & _
	'bool state;bool over;' & _
	'char onMove[50];'  	& _
	'char onSize[50];'  	& _
	'char onMouse[50];'  	& _
	'char onKey[50];' 		& _
	'char onDrop[50];'		& _
	'char onActivate[50];'

global $__tagCtrlEvent_size = dllstructgetsize(dllstructcreate($__tagCtrlEvent))

global $__tagKeyEvent = _
	'bool type;'			& _
	'bool altKey;'			& _
	'bool ctrlKey;'			& _
	'bool shiftKey;'		& _
	'short which;'			& _
	'char key[20];'

global $__tagMouseEvent = _
	'int x;'				& _
	'int y;'				& _
	'short state;'			& _
	'bool isOver;'

global $__tagDragEvent = _
	'wchar files[' 			& _
	$__MAXPATH & '];' 		& _
	'uint count;'

global $__tagMoveEvent = _
	'int x;'				& _
	'int y;'

global $__tagSizeEvent = _
	'uint type;'			& _
	'uint width;'			& _
	'uint height;'

; // Main functions
; ==================================================

func CtrlEvent_Reg($handle)
	if (isptr(__CE_GetWindowLong($handle, -21))) then _
		return 0

	local $ptr = __CE_MemAlloc($__tagCtrlEvent_size)
	local $self = dllstructcreate($__tagCtrlEvent, $ptr)
	if @error then return 0

	$self.hwnd = $handle
	__CE_SetWindowLong($handle, -21, $ptr)

	$self.oldproc = __CE_GetWindowLong($handle, -4)
	__CE_SetWindowLong($handle, -4, $__pCtrlEvent__SubProc)

	return $self
endfunc

func CtrlEvent_UnReg($handle)
	local $ptr = __CE_GetWindowLong($handle, -21)
	local $self = dllstructcreate($__tagCtrlEvent, $ptr)
	if @error then return 0

	__CE_SetWindowLong($handle, -4, $self.oldproc)
	__CE_SetWindowLong($handle, -21, null)
	__CE_MemFree($ptr)

	return 1
endfunc

; // Main SubProc callback / event handler
; ==================================================

func __CtrlEvent__SubProc($handle, $msg, $wp, $lp)
	local $ptr = __CE_GetWindowLong($handle, -21)
	local $self = dllstructcreate($__tagCtrlEvent, $ptr)
	if (@error or (not $ptr)) then return 0

	switch ($msg)

		case 0x0003
			if ($self.onMove) then

				local $e = dllstructcreate($__tagMoveEvent)
				$e.x = bitand($lp, 0xffff)
				$e.y = bitshift($lp, 0xf)

				call($self.onMove, $e)

				return 0

			endif

		case 0x0005
			if ($self.onSize) then

				local $e = dllstructcreate($__tagSizeEvent)
				$e.type = $wp
				$e.width = bitand($lp, 0xffff)
				$e.height = bitshift($lp, 0xf)

				call($self.onSize, $e)

				return 0

			endif

		case 0x0100, 0x0101
			if ($self.onKey) then

				local $e = dllstructcreate($__tagKeyEvent)

				$e.which = $wp
				$e.key = chr($wp)
				$e.type = ($msg == 0x0100 ? 0 : 1)
				$e.shiftKey = (__CE_GetAsyncKeyState(0xa0) or __CE_GetAsyncKeyState(0xa1)) and 0x800
				$e.ctrlKey = (__CE_GetAsyncKeyState(0xa2) or __CE_GetAsyncKeyState(0xa3)) and 0x800
				$e.altKey = (__CE_GetAsyncKeyState(0xa4) or __CE_GetAsyncKeyState(0xa5)) and 0x800

				call($self.onKey, $e)
				return 0

			endif

		case 0x0113
			if ($self.onMouse) then

				local $pt = dllstructcreate('int[2]')
				local $rc = dllstructcreate('int[4]')
				__CE_GetCursorPos($pt)
				__CE_GetWindowRect($handle, $rc)

				$self.over = __CE_PtInRect($rc, $pt)

				if (not $self.over) then
					__CE_KillTimer($handle, $self.timer)
					$self.timer = 0
					$self.state = 0
					$self.click = 0
					__CE_ReleaseCapture()

					local $e = dllstructcreate($__tagMouseEvent)
					$e.isOver = $self.over
					$e.state = $self.state

					call($self.onMouse, $e)
				endif

				return 0

			endif

		case 0x0200
			if ($self.onMouse) then

				if ($self.click == 2 or $self.state) then return 0

				if (not $self.over) then
					$self.over = 1
					if ($self.timer == 0) then $self.timer = __CE_SetTimer($handle, 69, 30, null)

					if ($self.click) then
						if (iState == 2) then return 0
						$self.state = 2
					else
						if ($self.state == 1) then return 0
						$self.state = 1
					endif
				else
					if (not $self.state) then return 0
					iState = 0
				endif
				
				local $e = dllstructcreate($__tagMouseEvent)
				$e.isOver = $self.over
				$e.state = $self.state
				$e.x = bitand($lp, 0xffff)
				$e.y = bitshift($lp, 0xf)

				call($self.onMouse, $e)

				return 0

			endif

		case 0x0201
			if ($self.onMouse) then

				if ($self.over) then
					__CE_SetCapture($handle);
					if ($self.click == 2) then return 0

					$self.click = 1
					$self.state = 2

					local $e = dllstructcreate($__tagMouseEvent)
					$e.isOver = $self.over
					$e.state = $self.state
					$e.x = bitand($lp, 0xffff)
					$e.y = bitshift($lp, 0xf)

					call($self.onMouse, $e)

				endif
				return 0

			endif

		case 0x0202
			if ($self.onMouse) then

				__CE_ReleaseCapture()
				if (not $self.click) then return 0
				if ($self.over) then
					$self.state = 1
					$self.click = 0

					local $e = dllstructcreate($__tagMouseEvent)
					$e.isOver = $self.over
					$e.state = 3;$self.state
					$e.x = bitand($lp, 0xffff)
					$e.y = bitshift($lp, 0xf)

					call($self.onMouse, $e)

				else
					$self.state = 0
					$self.click = 0
					; // // //
				endif
				return 0

			endif

		case 0x0233
			if ($self.onDrop) then
				local $count = __CE_DragQueryFile($wp, 0xFFFFFFFF, null)
				local $files = ''

				for $i = 0 to $count-1
					local $name
					__CE_DragQueryFile($wp, $i, $name)
					$files &= $name & ($count == 1 ? '' : ';')
				next
				
				local $e = dllstructcreate('wchar files[' & stringlen($files)+1 & '];uint count;')
				$e.count = $count
				$e.files = $files
				__CE_DragFinish($wp)

				call($self.onDrop, $e)
			endif

	endswitch

	return __CE_CallWindowProc($self.oldproc, $handle, $msg, $wp, $lp)
endfunc

; // User32 API
; =========================

func __CE_CallWindowProc($oldproc, $handle, $msg, $wp, $lp)
	local $ret = dllcall($__user32, 'lresult', 'CallWindowProcW', _
		'ptr', $oldproc, 'hwnd', $handle, 'uint', $msg, 'wparam', $wp, 'lparam', $lp)
	return @error ? 0 : $ret[0]
endfunc

func __CE_GetWindowLong($handle, $idx)
	local $ret = dllcall($__user32, "long_ptr", @autoitx64 ? 'GetWindowLongPtrW' : 'GetWindowLongW', _
		"hwnd", $handle, "int", $idx)
	return @error ? 0 : $ret[0]
endfunc

func __CE_SetWindowLong($handle, $idx, $val)
	local $ret = dllcall($__user32, "long_ptr", @autoitx64 ? 'SetWindowLongPtrW' : 'SetWindowLongW', _
		"hwnd", $handle, "int", $idx, 'long_ptr', $val)
	return @error ? 0 : $ret[0]
endfunc

func __CE_GetKeyState($nVirtKey)
	local $ret = dllcall($__user32, 'short', 'GetKeyState', 'int', $nVirtKey)
	return @error ? 0 : $ret[0]
endfunc

func __CE_GetAsyncKeyState($nVirtKey)
	local $ret = dllcall($__user32, 'short', 'GetAsyncKeyState', 'int', $nVirtKey)
	return @error ? 0 : $ret[0]
endfunc

func __CE_GetCursorPos($stPoint)
	dllcall($__user32, 'bool', 'GetCursorPos', 'struct*', $stPoint)
endfunc

func __CE_GetWindowRect($handle, $stRect)
	dllcall($__user32, 'bool', 'GetWindowRect', 'hwnd', $handle, 'struct*', $stRect)
endfunc

func __CE_PtInRect($stRect, $stPoint)
	local $ret = dllcall($__user32, "bool", "PtInRect", "struct*", $stRect, "struct", $stPoint)
	return @error ? 0 : $ret[0]
endfunc

func __CE_SetCapture($handle)
	dllcall($__user32, 'bool', 'SetCapture', 'hwnd', $handle)
endfunc

func __CE_ReleaseCapture()
	dllcall($__user32, 'bool', 'ReleaseCapture')
endfunc

func __CE_InvalidateRect($handle, $stRect, $bErase)
	dllcall($__user32, 'bool', 'InvalidateRect', 'hwnd', $handle, 'struct*', $stRect, 'bool', $bErase)
endfunc

func __CE_SetTimer($handle, $id, $time, $timerProc)
	local $ret = dllcall($__user32, 'uint', 'SetTimer', 'hwnd', $handle, 'uint', $id, 'uint', $time, 'ptr', $timerProc)
	return @error ? 0 : $ret[0]
endfunc

func __CE_KillTimer($handle, $id)
	dllcall($__user32, 'bool', 'KillTimer', 'hwnd', $handle, 'uint', $id)
endfunc

; // Shell32 API
; =========================

func __CE_DragFinish($hDrop)
	dllcall($__shell32, 'none', 'DragFinish', 'handle', $hDrop)
endfunc

func __CE_DragQueryFile($hDrop, $iFile, byref $sFile)
	local $ret
	if ($sFile <> null) then
		local $wcs = dllstructcreate('wchar val[' & $__MAXPATH & ']')
		$ret = dllcall($__shell32, 'uint', 'DragQueryFileW', 'handle', $hDrop, 'uint', $iFile, 'ptr', dllstructgetptr($wcs, 1), 'uint', $__MAXPATH)
		$sFile = $wcs.val
	else 
		$ret = dllcall($__shell32, 'uint', 'DragQueryFileW', 'handle', $hDrop, 'uint', $iFile, 'ptr', null, 'uint', $__MAXPATH)
	endif

	return @error ? 0 : $ret[0]
endfunc

; // MSVCRT API
; =========================

func __CE_MemAlloc($size)
	local $ret = dllcall('msvcrt', 'ptr:cdecl', 'calloc', 'uint', 1, @autoitx64 ? 'uint64' : 'uint', $size)
	return @error ? 0 : $ret[0]
endfunc

func __CE_MemFree($ptr)
	dllcall('msvcrt', 'none:cdecl', 'free', 'ptr', $ptr)
endfunc