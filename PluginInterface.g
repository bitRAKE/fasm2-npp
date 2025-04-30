; This file is part of Notepad++ project
; Copyright (C)2024 Don HO <don.h@free.fr>

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; at your option any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

; For more comprehensive information on plugin communication, please refer to the following resource:
; https://npp-user-manual.org/docs/plugin-communication/

include 'windows.g'

include 'Scintilla.g'		; Scintilla constants
;include 'ScintillaCallEx.g'	; direct call interface

include 'Notepad_plus_msgs.g'	; Notepad++ plugin SDK header
include 'menuCmdID.g'		; menu resource IDs
;include 'Docking.g'		;


struct NppData
	_nppHandle		dq ? ; HWND = nullptr
	_scintillaMainHandle	dq ? ; HWND = nullptr
	_scintillaSecondHandle	dq ? ; HWND = nullptr
ends

struct ShortcutKey
	_isCtrl		db ?	; bool
	_isAlt		db ?	; bool
	_isShift	db ?	; bool
	_key		db ?	; u8
ends

menuItemSize := 64

; typedef void (__cdecl * PFUNCPLUGINCMD)();
struct FuncItem
	_itemName	du menuItemSize dup ?	; wchar_t[menuItemSize]
	_pFunc		dq ?			; PFUNCPLUGINCMD
	_cmdID		dd ?			; int
	_init2Check	db ?			; bool
	__align_0	db ?,?,?
	_pShKey		dq ?			;*ShortcutKey
ends

; Implement those functions which are called by Notepad++ plugin manager.
; (See examples to better understand default functions.)
postpone
	; To simplify plugin creation default stubs for typical function
	; implementations are provided:

	if ~ definite _DllMainCRTStartup
		:_DllMainCRTStartup: public ; BOOL DllMain(..);
	end if

	; isUnicode() always true, since Notepad++ isn't compiled in ANSI mode anymore.
	; BOOL isUnicode();
	if ~ definite isUnicode
		; Indicates that the plugin supports Unicode.
		:isUnicode: public
	end if

	if _DllMainCRTStartup = $ | isUnicode = $
		push 1 ; TRUE
		pop rax
		retn
	end if

	; const TCHAR * getName();
	if ~ definite getName
		; Returns the plugin name.
		:getName: public
			lea rax, [PluginNameW]
			retn
	end if

	; FuncItem * getFuncsArray(int *nbF);
	if ~ definite getFuncsArray
		; Returns the static array of plugin commands (_MUST_ be writeable).
		:getFuncsArray: public
			lea rax, [CommandItems]
			mov dword [rcx], sizeof CommandItems
			retn
	end if

	; LRESULT messageProc(UINT Message, WPARAM wParam, LPARAM lParam);
	if ~ definite messageProc
		; Message proc callback (if needed).
		:messageProc: public
			xor eax, eax
			retn
	end if

	; void beNotified(SCNotification *notifyCode);
	if ~ definite beNotified
		; Notification callback (if needed).
		:beNotified: public
			; Handle notifications if necessary.
			retn
	end if

	; void setInfo(NppData notepadPlusData);
	if ~ definite setInfo
		BLOCK COFF.8.BSS
			g_hNPP		dq ?
			g_hScintilla0	dq ?
			g_hScintilla1	dq ?
		END BLOCK

		; Called when the plugin is loaded.
		:setInfo: public
			; Dereferrence structure to simply all other code.
			push [rcx + NppData._scintillaSecondHandle]
			push [rcx + NppData._scintillaMainHandle]
			push [rcx + NppData._nppHandle]
			pop [g_hNPP]
			pop [g_hScintilla0]
			pop [g_hScintilla1]
			retn
	end if

	; Common linker settings:
	virtual as "response"
		db '/NOLOGO',10 ; don't show linker version header

	; Use to debug build process:
	;	db '/VERBOSE',10
	;	db '/TIME+',10

	; Create unique binary using image version and checksum:
		db '/RELEASE',10 ; set program checksum in header
		repeat 1,T:__TIME__ shr 16,t:__TIME__ and 0xFFFF
			db '/VERSION:',`T,'.',`t,10
		end repeat

		db "/DLL",10
		db '/SUBSYSTEM:WINDOWS,6.00',10
		db '/NOCOFFGRPINFO',10	; no debug info, undocumented

;		db '/MERGE:.rdata=.text',10 ; reduce executable size

	; Default is 1MB reserve for each:
		db '/HEAP:0,0',10	; allocation granularity sufficient
		db '/STACK:0,0',10	; allocation granularity sufficient

		db '/DYNAMICBASE',10
		db '/HIGHENTROPYVA',10
		db '/NODEFAULTLIB',10

		db '/EXPORT:setInfo',10
		db '/EXPORT:beNotified',10
		db '/EXPORT:getName',10
		db '/EXPORT:getFuncsArray',10
		db '/EXPORT:messageProc',10
		db '/EXPORT:isUnicode',10

		db 'kernel32.lib',10
		db 'user32.lib',10

	; The first object file defines the DLL name, unless /OUT: is used:
	; (Breaks output names change on fasmg command line!)
		__BASE__ = __SOURCE__ bswap lengthof __SOURCE__
		while '.' <> __BASE__ and 0xFF
			__BASE__ = __BASE__ shr 8
		end while
		__BASE__ = __BASE__ bswap lengthof __BASE__
		db __BASE__,'obj',10
	end virtual

end postpone
