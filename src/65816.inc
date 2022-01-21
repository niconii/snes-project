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

mva             .macro src, dst
                lda \src
                sta \dst
                .endmacro

mvx             .macro src, dst
                ldx \src
                stx \dst
                .endmacro

mvy             .macro src, dst
                ldy \src
                sty \dst
                .endmacro

inc32           .macro addr
                inc \addr
                bne +
                inc \addr+2
+
                .endmacro
