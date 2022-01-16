a8              .macro
                sep #$20
                .as
                .endmacro

a16             .macro
                rep #$20
                .al
                .endmacro

x8              .macro
                sep #$10
                .xs
                .endmacro

x16             .macro
                rep #$10
                .xl
                .endmacro
