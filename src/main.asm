main:           %dma_to_vram(0, font, datasize(font), $0000)

                ; ldy.b #$01
                sty   TM            ; enable BG1
                ldy.b #%00000100    ; map addr = $0400
                sty   BG1SC
                ldy.b #$00          ; tile addr = $0000
                sty   BG12NBA

                ; ldy.b #$00
                sty   CGADD
                ldy.b #rgb(6,20,27)
                sty   CGDATA
                ldy.b #rgb(6,20,27)>>8
                sty   CGDATA
                ldy.b #rgb(31,31,31)
                sty   CGDATA
                ldy.b #rgb(31,31,31)>>8
                sty   CGDATA

                lda.w #($0400+32*2+2)   ; BG1 map (2, 2)
                sta   VMADDL
                %a8()
                ldy.b #0
-               lda   hello_str,y
                beq   +
                sec
                sbc.b #32
                sta   VMDATAL
                stz   VMDATAH
                iny
                bra   -
+               %a16()

                ldy.b #$0f
                sty   ScrBrightness

                ldy.b #$81
                sty   NMITIMEN

main_loop:      ; do processing here

                jsr   vsync
                ldy.b #$8f          ; turn off screen for safety
                sty   INIDISP

                ; update screen here

                ldy   ScrBrightness ; turn screen back on
                sty   INIDISP
                %inc32(StepCtL)
                jmp   main_loop

vsync:          ldy   FrameCtL
.spin:          wai
                cpy   FrameCtL
                beq   .spin
                rts

                bank noassume
                optimize dp none
vblank:         rep   #%11111011    ; clear all flags except interrupt
                phb                 ; set data bank to $00
                phk
                plb
                bank $7e
                %inc32(FrameCtL)
                plb
dummy_handler:  rti                 ; interrupt handler that does nothing
                optimize dp always

zero:           db    $00           ; used to clear memory with DMAs

hello_str:      db    "HELLO, WORLD!",0
