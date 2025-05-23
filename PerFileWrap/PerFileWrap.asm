;-------------------------------------------------------------------------------
; Per-File Wrapping
;-------------------------------------------------------------------------------
; (call fasm2 -e 9 PerFileWrap.asm && link @PerFileWrap.response) && exit
; (del *.response *.obj *.exp *.lib) && exit

include '..\PluginInterface.g' ; ensure needed parts are defined
include 'map.BufferID.inc'

{const:2} PluginNameW du 'PerFileWrap',0
{data:1} g_isPerFileWrapEnabled db MF_CHECKED ; start enabled

;-------------------------------------------------------------------------------

; This data defines the plugin menu (needs to be writeable):
BLOCK COFF.8.DATA
	g_priorBufferId dq ?

	label CommandItems:3 ; sizeof = FuncItem item count

	; Populate our menu item entries:

	PluginToggle	FuncItem \
		_itemName:	<'Enabled',0>,\	; menu text
		_pFunc:		toggleEnable,\	; function to call
		_cmdID:		0,\		; plugin manager sets id
		_init2Check:	TRUE,\		; start enabled
		_pShKey:	NULL		; no shortcut key

	; Separator when _pFunc = NULL!
			FuncItem

	PluginAbout	FuncItem \ ; just the needed parts
		_itemName:	<'About...',0>,\
		_pFunc:		showAbout

END BLOCK


:toggleEnable:
	enter .frame, 0
	; Use the same bit as MF_CHECKED to simplify the code.
	xor [g_isPerFileWrapEnabled], MF_CHECKED

	call applyCurrentBufferState

	movzx r9, [g_isPerFileWrapEnabled] ; MF_CHECKED | MF_UNCHECKED
	SendMessageW [g_hNPP], NPPM_SETMENUITEMCHECK, [PluginToggle._cmdID], r9
	leave
	retn


:showAbout:
	enter .frame, 0
	MessageBoxW [g_hNPP], <W\
		'This plugin caches the Word Wrap setting for each file. Set',10,\
		'one file to wrap text and another file to not wrap text, and',10,\
		'Notepad++ will remember your choice for each file as you',10,\
		'switch between.'>, & PluginNameW, MB_OK
	leave
	retn

;----------------------------------- Notepad++ Plugin Interface Implementation:

; Notification callback - process NPPN_* codes:
:beNotified: public ; void beNotified(SCNotification *notifyCode);
	iterate notification,\
		NPPN_BUFFERACTIVATED,\
		NPPN_FILEBEFORECLOSE

		cmp [rcx + NMHDR.code], notification
		jz .notification
	end iterate
	retn

.NPPN_BUFFERACTIVATED equ applyCurrentBufferState

.NPPN_FILEBEFORECLOSE: ; Remove cached wrap mode for bufferId.
	Map__Remove [rcx + NMHDR.idFrom] ; BufferID
	retn

;Notepad++ Plugin Interface Implementation -----------------------------------:

:applyCurrentBufferState:
	enter .frame, 0
	virtual at rbp+16
		.hSci	dq ?	; current handle
		.iBuf	dq ?	; BufferId
		.iWrap	dd ?	; SC_WRAP_*
	end virtual

	test [g_isPerFileWrapEnabled], -1
	jz .done

	SendMessageW [g_hNPP], NPPM_GETCURRENTSCINTILLA, 0, & .hSci
	test dword [.hSci], -1 ; index or error
	js .done
	cmovnz rax, [g_hScintilla1]
	cmovz rax, [g_hScintilla0]
	mov [.hSci], rax

	SendMessageW [.hSci], SCI_GETWRAPMODE, 0, 0
	mov [.iWrap], eax		; current state

	SendMessageW [g_hNPP], NPPM_GETCURRENTBUFFERID, 0, 0
	test rax, rax
	jz .done
	mov [.iBuf], rax

	mov rcx, [g_priorBufferId]
	jrcxz .skip_retro
	cmp rcx, rax
	jz .skip_retro
	Map__Set rcx,,[.iWrap]
.skip_retro:
	mov rcx, [.iBuf]
	mov [g_priorBufferId], rcx
	Map__Get rcx
	jz .use_cached_state
	Map__Set [.iBuf],,[.iWrap]	; cache current state
	jmp .done

.use_cached_state:
	cmp [.iWrap], eax
	jz .done

	mov [.iWrap], eax		; use prior cached state
	test eax, eax
	setnz al
	movzx r8d, al			; SC_WRAP_NONE | SC_WRAP_WORD
	SendMessageW [.hSci], SCI_SETWRAPMODE, r8, 0

	mov r9d, MF_CHECKED
	test [.iWrap], -1
	cmovz r9d, [.iWrap] ; Any non- SC_WRAP_NONE mode is wrapping enabled.
	SendMessageW [g_hNPP], NPPM_SETMENUITEMCHECK, IDM_VIEW_WRAP, r9

.done:	leave
	retn
