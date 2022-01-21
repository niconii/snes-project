main            dma_to_vram 0, font, font_size, $0000

                ; ldy #$01
                sty TM                  ; enable BG1
                mvy #%00000100, BG1SC   ; map addr = $0400
                mvy #$00,       BG12NBA ; tile addr = $0000

                sty CGADD
                mvy #<rgb( 6,20,27), CGDATA
                mvy #>rgb( 6,20,27), CGDATA
                mvy #<rgb(31,31,31), CGDATA
                mvy #>rgb(31,31,31), CGDATA

                mva #($0400+32*2+2), VMADDL ; BG1 map (2, 2)
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

                mvy #$0f, ScrBrightness
                mvy #$81, NMITIMEN

main_loop       ; do processing here

                jsr vsync
                mvy #$8f, INIDISP

                ; update screen here

                mvy ScrBrightness, INIDISP
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
