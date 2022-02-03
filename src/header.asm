                namespace header
                ;   123456789012345678901
title:          db "TEST ROM             "
map_mode:       db $30  ; lorom, fast
chipset:        db $00  ; ROM
rom_size:       db 5    ; 32 (1<<5) KB ROM
ram_size:       db 0    ; no RAM
country:        db $00  ; international
developer:      db $00  ; none
version:        db $00  ; 1.0
checksum:       dw $ffff, $0000
                namespace off

                namespace vectors
                dw dummy_handler
                dw dummy_handler
cop_816:        dw dummy_handler
brk_816:        dw dummy_handler
                dw dummy_handler
nmi_816:        dw vblank
                dw dummy_handler
irq_816:        dw dummy_handler
                dw dummy_handler
                dw dummy_handler
cop_02:         dw dummy_handler
                dw dummy_handler
                dw dummy_handler
nmi_02:         dw dummy_handler
reset_02:       dw reset
irq_brk_02:     dw dummy_handler
                namespace off
