header          .block
                ;      123456789012345678901
title           .text "TEST ROM             "
map_mode        .byte $30  ; lorom, fast
chipset         .byte $00  ; ROM
rom_size        .byte 5    ; 32 (1<<5) KB ROM
ram_size        .byte 0    ; no RAM
country         .byte $00  ; international
developer       .byte $00  ; none
version         .byte $00  ; 1.0
checksum        .word $ffff, $0000
                .endblock

vectors         .block
                .addr dummy_handler
                .addr dummy_handler
cop_816         .addr dummy_handler
brk_816         .addr dummy_handler
                .addr dummy_handler
nmi_816         .addr vblank
                .addr dummy_handler
irq_816         .addr dummy_handler
                .addr dummy_handler
                .addr dummy_handler
cop_02          .addr dummy_handler
                .addr dummy_handler
                .addr dummy_handler
nmi_02          .addr dummy_handler
reset_02        .addr reset
irq_brk_02      .addr dummy_handler
                .endblock
