find_rsdt_entry:
        ;--------------------------
        ; スタックフレームの構築
        ;--------------------------
        push ebp
        mov ebp, esp

        ;--------------------------
        ; レジスタの保存
        ;--------------------------
        push ebx
        push ecx
        push esi
        push edi

        ;--------------------------
        ; 引数の所得
        ;--------------------------
        mov esi, [ebp + 8]
        mov ecx, [ebp + 12]

        mov ebx, 0

        ;--------------------------
        ; ACPIテーブル検索処理
        ;--------------------------
        mov edi, esi
        add edi, [esi + 4]
        add esi, 36
.10L:
        cmp esi, edi
        jge .10E

        lodsd

        cmp [eax], ecx
        jne .12E
        mov ebx, eax
        jmp .10E
.12E:   jmp .10L
.10E:

        mov eax, ebx

        ;--------------------------
        ; レジスタの復帰
        ;--------------------------
        pop edi
        pop esi
        pop ecx
        pop ebx

        ;--------------------------
        ; スタックフレームの破棄
        ;--------------------------
        mov esp, ebp
        pop ebp

        ret