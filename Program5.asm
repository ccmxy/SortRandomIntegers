TITLE RandomArray   (Program5.asm)

; Name: Colleen Minor
;Email: minorc@onid.oregonstate.edu
; CS271-400 / Assignment 5                                           Date: 3/01/2015
; Description: Program introduces itself and accepts a user request bewteen [min = 10, max = 200] and
;generates that number of random integers [lo = 100... hi = 999], storing them in consecutive elements of an array.
;Then it displays a list of the integers before sorting, 10 numbers per line.
;Then it sorts the list in decending order (largest first).
;Then it calculates and displays the median value, rounded to the nearest integer.
;Then it displays the sorted list, 10 numbers per line.

INCLUDE Irvine32.inc
INCLUDE macros.inc

.data
min EQU 10
max EQU 200
lo EQU 100
hi EQU 899
request  DWORD ? ; Number of integers to fill the array
list DWORD max DUP(?) ; Array of integers

 intro1 BYTE "Welcome to The Random Integer Generator and Sorter by Colleen", 0
 intro2 BYTE "This program will display between 10 and 200 random numbers",0
 intro3 BYTE "in the range [100... 999].",0
 intro4 BYTE "Then it will display their median value,",0
 intro5 BYTE "and finally it will show you the numbers in decsending order.",0
 getdata1 BYTE "Enter the number of random numbers to display [10 .. 200]: ",0
 tooHigh1 BYTE "That request is too high! Try again", 0
 tooLow1 BYTE "That number is too low! Try again", 0
 unsorted1   BYTE "Unsorted List: ",0
 median1   BYTE  "The median is: ",0
 sorted1   BYTE "Sorted List: ",0

.code
main PROC
call introduction    ;introduce program

push OFFSET request   
call getData       

push OFFSET list
push request
call fillArray

mov edx, OFFSET unsorted1
call crlf
call writeString
call crlf

push OFFSET list
push request      
call displayList

push OFFSET list
push request
call sortList

push OFFSET list
push request      
call displayMedian


mov edx, OFFSET sorted1
call crlf
call writeString
call crlf
call displayList
exit

main ENDP
;-----------------------------------
;Procedure to introduce the program.
;receives: none
;returns: none
;preconditions:  none
;registers changed: edx
introduction    PROC
;-----------------------------------
    mov     edx,OFFSET intro1
    call    WriteString
    call    Crlf
    mov        edx,OFFSET intro2
    call    WriteString
    call    Crlf
  ;Display description
    mov        edx,OFFSET intro3
    call    WriteString
    call    Crlf
    mov        edx,OFFSET intro4
    call    WriteString
    call    Crlf
    mov        edx,OFFSET intro5
    call    WriteString
    call    Crlf
    call    Crlf
    ret      
introduction    ENDP

;-----------------------------------
;getData PROC                          
;Procedure to get the user request.
;receives: @requst
;returns: request (becomes user-input integer value)
;preconditions:  none
;registers changed: eax, ebx, edx
;-----------------------------------
getData PROC
    push ebp              
    mov ebp,esp          
L1:
    mov edx, OFFSET getData1
    call WriteString
;get an integer for "reqest"
    mov        ebx,[ebp+8]       
    call    ReadInt            
    mov        [ebx],eax       
;validate
    mov eax,[ebp+8]
    mov eax, [eax]
    cmp eax, max
    jg tooHigh
    cmp eax, min
    jl tooLow
    pop ebp  
    ret 8
tooHigh:
    pop request
    mov edx, OFFSET tooHigh1
    call WriteString
    call Crlf
    push OFFSET request
    jmp L1
tooLow:
    pop request
    mov edx, OFFSET tooLow1
    call WriteString
    call Crlf
    push OFFSET request
    jmp L1
getData ENDP


;-----------------------------------
; fillArray PROC                           
; Procedure to fill array of size 'request' with random integers
; citation: CS 271-400 / OSU / Winter 2015 / Lecture 20 
; receives: request, @theArray
; returns: the random array
; preconditions: Request is an integer between 10 and 200, inclusive.
; registers changed: eax, edx, ecx, edi
;-----------------------------------
fillArray PROC
    push    ebp              
    mov        ebp,esp      
    mov edi, [ebp + 12] ;@list in edi
    mov ecx, [ebp + 8] ;request number in ecx
more:
    mov eax, hi
    call randomRange ; generate random number between 0 and 899
    add eax, lo ;number between 100 and 999
    mov [edi],eax
    add edi, 4
loop more
    pop ebp
    ret
fillArray ENDP

;-----------------------------------
; sortList PROC                            
; Procedure that uses bubble sort to sort elements of 
; passed in array in ascending order. 
; Citation: Kip Irvine, "Assembly Language for  x86
; processors (7th edition)", Ch.9, pp. 374
; receives: @list, request
; returns: the sorted list 
; preconditions: list is filled with integers
; registers changed: eax, ecx, esi
;-----------------------------------
sortList PROC
    push ebp
    mov ebp, esp      
    mov ecx, [ebp + 8] ;request
    dec ecx
L1:
    push ecx ; store outer loop, create inner loop
    mov esi, [ebp + 12] ; point to first number in array

L2:
    mov eax, [esi] ; move element of array to eax
    cmp [esi + 4], eax ; compare eax element with next element
    jl L3 ;if [ESI] <= [ESI + 4], no exchange
    xchg eax, [esi + 4]
    mov [esi], eax
L3:
    add esi, 4
    loop L2

    pop ecx
    loop L1
    pop ebp
    ret
sortList ENDP


;-----------------------------------
; displayMedian PROC                      
; Procedure to display the median of an array of integers
; receives: @list, request
; returns: None
; preconditions: list is filled with ordered integers
; registers changed: eax, ebx, edx, esi
;-----------------------------------
displayMedian PROC
    push ebp 
    mov ebp,esp
    sub esp, 12   
    mov edx, OFFSET median1  
    call WriteString
    call Crlf

    mov eax, [ebp + 12]
    mov DWORD PTR [ebp - 12], eax; ebp - 12 = @list
    mov edx, 0
    mov ebx, 2
    mov eax, [ebp + 8] ;request
    div ebx
    mov DWORD PTR [ebp - 8], eax ;lower median = 6
    cmp edx, 1
    je oddLoop ; remainder of 1-- add 1 to midNum
    jl evenLoop ; no remainder-- find the avg
oddLoop:
    mov eax, DWORD PTR [ebp - 8]
    mov ebx, 4
    mul ebx       
    add DWORD PTR [ebp - 12], eax
    mov eax, DWORD PTR [ebp - 12]
    mov eax, [eax]
    call WriteDec
    call Crlf
    jmp exitLoop
evenLoop:
    mov eax, DWORD PTR [ebp - 8]
    mov ebx, 4
    mul ebx       
    add DWORD PTR [ebp - 12], eax;  DWORD PTR [ebp - 12] = @EAX
    mov eax, DWORD PTR [ebp - 12]
    mov eax, [eax]
    mov DWORD PTR [ebp - 4], eax ;[OTHER NUM]
    mov eax, [ebp + 12]
    mov DWORD PTR [ebp - 12], eax; ebp - 12 = @list
    mov edx, 0
    mov ebx, 2
    mov eax, [ebp + 8] ;request
    div ebx
    DEC eax    ;ready for next number
    mov ebx, 4
    mul ebx
    add DWORD PTR [ebp - 12], eax;  DWORD PTR [ebp - 12] = @EAX
    mov eax, DWORD PTR [ebp - 12]
    mov eax, [eax]
    mov DWORD PTR [ebp - 8], eax ;[ONE NUM]
    mov eax, DWORD PTR [ebp - 8]
    add eax, DWORD PTR [ebp - 4]
    mov ebx, 2
    div ebx
    call WriteDec
    call Crlf
    jmp exitLoop
exitLoop:
    mov esp, ebp    ;remove locals from stack
    pop ebp
    ret
displayMedian ENDP

;-----------------------------------
; displayList PROC                        
; Procedure to display the integers on "list" into console window
; receives: @array, request 
; returns: none
; preconditions: list is an array of integers
; registers changed: eax, ebx, ecx, edx, esi
;-----------------------------------
displayList PROC
    push ebp                
    mov ebp,esp            
    sub esp, 4    
    mov esi, [ebp + 12]
    mov ebx, [ebp + 8] 
    mov DWORD PTR [ebp - 4], 0
    mov ecx, 0
L0:
    cmp ecx, ebx
    je L2
    mov eax, [esi]
    call writeDec
    mWriteSpace
    add esi, 4
    inc ecx
    inc DWORD PTR [ebp - 4]
    cmp DWORD PTR [ebp - 4], 10
    je L1
    jmp L0
L1:
    mov DWORD PTR [ebp - 4], 0
    call Crlf
    jmp L0
L2:
    call Crlf
    mov esp, ebp    ;remove locals from stack
    pop ebp
    ret
displayList ENDP

END main