acpi_package_value:
        ;------------------------
        ; スタックフレームの構築
        ;------------------------
        push ebp
        mov ebp, esp

        ;------------------------
        ; レジスタの保存
        ;------------------------
        push esi

        ;------------------------
        ; 引数を取得
        ;------------------------
        mov esi, [ebp + 8]

        ;------------------------
        ; パケットのヘッダをスキップ
        ;------------------------
        inc esi
        inc esi
        inc esi

        ;------------------------
        ; 2バイトのみを取得
        ;------------------------
        mov al, [esi]
        cmp al, 0x0B
        je .C0B
        cmp al, 0x0C
        je .C0C
        cmp al, 0x0E
        je .C0E
        jmp .C0A
.C0B:
.C0C:
.C0E:
        mov al, [esi + 1]
        mov ah, [esi + 2]
        jmp .10E

.C0A:
        cmp al, 0x0A
        jne .11E
        mov al, [esi + 1]
        inc esi
.11E:
        inc esi
        mov ah, [esi]
        cmp ah, 0x0A
        jne .12E
        mov ah, [esi + 1]
.12E:
.10E:

        ;------------------------
        ; レジスタの復帰
        ;------------------------
        pop esi

        ;------------------------
        ; スタックフレームの破棄
        ;------------------------
        mov esp, ebp
        pop ebp

        ret