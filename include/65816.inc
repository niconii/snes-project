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

ax8             .macro
                sep #$30
                .as
                .xs
                .endmacro

ax16            .macro
                rep #$30
                .al
                .xl
                .endmacro

inc32           .macro addr
                inc \addr
                bne +
                inc \addr+2
+
                .endmacro
