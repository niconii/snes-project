                bank noassume
reset:          clc                 ; switch to 65816 native mode
                xce
                jml   .fast         ; jump to bank $80 (fast ROM)

                ;       NVMXDIZC
.fast:          rep   #%11101011    ; set status flags
                sep   #%00010100

                ldx.b #$80          ; set data bank to $80
                phx
                plb
                bank $80

                ldx.b #$01          ; enable fast ROM in banks $80-$ff
                stx   MEMSEL
    
                lda.w #$1fff        ; set stack pointer to $1fff
                tcs

                lda.w #$2100        ; set direct page to $2100
                tcd
                dpbase $2100
                %a8()

                ;; Screen settings
                lda.b #$8f          ; turn off screen, max brightness
                sta   INIDISP

                ;; OBJ (sprite) settings
                stz   OBSEL         ; 8x8/16x16 sprites, no gap, base 0
                stz   OAMADDL       ; OAM addr 0
                stz   OAMADDH
                
                ;; Background settings
                stz   BGMODE        ; 8x8 px tiles, BG3 prio normal, mode 0
                stz   MOSAIC        ; size 1x1, mosaic off for all BGs
                stz   BG1SC         ; BGs screen addr 0, 32x32 tile screen
                stz   BG2SC
                stz   BG3SC
                stz   BG4SC
                stz   BG12NBA       ; all BGs tiles addr 0
                stz   BG34NBA

                stz   BG1HOFS       ; all BGs scroll offset (0, 0)
                stz   BG1HOFS
                stz   BG1VOFS
                stz   BG1VOFS
                stz   BG2HOFS
                stz   BG2HOFS
                stz   BG2VOFS
                stz   BG2VOFS
                stz   BG3HOFS
                stz   BG3HOFS
                stz   BG3VOFS
                stz   BG3VOFS
                stz   BG4HOFS
                stz   BG4HOFS
                stz   BG4VOFS
                stz   BG4VOFS

                ;; VRAM settings
                lda.b #$80          ; auto-inc, no translation, step by 1
                sta   VMAIN
                stz   VMADDL        ; VRAM addr 0
                stz   VMADDH

                ;; Mode 7 settings
                stz   M7SEL         ; wrap, no h/v flip
                lda.b #$01
                stz   M7A           ; a = 1.0
                sta   M7A
                stz   M7B           ; b = 0.0
                stz   M7B
                stz   M7C           ; c = 0.0
                stz   M7C
                stz   M7D           ; d = 1.0
                sta   M7D
                stz   M7X           ; x = 0.0
                stz   M7X
                stz   M7Y           ; y = 0.0
                stz   M7Y

                ;; CGRAM (palette) settings
                stz   CGADD         ; CGRAM addr 0

                ;; Window settings
                stz   W12SEL        ; disable windows
                stz   W34SEL
                stz   WOBJSEL
                stz   WH0           ; window 1 left  = 0
                stz   WH1           ; window 1 right = 0
                stz   WH2           ; window 2 left  = 0
                stz   WH3           ; window 2 right = 0
                stz   WBGLOG        ; windows OR together when overlapped
                stz   WOBJLOG

                ;; Main/sub screen settings
                stz   TM            ; all BGs/OBJs disabled on main and sub
                stz   TS
                stz   TMW           ; BGs/OBJs are not disabled by windows
                stz   TSW
                
                ;; Color math settings
                lda.b #$30          ; force main black off, color math off
                sta   CGWSEL        ; sub BG/OBJ disabled, no direct color
                stz   CGADSUB       ; addition, no divide, all BGs/OBJs off
                lda.b #$e0          ; set sub screen backdrop to black
                sta   COLDATA

                ;; PPU settings
                stz   SETINI        ; no ext sync, no extbg, no pseudo 512,
                                    ; 256x224, low v-res OBJs, no interlace

                ;; WRAM settings
                stz   WMADDL        ; WRAM addr 0
                stz   WMADDM
                stz   WMADDH

                %a16()              ; set direct page to $4200
                lda.w #$4200
                tcd
                dpbase $4200
                %a8()

                ;; Joypad settings
                stz   NMITIMEN      ; no NMI, no H/V IRQ, disable joypads
                lda.b #$ff          ; joypad IO pins floating
                sta   WRIO

                ;; Multiplier and divider inputs
                stz   WRMPYA        ; multiplicand = 0
                stz   WRMPYB        ; multiplier   = 0
                stz   WRDIVL        ; dividend     = 0
                stz   WRDIVH
                stz   WRDIVB        ; divisor      = 0

                ;; H/V counter settings
                stz   HTIMEL        ; h = 0
                stz   HTIMEH
                stz   VTIMEL        ; v = 0
                stz   VTIMEH

                ;; DMA settings
                stz   MDMAEN        ; disable all DMA channels
                stz   HDMAEN        ; disable all HDMA channels

                %a16()              ; set direct page to $4300
                lda.w #$4300
                tcd
                dpbase $4300
                %a8()

                lda.b #$00
                ldx.b #$00
                ldy.b #7
-               stz   DMAP0,x       ; A -> B, HDMA direct, increment A, [B]
                stz   BBAD0,x       ; B-bus addr = $2100
                stz   A1T0L,x       ; A-bus/HDMA table addr = $000000
                stz   A1T0H,x
                stz   A1B0,x
                stz   DAS0L,x       ; 64 KB DMA/indirect HDMA addr = $000000
                stz   DAS0H,x
                stz   DASB0,x
                stz   A2A0L,x       ; HDMA table current addr = $0000
                stz   A2A0H,x
                stz   NTRL0,x       ; HDMA line count = no repeat, 0 lines
                clc
                adc.b #$10
                tax
                dey
                bpl   -

                %a16()
                lda.w #zero         ; A-bus addr = zero
                sta   A1T0L
                ldx.b #bank(zero)
                stx   A1B0
                ldy.b #%00000001    ; DMA channel 0

                ;; Initialize OAM
                ldx.b #%00001010    ; A -> B, fixed, write to [B, B]
                stx   DMAP0
                ldx.b #OAMDATA      ; B-bus addr = OAMDATA
                stx   BBAD0
                lda.w #$0220        ; bytes to transfer = $220
                sta   DAS0L
                sty   MDMAEN        ; clear OAM

                ;; Initialize CGRAM
                ldx.b #CGDATA       ; B-bus addr = CGDATA
                stx   BBAD0
                lda.w #$0200        ; bytes to transfer = $200
                sta   DAS0L
                sty   MDMAEN        ; clear CGRAM

                ;; Initialize VRAM
                ldx.b #%00001001    ; A -> B, fixed, write to [B, B+1]
                stx   DMAP0
                ldx.b #VMDATAL      ; B-bus addr = VMDATAL
                stx   BBAD0
                sty   MDMAEN        ; clear VRAM

                ;; Initialize WRAM
                ldx.b #%00001000    ; A -> B, fixed, write to [B]
                stx   DMAP0
                ldx.b #WMDATA       ; B-bus addr = WMDATA
                stx   BBAD0
                sty   MDMAEN        ; clear WRAM $7e0000-$7effff
                sty   MDMAEN        ; clear WRAM $7f0000-$7fffff

                lda.w #$0000        ; set direct page to $0000
                tcd
                dpbase $0000

                ldx.b #$00
                ldy.b #$00
