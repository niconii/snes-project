main            stz VMADDL          ; copy font to vram
                ldy #%00000001
                sty DMAP0
                ldy #<VMDATAL
                sty BBAD0
                lda #<>font
                sta A1T0L
                ldy #`font
                sty A1B0
                lda #font_size
                sta DAS0L
                ldy #(1 << 0)
                sty MDMAEN

                ; ldy #$01
                sty TM              ; enable BG1
                ldy #%00000100      ; map addr = $0400
                sty BG1SC
                ldy #$00            ; tile addr = $0000
                sty BG12NBA

                ; ldy #$00
                sty CGADD
                ldy #<rgb( 6,20,27)
                sty CGDATA
                ldy #>rgb( 6,20,27)
                sty CGDATA
                ldy #<rgb(31,31,31)
                sty CGDATA
                ldy #>rgb(31,31,31)
                sty CGDATA

                lda #($0400 + 32*2 + 2) ; BG1 map (2, 2)
                sta VMADDL
                a8
                ldy #0
-               lda hello_str,y
                beq +
                sec
                sbc #32
                sta VMDATAL
                stz VMDATAH
                iny
                bra -
+               a16

                ldy #$0f
                sty ScrBrightness

                ldy #$81
                sty NMITIMEN

main_loop       ; do processing here

                jsr vsync
                ldy #$8f            ; turn off screen for safety
                sty INIDISP

                ; update screen here

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

hello_str       .null "HELLO, WORLD!"
