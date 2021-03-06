acpi_find:
        ;-----------------------------
        ; スタックフレームの構築
        ;-----------------------------
        push ebp
        mov ebp, esp

        ;-----------------------------
        ; レジスタの保存
        ;-----------------------------
        push eax
        push ecx
        push edi

        ;-----------------------------
        ; 引数を取得
        ;-----------------------------
        mov edi, [ebp + 8]
        mov ecx, [ebp + 12]
        mov eax, [ebp + 16]

        ;-----------------------------
        ; 名前の検索
        ;-----------------------------
        cld
.10L:
        repne scasb

        cmp ecx, 0
        jnz .11E
        mov eax, 0
        jmp .10E
.11E:

        cmp eax, [es:edi - 1]
        jne .10L

        dec edi
        mov eax, edi
.10E:

        ;------------------------------
        ; レジスタの復帰
        ;------------------------------
        pop edi
        pop ecx
        pop ebx

        ;-----------------------------
        ; スタックフレームの破棄
        ;-----------------------------
        mov esp, ebp
        pop ebp

        ret