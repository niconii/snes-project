                .cpu "65816"
                .include "65816.inc"
                .include "snes.inc"
                .include "ram.inc"
                .lorom

                .org $808000
                .include "reset.asm"
                .include "main.asm"
font            .binary "../build/graphics/font.2bpp"
font_size       = * - font

                .org $80ffc0
                .include "header.asm"
