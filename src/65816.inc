                macro a8()
                sep   #$20
                endmacro

                macro a16()
                rep   #$20
                endmacro

                macro x8()
                sep   #$10
                endmacro

                macro x16()
                rep   #$10
                endmacro

                macro ax8()
                sep   #$30
                endmacro

                macro ax16()
                rep   #$30
                endmacro

                macro inc32(addr)
                inc   <addr>
                bne   +
                inc   <addr>+2
+
                endmacro
