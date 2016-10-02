org 0x7c00

section .data

%define string_constant(name, content) name db content, 13, 10, 0 ; Used to add a newline at the end of a string.

string_constant(hello_world_msg, 'Hello, world !')
string_constant(a20_accessible_msg, 'A20 line is accessible ! :)')
string_constant(a20_inaccessible_msg, 'A20 line is inaccessible ! :(')

section .text

MEMORY_WRAP_SEGMENT equ 0xFFFF
MEMORY_WRAP_BYTE equ 0x10

main:
    mov sp, 0x600

    push hello_world_msg
    call print_string
    add sp, 2

    call check_a20
    call disable_a20
    call check_a20
    call enable_a20
    call check_a20

    jmp exit


check_a20:
    ; Check if the A20 controller is alowing addresses of more than 20 bit or not.
    ; Prints a message describing whether it is open or not.
    mov dx, MEMORY_WRAP_SEGMENT
    mov es, dx

    ; We save the value at memory address 0, and store a different value in cl.
    mov al, [0]
    mov cl, al
    not cl
    
    ; We temporarily change the value at the 1M address (the wrap address), 
    ; and save the value at the 0 address to bl.
    mov dl, [es:MEMORY_WRAP_BYTE]
    mov [es:MEMORY_WRAP_BYTE], cl
    mov bl, [0]
    mov [es:MEMORY_WRAP_BYTE], dl

    ; If the value in the 0 address is different when we changed the value at the wrap address, 
    ; it means we have a warp. If the values are the same we don't have a wrap.
    cmp al, bl
    jne a20_inaccessible

a20_accessible:
    push a20_accessible_msg
    jmp print_a20_accessibility_msg

a20_inaccessible:
    push a20_inaccessible_msg

print_a20_accessibility_msg:
    call print_string
    add sp, 2
    ret


enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret


disable_a20:
    in al, 0x92
    and al, 0xFD
    out 0x92, al
    ret


print_string:
    ; Gets a pointer to a string (pushed to the stack), and prints it.
    ; Terminates on the first 0 byte in the string.
    mov si, [esp + 2]

    mov ah, 0x0E
    mov cx, 0x01
    xor bx, bx

    print_char:
        mov al, [si]

        cmp al, 0
        je finish_printing

        int 0x10
        inc si
        jmp print_char

finish_printing:
    ret

exit:
    nop
