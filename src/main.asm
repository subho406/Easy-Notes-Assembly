
section .data                           ;Data segment
   IntroMsg db 'Please input an action:  ',10,'1. read - Read a Message',10,'2. write - Write a Message',10,'3. edit - Edit a Message',10,'Action: ',0 ;Ask the user to enter a number
   lenIntroMsg equ $-IntroMsg             ;The length of the message
   readMsg db 10,'You have entered Read mode ',10,'Please enter a message name to read: ',0
   lenReadMsg equ $-readMsg    
   writeMsg db 10,'You have entered Write mode ',10,'Please give a name to your message: ',0
   lenWriteMsg equ $-writeMsg
   writeMsg2 db 10,'Type your message (Press enter to exit) : ',10,0
   lenWriteMsg2 equ $-writeMsg2  
   InvalidMsg db 10,'Invalid Command entered. Please try again.',10,0
   lenInvalidMsg equ $-InvalidMsg    
   readinst db 'read',0,0,0,0          ;Read intruction stored in 8 bytes - 64 bit 
   editinst db 'edit',0,0,0,0

   writeinst db 'write',0,0,0,0          ;Write intruction stored in 8 bytes - 64 bit 
   readMsg2 db 'Message: ',10,0
   lenReadMsg2 equ $-readMsg2
   len equ 1024


section .bss           ;Uninitialized data
   choice resb 8		; Stores the user choice of whether to read or write a file
   filename resb  8;Name of the file to read or write, length should be less than 8 bytes ie 8 characters
	readbuf resb 1024
   writebuf resb 1024
   fd_out resb 1

section .text          ;Code Segment
   global _start



 _read:
   mov eax, 4
   mov ebx, 1
   mov ecx, readMsg
   mov edx, lenReadMsg
   int 80h  
   ;Read the filename and store in location filename
   mov eax, 3
   mov ebx, 2
   mov ecx, filename
   mov edx, 8         ;8 bytes for filename
   int 80h 

   mov eax, 4
   mov ebx, 1
   mov ecx, readMsg2
   mov edx, lenReadMsg2
   int 80h  

   mov ebx, filename ; const char *filename
   mov eax, 5  
   mov ecx, 0  
   int 80h     

   mov [fd_out], eax
   

   mov eax, 3  
   mov ebx, eax
   mov ecx,readbuf
   mov edx, len    
   int 80h     

   mov eax, 6
   mov ebx, [fd_out]

   mov eax, 4  
   mov ebx, 1
   mov ecx, readbuf 
   mov edx, len    
   int 80h     

   mov eax, 1
   mov ebx, 0
   int 80h 

_write:
   mov eax, 4
   mov ebx, 1
   mov ecx, writeMsg
   mov edx, lenWriteMsg
   int 80h  

  ;Read the filename and store in location filename
   mov eax, 3
   mov ebx, 2
   mov ecx, filename
   mov edx, 8         ;8 bytes for filename
   int 80h 

   mov eax, 4
   mov ebx, 1
   mov ecx, writeMsg2
   mov edx, lenWriteMsg2
   int 80h 

   mov eax, 3
   mov ebx, 2
   mov ecx, writebuf
   mov edx, 1024         ;8 bytes for filename
   int 80h 

   mov  eax, 8
   mov  ebx, filename
   mov  ecx, 0777        ;read, write and execute by all
   int  0x80             ;call kernel
   
   mov [fd_out], eax

      ; write into the file
   mov   edx, len       ;number of bytes
   mov   ecx, writebuf         ;message to write
   mov   ebx, [fd_out]   ;file descriptor 
   mov   eax,4            ;system call number (sys_write)
   int   0x80             ;call kernel
   

   ; close the file
   mov eax, 6
   mov ebx, [fd_out]
    
   mov eax, 1
   mov ebx, 0
   int 80h 

_start:                ;User prompt
   mov eax, 4
   mov ebx, 1
   mov ecx, IntroMsg
   mov edx, lenIntroMsg
   int 80h


_start2:
   ;Read and store the user input
   mov eax, 3
   mov ebx, 2
   mov ecx, choice  
   mov edx, 8          ;5 bytes (numeric, 1 for sign) of that information
   int 80h
   
   mov eax ,0
   add eax,[choice]
   mov ebx,0
   mov ebx,[readinst]  ;eax contains the choice, ebx stores the intruction that has to be compared with eax ie. the input choice
   cmp ebx,eax ;Compare the registers and jump to read block if equal
   je _read

   mov eax ,0
   add eax,[choice]
   mov ebx,0
   mov ebx,[writeinst]  ;eax contains the choice, ebx stores the intruction that has to be compared with eax ie. the input choice
   cmp ebx,eax ;Compare the registers and jump to read block if equal
   je _write

   mov eax ,0
   add eax,[choice]
   mov ebx,0
   mov ebx,[editinst]  ;eax contains the choice, ebx stores the intruction that has to be compared with eax ie. the input choice
   cmp ebx,eax ;Compare the registers and jump to read block if equal
   je _write

   ;Show InvalidMsg if invalid Message is enterd
   mov eax, 4
   mov ebx, 1
   mov ecx, InvalidMsg
   mov edx, lenInvalidMsg
   int 80h 
   jmp _start2
   ;Output the message 'The entered number is: '
   ; Exit code
   mov eax, 1
   mov ebx, 0
   int 80h



;read:
