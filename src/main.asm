                .cpu "65816"
                .include "65816.inc"
                .include "snes.inc"
                .include "ram.inc"
                .lorom

                .org $808000
                .include "reset.asm"

                ldy #$0f
                sty ScrBrightness
                sty INIDISP

                ldy #$81
                sty NMITIMEN

main_loop       ; do processing here

                jsr vsync
                ldy #$8f            ; turn off screen for safety
                sty INIDISP

                lda StepCtL
                a8
                stz CGADD
                sta CGDATA
                xba
                sta CGDATA
                a16

                ldy ScrBrightness   ; turn screen back on
                sty INIDISP
                inc32 StepCtL
                jmp main_loop

vsync           ldy FrameCtL
_spin           wai
                cpy FrameCtL
                beq _spin
                rts

                .databank ?
                .dpage ?
vblank          rep #%11111011      ; clear all flags except interrupt
                .al
                phb                 ; set data bank to $00
                phk
                plb
                .databank $00
                inc32 FrameCtL
                plb
dummy_handler   rti                 ; interrupt handler that does nothing
zero            .byte $00           ; used to clear memory with DMAs

                .org $80ffc0
                .include "header.asm"
