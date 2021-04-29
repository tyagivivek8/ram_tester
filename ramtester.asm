                             #make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

          jmp     st1 

          db     1021 dup(0) 
          
;jmp st1 will take up 3 bytes in memory - another 1021 bytes are filled with '0s'
;1021 + 3 bytes = 1024 bytes
;first 1 k of memory is IVT - 00000 -00002H will now have the jmp instruction. 00003H - 001FFH will
;have 00000 - as vector number 0 to FFH are unused
      
          ;main program
          ;code segment will be in ROM 
        
st1:      cli   

; intialize ds, es,ss to start of RAM - that is 020000H - as you need r/w capability for DS,ES & SS
; 0002H is the offset in data segmnet where we are storing the data.
; db can be used only to store data in code segment

          mov ax,0200h
          mov ds,ax
          mov es,ax
          mov ss,ax
          mov sp,0FFFEH
          
          ;intialise portA as input portb,portc as output for the first 8255

          mov al,90h
		  out 06h,al        

          ;Keep polling port A until you get 1 from the switch 

poll:     in  al,00h
          mov bl,01h
          cmp bl,al 
          jnz poll   
                                    
start:

          ;Initialize portA,B as output and port C isnt connected

          mov al,10000000b        
          out 0Eh,al        

                     
          mov dx,00h            ;initial address for RAM testing          
 
          
          
          
byte:     mov bh, 00h           ;for writing zeroes
          mov bl, 01h           ;for writing ones
          mov ah, 08h           ;count for bits to be tested in a byte
          
                    
bits:     ;writing zero

          mov al,10010010b      ;Initialize 3rd 8255 to write data ;So port C in output mode
          out 16h,al 
          
          
          mov al,dl             ;Sends Address to address lines A0-A7 
          out 08h,al
          
          mov al,dh             ;Get address lines A8-A12
          and al,10111111b      ;Turn on WE' 
          or  al,00100000b      ;Turn off OE'
          and al,01111111b      ;Turn on CE'
          
          out 0Ah,al            ;sends Address to address lines A8-A12 and control signals
                                      
                                      
          mov al, bh            ;Write from Port C of 3rd 8255
          out 14h,al    
                                            
          ;reading zero
          
          mov al,dh             ;Get address lines A8-A12
          and al,11011111b      ;Turn on OE'
          or  al,01000000b      ;Turn off WE'  
          and al,01111111b      ;Turn on CE'              
          out 0Ah,al            ;sends Address to address lines A8-A12 and control signals
                  
    

          mov al,10011011b      ;Initialize 3rd 8255 to read data : So port C in input mode  
          out 16h,al         
          
          in  al,14h            ;Data is read from RAM using port C of 3rd 8255
          and al,bl             ;To get a specific bit and mask rest of the bits
          
     
          cmp al,bh             ;compare data read to the data written previously
          jnz fail              ;if data read and written are different, display FAIL
          
          ;writing one
          
          mov al,10010010b      ;Initialize 3rd 8255 to write data ;So port C in output mode
          out 16h,al 
          
          
          mov al,dl             ;Sends Address to address lines A0-A7
          out 08h,al
          
          mov al,dh             ;Get address lines A8-A12
          and al,10111111b      ;Turn on WE'
          or  al,00100000b      ;Turn off OE'
          and al,01111111b      ;Turn on CE'
          
          out 0Ah,al            ;sends Address to address lines A8-A12 and control signals
                                      
                                      
          mov al, bl            ;Write from Port C of 3rd 8255
          out 14h,al    
          
          ;reading one                                  
          
          mov al,dh             ;Get address lines A8-A12
          and al,11011111b      ;Turn on OE'
          or  al,01000000b      ;Turn off WE'  
          and al,01111111b      ;Turn on CE'              
          out 0Ah,al            ;sends Address to address lines A8-A12 and control signals
                  
    

          mov al,10011011b      ;Initialize 3rd 8255 to read data : So port C in input mode  
          out 16h,al         
          
          in al,14h             ;Data is read from RAM using port C of 3rd 8255
          and al,bl             ;To get a specific bit and mask rest of the bits
          
     
          cmp al,bl             ;compare data read to the data written previously
          jnz fail              ;if data read and written are different, display FAIL
          
          rol bl,1              ;rotate bl to check for next bit
          dec ah                ;decreases the count of bits to be checked after one successful check
          jnz bits              ;repeat till all bits of a byte are checked

          inc dx                ;increment address to check next byte of RAM
          cmp dx,8192d          ;check if the last byte of RAM is checked
          jz pass               ;display PASS if all bytes are checked

          jmp  byte             ;repeat till all bytes are checked
                                                           
          
   
;Fail on LED               
           
fail:     mov al,0FFh
          out 04,al 
          
          
          mov al,01h
          out 02h,al 
          
          mov al,8eh         ;For F
          out 04h,al 
          
          mov al,02h
          out 02h,al 
          
          mov al,88h         ;For A
          out 04h,al
                      
          mov al,00
          out 02h,al
          
          mov al,0ffh
          out 04h,al 
          
          mov al,04h
          out 02h,al
          
          
          mov al,0F9h        ;For I
          out 04h,al         
          
          
          mov al,08h
          out 02h,al 
          
          mov al,0c7h        ;For L
          out 04h,al 
          
          mov al,00
          out 02h,al
          
          mov al,0ffh
          out 04h,al     
          
          in  al,00h         ;check if user wants to test RAM
          mov bl,01h
          cmp bl,al 
          jz  start  
                            
          
          jmp fail           ;else keep displaying FAIL
                         

;Pass on LED       

pass:     mov al,0FFh
          out 04,al 
          
          
          mov al,01h
          out 02h,al 
          
          mov al,8ch         ;For P
          out 04,al 
          
          mov al,02h
          out 02h,al 
          
          mov al,88h         ;For A
          out 04,al
          
          mov al,04h
          out 02h,al 
          
          mov al,92h         ;For S
          out 04,al         
          
          
          mov al,08h
          out 02h,al 
          
          mov al,92h         ;For S
          out 04,al 
          
          mov al,00
          out 02h,al
          
          mov al,0ffh
          out 04h,al      
          
          in  al,00h         ;check if user wants to test RAM
          mov bl,01h
          cmp bl,al 
          jz  start          ;else keep displaying PASS
                            
          
          jmp pass
          
;delay proc near
;        mov cx,22726d
 ;       
  ;      x1: nop
   ;         dec cx
    ;        jnz x1
     ;   ret

