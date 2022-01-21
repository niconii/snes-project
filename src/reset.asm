                .as
                .xs
reset           clc                 ; switch to 65816 native mode
                xce
                jml _fast           ; jump to bank $80 (fast ROM)

                ;     NVMXDIZC
_fast           rep #%11101011      ; set status flags
                sep #%00010100
                .al

                mvx #$01, zMEMSEL   ; enable fast ROM in banks $80-$ff

                ldx #$80
                phx
                plb
                .databank $80
    
                lda #$1fff          ; set stack pointer
                tcs

                lda #$2100          ; set direct page to $2100
                tcd
                .dpage $2100
                a8

                ;; Screen settings
                mva #$8f, zINIDISP  ; turn off screen, max brightness

                ;; OBJ (sprite) settings
                stz zOBSEL          ; 8x8/16x16 sprites, no gap, base 0
                stz zOAMADDL        ; OAM addr 0
                stz zOAMADDH
                
                ;; Background settings
                stz zBGMODE         ; 8x8 px tiles, BG3 prio normal, mode 0
                stz zMOSAIC         ; size 1x1, mosaic off for all BGs
                stz zBG1SC          ; BGs screen addr 0, 32x32 tile screen
                stz zBG2SC
                stz zBG3SC
                stz zBG4SC
                stz zBG12NBA        ; all BGs tiles addr 0
                stz zBG34NBA

                stz zBG1HOFS        ; all BGs scroll offset (0, 0)
                stz zBG1HOFS
                stz zBG1VOFS
                stz zBG1VOFS
                stz zBG2HOFS
                stz zBG2HOFS
                stz zBG2VOFS
                stz zBG2VOFS
                stz zBG3HOFS
                stz zBG3HOFS
                stz zBG3VOFS
                stz zBG3VOFS
                stz zBG4HOFS
                stz zBG4HOFS
                stz zBG4VOFS
                stz zBG4VOFS

                ;; VRAM settings
                mva #$80, zVMAIN    ; auto-inc, no translation, step by 1
                stz zVMADDL         ; VRAM addr 0
                stz zVMADDH

                ;; Mode 7 settings
                stz zM7SEL          ; wrap, no h/v flip
                lda #$01
                stz zM7A            ; a = 1.0
                sta zM7A
                stz zM7B            ; b = 0.0
                stz zM7B
                stz zM7C            ; c = 0.0
                stz zM7C
                stz zM7D            ; d = 1.0
                sta zM7D
                stz zM7X            ; x = 0.0
                stz zM7X
                stz zM7Y            ; y = 0.0
                stz zM7Y

                ;; CGRAM (palette) settings
                stz zCGADD          ; CGRAM addr 0

                ;; Window settings
                stz zW12SEL         ; disable windows
                stz zW34SEL
                stz zWOBJSEL
                stz zWH0            ; window 1 left  = 0
                stz zWH1            ; window 1 right = 0
                stz zWH2            ; window 2 left  = 0
                stz zWH3            ; window 2 right = 0
                stz zWBGLOG         ; windows OR together when overlapped
                stz zWOBJLOG

                ;; Main/sub screen settings
                stz zTM             ; all BGs/OBJs disabled on main and sub
                stz zTS
                stz zTMW            ; BGs/OBJs are not disabled by windows
                stz zTSW
                
                ;; Color math settings
                mva #$30, zCGWSEL   ; force main black off, color math off
                                    ; sub BG/OBJ disabled, no direct color
                stz zCGADSUB        ; addition, no divide, all BGs/OBJs off
                mva #$e0, zCOLDATA  ; set sub screen backdrop to black

                ;; PPU settings
                stz zSETINI         ; no ext sync, no extbg, no pseudo 512,
                                    ; 256x224, low v-res OBJs, no interlace

                ;; WRAM settings
                stz zWMADDL         ; WRAM addr 0
                stz zWMADDM
                stz zWMADDH

                a16                 ; set direct page to $4200
                lda #$4200
                tcd
                .dpage $4200
                a8

                ;; Joypad settings
                stz zNMITIMEN       ; no NMI, no H/V IRQ, disable joypads
                mva #$ff, zWRIO     ; joypad IO pins floating

                ;; Multiplier and divider inputs
                stz zWRMPYA         ; multiplicand = 0
                stz zWRMPYB         ; multiplier   = 0
                stz zWRDIVL         ; dividend     = 0
                stz zWRDIVH
                stz zWRDIVB         ; divisor      = 0

                ;; H/V counter settings
                stz zHTIMEL         ; h = 0
                stz zHTIMEH
                stz zVTIMEL         ; v = 0
                stz zVTIMEH

                ;; DMA settings
                stz zMDMAEN         ; disable all DMA channels
                stz zHDMAEN         ; disable all HDMA channels

                a16                 ; set direct page to $4300
                lda #$4300
                tcd
                .dpage $4300
                a8

                lda #$00
                ldx #$00
                ldy #7
-               stz zDMAP0,x        ; A -> B, HDMA direct, increment A, [B]
                stz zBBAD0,x        ; B-bus addr = $2100
                stz zA1T0L,x        ; A-bus/HDMA table addr = $000000
                stz zA1T0H,x
                stz zA1B0,x
                stz zDAS0L,x        ; 64 KB DMA/indirect HDMA addr = $000000
                stz zDAS0H,x
                stz zDASB0,x
                stz zA2A0L,x        ; HDMA table current addr = $0000
                stz zA2A0H,x
                stz zNTRL0,x        ; HDMA line count = no repeat, 0 lines
                stz zUNUSED0,x      ; clear unused byte
                clc
                adc #$10
                tax
                dey
                bpl -

                a16
                mva #<>zero,    zA1T0L  ; A-bus addr = zero
                mvx #`zero,     zA1B0
                ldy #%00000001          ; DMA channel 0

                ;; Initialize OAM
                mvx #%00001010, zDMAP0  ; A -> B, fixed, write to [B, B]
                mvx #<OAMDATA,  zBBAD0  ; B-bus addr = OAMDATA
                mva #$0220,     zDAS0L  ; bytes to transfer = $220
                sty MDMAEN              ; clear OAM

                ;; Initialize CGRAM
                mvx #<CGDATA,   zBBAD0  ; B-bus addr = CGDATA
                mva #$0200,     zDAS0L  ; bytes to transfer = $200
                sty MDMAEN              ; clear CGRAM

                ;; Initialize VRAM
                mvx #%00001001, zDMAP0  ; A -> B, fixed, write to [B, B+1]
                mvx #<VMDATAL,  zBBAD0  ; B-bus addr = VMDATAL
                sty MDMAEN              ; clear VRAM

                ;; Initialize WRAM
                mvx #%00001000, zDMAP0  ; A -> B, fixed, write to [B]
                mvx #<WMDATA,   zBBAD0  ; B-bus addr = WMDATA
                sty MDMAEN              ; clear WRAM $7e0000-$7effff
                sty MDMAEN              ; clear WRAM $7f0000-$7fffff

                lda #$0000              ; set direct page to $0000
                tcd
                .dpage $0000

                ldx #$00
                ldy #$00
