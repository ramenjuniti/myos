draw_rotation_bar:
        ;-----------------------------
        ; レジスタの保存
        ;-----------------------------
        push eax

        ;-----------------------------
        ; 周期動作
        ;-----------------------------
        mov eax, [TIMER_COUNT]
        shr eax, 4
        cmp eax, [.index]
        je .10E

        mov [.index], eax
        and eax, 0x03

        mov al, [.table + eax]
        cdecl draw_char, 0, 29, 0x000F, eax
.10E:

        ;-----------------------------
        ; レジスタの復帰
        ;-----------------------------
        pop eax

        ret

ALIGN 4, db 0
.index: dd 0
.table: db "|/-\"