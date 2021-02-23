;
; x86http.asm: a static file server written in assembly
;

;
; COMPILE-TIME CONSTANTS
;
sys_write equ 0x01
sys_exit equ 0x3C

;
; STRUCTS
;
struc sockaddr_in
  sin_family: resw 1
  sin_port:   resw 1
  sin_addr:   resd 1
  sin_zero:   resb 8
endstruc

;
; MEMORY INITIALIZATION
;
section .data
opt db 0x01

buffer times 1024 db 0
filename times 64 db 0
filepath times 128 db 0

msg_startup db "Listening on port 5123. Press Ctrl+C to stop.", 0xa, 0x0
msg_req db 0x1b, "[36mRequest: ", 0x1b, "[33m%s ", 0x0
msg_200 db 0x1b, "[32m(200)", 0x1b, "[0m", 0xa, 0x0
msg_404 db 0x1b, "[31m(404)", 0x1b, "[0m", 0xa, 0x0

err_generic db "Error"

http_req db "GET %s HTTP/1.1"
http_404 db "HTTP/1.1 404 Not Found", 0xd, 0xa, 0x0
http_200 db "HTTP/1.1 200 OK\r\nContent-Length: %li\r\nContent-Type: text/plain", 0xd, 0xa, 0xd, 0xa, 0x0

str_root db "/", 0x0
str_index db "index.html", 0x0
str_mode db "rb", 0x0

address:
  istruc sockaddr_in
    at sin_family, dw 2   ; AF_INET
    at sin_port,   dw 788 ; htons(5123)
    at sin_addr,   dd 0   ; INADDR_ANY
    at sin_zero,   db 0   ; Zero
  iend

segment .bss
response: resb 8
responselen: resb 4

;
; C STANDARD LIBRARY
;
section .text
extern socket
extern setsockopt
extern bind
extern listen
extern accept
extern read
extern send
extern shutdown

extern perror
extern printf
extern sprintf
extern sscanf

extern strcat
extern strcmp
extern strcpy
extern strlen

extern malloc
extern free

extern getcwd

extern fopen
extern fread
extern fseek
extern ftell
extern fclose

;
; ERROR HANDLER
;
fail:
  mov rdi, err_generic
  call perror
  mov rax, sys_exit
  mov rdi, 1
  syscall

;
; ENTRY POINT
;
global _start
_start:
  mov rdi, 2 ; AF_INET
  mov rsi, 1 ; SOCK_STREAM
  mov rdx, 0
  call socket
  mov r15, rax ; Server fd
  cmp rax, 0
  je  fail
  mov rdi, r15 ; Server fd
  mov rsi, 1   ; SOL_SOCKET
  mov rdx, 15  ; SO_REUSEADDR | SO_REUSEPORT
  mov rcx, opt ; Pointer to 1 (bring socket up)
  mov r8, 4    ; sizeof(int)
  call setsockopt
  cmp rax, 0
  jne fail
  mov rdi, r15
  mov rsi, address
  mov rdx, 16 ; sizeof(struct sockaddr_in)
  call bind
  cmp rax, 0
  jl fail

  mov rdi, msg_startup
  call printf

loop:
  mov rdi, r15
  mov rsi, 8 ; Backlog size
  cmp rdx, 0
  call listen
  jl fail

  mov rdi, r15
  mov rsi, 0x0 ; NULL
  mov rdx, 0x0 ; NULL
  call accept
  mov r14, rax ; New socket
  cmp rax, 0
  jl fail

  mov rdi, r14
  mov rsi, buffer
  mov rdx, 1024 ; Max bytes to read
  call read

  mov rdi, buffer
  mov rsi, http_req
  mov rdx, filename
  call sscanf

  mov rdi, filepath
  mov rsi, 128 ; sizeof(filepath)
  call getcwd

  mov rdi, filepath
  mov rsi, filename
  call strcat

  mov rdi, msg_req
  mov rsi, filename
  call printf

  mov rdi, filename
  mov rsi, str_root
  call strcmp
  cmp rax, 0
  je append_index

read_file:
  mov rdi, filepath
  mov rsi, str_mode
  call fopen
  mov r13, rax ; fp
  cmp r13, 0
  je error_404

  mov rdi, msg_200
  call printf

  mov rdi, r13
  mov rsi, 0   ; Offset
  mov rdx, 2   ; SEEK_END
  call fseek

  mov rdi, r13
  call ftell
  mov r12, rax ; Filesize

  mov rdi, r12
  add rdi, 128
  call malloc
  mov [response], rax

  mov rdi, r13
  mov rsi, 0   ; Offset
  mov rdx, 0   ; SEEK_SET
  call fseek

  mov rdi, [response]
  mov rsi, http_200
  mov rdx, r12
  call sprintf
  mov [responselen], rax
  add [responselen], r12

  mov rdi, [response]
  call strlen
  add rdi, rax
  mov rsi, r12
  mov rdx, 1   ; 1 set of [r12] bytes
  mov rcx, r13
  call fread
  mov rdi, r13
  call fclose

send_response:
  mov rdi, r14
  mov rsi, [response]
  mov rdx, [responselen]
  mov rcx, 0
  call send

  mov rdi, [response]
  call free

  mov rdi, r14
  mov rsi, 2  ; Shut down both sending and receiving
  call shutdown

  jmp loop
  ; Unreachable

;
; ROUTINES
;
append_index:
  mov rdi, filepath
  mov rsi, str_index
  call strcat
  jmp read_file

error_404:
  mov rdi, msg_404
  call printf

  mov rdi, 24 ; strlen(http_404)
  call malloc
  mov [response], rax

  mov rdi, [response]
  mov rsi, http_404
  call strcpy
  mov dword [responselen], 24
  jmp send_response
