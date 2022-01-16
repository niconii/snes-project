                .cpu "65816"
                .include "../include/65816.inc"
                .include "../include/snes.inc"
                .lorom

                .org $808000
                .include "reset.asm"

                lda #rgb(0,0,31)    ; set color 0 to blue
                a8
                stz CGADD
                sta CGDATA
                xba
                sta CGDATA

                lda #$0f            ; turn on screen
                sta INIDISP

forever         wai                 ; loop forever
                bra forever

dummy_handler   rti                 ; interrupt handler that does nothing
zero            .byte $00           ; used to clear memory with DMAs

                .org $80ffc0
                .include "header.asm"
