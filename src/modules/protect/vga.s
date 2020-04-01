vga_set_read_plane:
        ;-----------------------------------------
        ; 【スタックフレームの構築】
        ;-----------------------------------------
        push ebp
        mov ebp, esp

        ;-----------------------------------------
        ; 【レジスタの保存】
        ;-----------------------------------------
        push eax
        push edx

        ;-----------------------------------------
        ; 読み込みプレーンの選択
        ;-----------------------------------------
        mov ah, [ebp + 8]
        and ah, 0x03
        mov al, 0x04
        mov dx, 0x03CE
        out dx, ax

        ;-----------------------------------------
        ; 【レジスタの復帰】
        ;-----------------------------------------
        pop edx
        pop eax

        ;-----------------------------------------
        ; 【スタックフレームの破棄】
        ;-----------------------------------------
        mov esp, ebp
        pop ebp

        ret

vga_set_write_plane:
        ;-----------------------------------------
        ; 【スタックフレームの構築】
        ;-----------------------------------------
        push ebp
        mov ebp, esp

        ;-----------------------------------------
        ; 【レジスタの保存】
        ;-----------------------------------------
        push eax
        push edx

        ;-----------------------------------------
        ; 書き込みプレーンの選択
        ;-----------------------------------------
        mov ah, [ebp + 8]
        and ah, 0x0F
        mov al, 0x02
        mov dx, 0x03C4
        out dx, ax

        ;-----------------------------------------
        ; 【レジスタの復帰】
        ;-----------------------------------------
        pop edx
        pop eax

        ;-----------------------------------------
        ; 【スタックフレームの破棄】
        ;-----------------------------------------
        mov esp, ebp
        pop ebp

        ret

vram_font_copy:
        ;-----------------------------------------
        ; 【スタックフレームの構築】
        ;-----------------------------------------
        push ebp
        mov ebp, esp

        ;-----------------------------------------
        ; 【レジスタの保存】
        ;-----------------------------------------
        push eax
        push ebx
        push ecx
        push edx
        push esi
        push edi

        ;-----------------------------------------
        ; マスクデータの作成
        ;-----------------------------------------
        mov esi, [ebp + 8]
        mov edi, [ebp + 12]
        movzx eax, byte [ebp + 16]
        movzx ebx, word [ebp + 20]

        test bh, al
        setz dh
        dec dh

        test bl, al
        setz dl
        dec dl

        ;-----------------------------------------
        ; 16ドットフォントのコピー
        ;-----------------------------------------
        cld

        mov ecx, 16
.10L:

        ;-----------------------------------------
        ; フォントマスクの作成
        ;-----------------------------------------
        lodsb
        mov ah, al
        not ah

        ;-----------------------------------------
        ; 前景色
        ;-----------------------------------------
        and al, dl

        ;-----------------------------------------
        ; 背景色
        ;-----------------------------------------
        test ebx, 0x0010
        jz .11F
        and ah, [edi]
        jmp .11E
.11F:
        and ah, dh
.11E:

        ;-----------------------------------------
        ; 前景色と背景色をコピー
        ;-----------------------------------------
        or al, ah

        ;-----------------------------------------
        ; 新しい値を出力
        ;-----------------------------------------
        mov [edi], al

        add edi, 80
        loop .10L
.10E:

        ;-----------------------------------------
        ; 【レジスタの復帰】
        ;-----------------------------------------
        pop edi
        pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax

        ;-----------------------------------------
        ; 【スタックフレームの破棄】
        ;-----------------------------------------
        mov esp, ebp
        pop ebp

        ret

vram_bit_copy:
        ;-----------------------------------------
        ; 【スタックフレームの構築】
        ;-----------------------------------------
        push ebp
        mov ebp, esp

        ;-----------------------------------------
        ; 【レジスタの保存】
        ;-----------------------------------------
        push eax
        push ebx
        push edi

        ;-----------------------------------------
        ; ビットのコピー
        ;-----------------------------------------
        mov edi, [ebp + 12]
        movzx eax, byte [ebp + 16]
        movzx ebx, word [ebp + 20]

        test bl, al
        setz bl
        dec bl

        ;-----------------------------------------
        ; 反転処理
        ;-----------------------------------------
        mov al, [ebp + 8]
        mov ah, al
        not ah

        ;-----------------------------------------
        ; 描画処理
        ;-----------------------------------------
        and ah, [edi]
        and al, bl
        or al, ah
        mov [edi], al

        ;-----------------------------------------
        ; 【レジスタの復帰】
        ;-----------------------------------------
        pop edi
        pop ebx
        pop eax

        ;-----------------------------------------
        ; 【スタックフレームの破棄】
        ;-----------------------------------------
        mov esp, ebp
        pop ebp

        ret