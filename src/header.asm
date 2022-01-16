                ;      123456789012345678901
title           .text "TEST ROM             "

info
map_mode        .byte $30  ; lorom, fast
chipset         .byte $00  ; ROM
rom_size        .byte 5    ; 32 (1<<5) KB ROM
ram_size        .byte 0    ; no RAM
country_code    .byte $00  ; international
developer_code  .byte $00  ; none
version         .byte $00  ; 1.0
checksum        .word $ffff, $0000

vectors 
                .addr dummy_handler
                .addr dummy_handler
v_816_cop       .addr dummy_handler
v_816_brk       .addr dummy_handler
                .addr dummy_handler
v_816_nmi       .addr dummy_handler
                .addr dummy_handler
v_816_irq       .addr dummy_handler
                .addr dummy_handler
                .addr dummy_handler
v_02_cop        .addr dummy_handler
                .addr dummy_handler
                .addr dummy_handler
v_02_nmi        .addr dummy_handler
v_02_reset      .addr reset
v_02_irq_brk    .addr dummy_handler
