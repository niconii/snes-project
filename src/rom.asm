                .cpu "65816"
                .include "65816.inc"
                .include "snes.inc"
                .include "ram.inc"
                .lorom

                .org $808000
                .include "reset.asm"
                .include "main.asm"

                .org $80ffc0
                .include "header.asm"