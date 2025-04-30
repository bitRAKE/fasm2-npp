; BufferID's are mapped to/from SC_WRAP_* values:
;	Map.Remove	0 -> {RCX}		; clear reference
;	Map.Get		{RCX} -> RAX		; value of retrieved
;	Map.Set		R8B -> {RCX}		; overwrite reference value
;
; Notes:
;   + Generally, the ZF signals failure/success of intended operation.
;   + Almost standard ABI.

calminstruction Map__Remove id*
	asm fastcall MAP?.Remove,id
end calminstruction
calminstruction Map__Get id*
	asm fastcall MAP?.Get,id
end calminstruction
calminstruction Map__Set id*,ignore,value*
	asm fastcall MAP?.Set,id,rdx,value
end calminstruction


define MAP? MAP?
namespace MAP?

ENTRIES := 64*2 ; increase [in multiples of 64] as needed

BLOCK COFF.64.BSS
	id	rq ENTRIES		; BufferID array
	state	rb ENTRIES		; byte, SC_WRAP_* values
END BLOCK

align 16, codepad #
find:	jrcxz find.BUFFER_INVALID
	xchg rax, rcx
.0:	mov ecx, ENTRIES
	lea rdx, [id - 8]		; adjust for 1-based indexing
@@:	cmp [rdx + rcx*8], rax
	loopnz @B
	retn
.BUFFER_INVALID:
	test rsp, rsp			; clear ZF, same as not found, full
	pop rax				; leaf returns to parent's parent
	retn


Get:	call find			;---------------------------------------
	jnz @0F
	lea rdx, [state]
	movzx eax, byte [rdx + rcx]
@0:	retn				; ZF=1, found, data valid, rAx = SC_WRAP_* value
					; ZF=0, not found


Remove:	call find			;---------------------------------------
	jnz @0F
	and qword [rdx + (rcx+1)*8], 0	; BUFFER_INVALID, ZF=1
@0:	retn				; ZF=1, found, entry removed
					; ZF=0, not found


Set:	call find			;---------------------------------------
	jz @1F				; Y: found, replace value
	push rax
	xor eax, eax
	call find.0
	pop rax
	jnz @0F				; Y: full, ignore error
	mov [rdx + (rcx+1)*8], rax
@1:	lea rdx, [state]
	mov [rdx + rcx], r8b
@0:	retn				; ZF=1, state set/update
					; ZF=0, full, no change to state

end namespace ; MAP
