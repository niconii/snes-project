@asar 1.90
arch 65816
math round off
namespace nested on

                optimize address mirrors
                optimize dp always

                lorom
                incsrc "ram.inc"
                incsrc "65816.inc"
                incsrc "snes.inc"

                org $808000
                incsrc "reset.asm"
                incsrc "main.asm"
font:           incbin "../build/graphics/font.2bpp"
data_end:

                org $80ffc0
                incsrc "header.asm"
