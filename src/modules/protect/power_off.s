power_off:
        ;--------------------------------
        ; レジスタの保存
        ;--------------------------------
        push eax
        push ebx
        push ecx
        push edx
        push esi

        ;--------------------------------
        ; ページングを無効化
        ;--------------------------------
        mov eax, cr0
        and eax, 0x7FFF_FFFF
        mov cr0, eax
        jmp $ + 2

        ;--------------------------------
        ; ACPIデータの確認
        ;--------------------------------
        mov eax, [0x7C00 + 512 + 4]
        mov ebx, [0x7C00 + 512 + 8]
        cmp eax, 0
        je .10E

        ;--------------------------------
        ; RSDTテーブルの検索
        ;--------------------------------
        cdecl acpi_find, eax, ebx, 'RSDT'
        cmp eax, 0
        je .10E

        ;--------------------------------
        ; FACPテーブルの検索
        ;--------------------------------
        cdecl find_rsdt_entry, eax, 'FACP'
        cmp eax, 0
        je .10E

        mov ebx, [eax + 40]
        cmp ebx, 0
        je .10E

        ;--------------------------------
        ; ACPIレジスタの保存
        ;--------------------------------
        mov ecx, [eax + 64]
        mov [PM1a_CNT_BLK], ecx

        mov ecx, [eax + 68]
        mov [PM1b_CNT_BLK], ecx


        ;--------------------------------
        ; S5名前空間の検索
        ;--------------------------------
        mov ecx, [ebx + 4]
        sub ecx, 36
        add ebx, 36
        cdecl acpi_find, ebx, ecx, '_S5_'
        cmp eax, 0
        je .10E

        ;--------------------------------
        ; パッケージデータの取得
        ;--------------------------------
        add eax, 4
        cdecl acpi_package_value, eax
        mov [S5_PACKAGE], eax

.10E:

        ;--------------------------------
        ; ページングを有効化
        ;--------------------------------
        mov eax, cr0
        or eax, (1 << 3)
        mov cr0, eax
        jmp $ + 2

        ;--------------------------------
        ; ACPIレジスタの取得
        ;--------------------------------
        mov edx, [PM1a_CNT_BLK]
        cmp edx, 0
        je .20E

        ;--------------------------------
        ; カウントダウンの表示
        ;--------------------------------
        cdecl draw_str, 38, 14, 0x020F, .s3
        cdecl wait_tick, 100
        cdecl draw_str, 38, 14, 0x020F, .s2
        cdecl wait_tick, 100
        cdecl draw_str, 38, 14, 0x020F, .s1
        cdecl wait_tick, 100

        ;-------------------------------
        ; PM1a_CNT_BLKの設定
        ;-------------------------------
        movzx ax, [S5_PACKAGE]
        shl ax, 10
        or ax, 1 << 13
        out dx, ax

        ;-------------------------------
        ; PM1b_CNT_BLKの確認
        ;-------------------------------
        mov edx, [PM1b_CNT_BLK]
        cmp edx, 0
        je .20E

        ;-------------------------------
        ; PM1b_CNT_BLKの設定
        ;-------------------------------
        movzx ax, [S5_PACKAGE]
        shl ax, 10
        or ax, 1 << 13
        out dx, ax

.20E:

        ;-------------------------------
        ; 電断待ち
        ;-------------------------------
        cdecl wait_tick, 100

        ;-------------------------------
        ; 電断失敗メッセージ
        ;-------------------------------
        cdecl draw_str, 38, 14, 0x020F, .s4

        ;-------------------------------
        ; レジスタの復帰
        ;-------------------------------
        pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax

        ret

.s0:    db " Power off...   ", 0
.s1:    db " 1", 0
.s2:    db " 2", 0
.s3:    db " 3", 0
.s4:    db "NG", 0

ALIGN 4, db 0
PM1a_CNT_BLK: dd 0
PM1b_CNT_BLK: dd 0
S5_PACKAGE:
.0:     db 0
.1:     db 0
.2:     db 0
.3:     db 0