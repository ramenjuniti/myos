    BOOT_LOAD equ 0x7C00 ; ブートプログラムのロード位置

    ORG BOOT_LOAD ; ロードアドレスをアセンブラに指示

; マクロ
%include "../include/macro.s"

; エントリポイント
entry:
    ; BPB(BIOS Parameter Block)
    jmp ipl ; IPLへジャンプ
    times 90 - ($ - $$) db 0x90

    ; IPL
ipl:
    cli ; 割り込み禁止

    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BOOT_LOAD

    sti ; 割り込み許可

    mov [BOOT.DRIVE], dl ; ブートドライブを保存

    ; 文字列を表示
    cdecl puts, .s0 ; puts(.s0);

    ; 処理を終了
    jmp $ ; while (1); // 無限ループ

    ; データ
.s0 db "Booting...", 0x0A, 0x0D, 0

ALIGN 2, db 0
BOOT:
.DRIVE: dw 0

; モジュール
%include "../modules/real/puts.s"

; ブートフラグ（先頭512バイトの終了）
    times 510 - ($ - $$) db 0x00
    db 0x55, 0xAA