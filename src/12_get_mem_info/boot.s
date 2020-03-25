;********************************************
; マクロ
;********************************************
%include "../include/define.s"
%include "../include/macro.s"

    ORG BOOT_LOAD                       ; ロードアドレスをアセンブラに指示

;********************************************
; エントリポイント
;********************************************
entry:
    ;---------------------------
    ; BPB(BIOS Parameter Block)
    ;---------------------------
    jmp ipl ; IPLへジャンプ
    times 90 - ($ - $$) db 0x90

    ;---------------------------
    ;IPL
    ;---------------------------
ipl:
    cli ; 割り込み禁止

    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BOOT_LOAD

    sti ; 割り込み許可

    ;---------------------------
    ; ブートドライブ番号を保存
    ;---------------------------
    mov [BOOT + drive.no], dl           ; ブートドライブを保存

    ;---------------------------
    ; 文字列を表示
    ;---------------------------
    cdecl puts, .s0 ; puts(.s0);

    ;---------------------------
    ; 残りのセクタを全て読み込む
    ;---------------------------
    mov bx, BOOT_SECT - 1               ; BX = 残りのブートセクタ数;
    mov cx, BOOT_LOAD + SECT_SIZE       ; CX = 次のロードアドレス;

    cdecl read_chs, BOOT, bx, cx        ; AX = read_chs(BOOT, BX, CX);

    cmp ax, bx                          ; if (AX != 残りのセクタ数)
.10Q: jz .10E                           ; {
.10T: cdecl puts, .e0                   ;   puts(.e0);
    call reboot                         ;   reboot(); 
.10E:                                   ; }

    ;---------------------------
    ; 次のステージへ移行
    ;---------------------------
    jmp stage_2                         ; ブート処理の第2ステージ

    ;---------------------------
    ; データ
    ;---------------------------
.s0 db "Booting...", 0x0A, 0x0D, 0
.e0 db "Error:sector read", 0

;********************************************
; ブートドライブに関する情報
;********************************************
ALIGN 2, db 0
BOOT:                                   ; ブートドライブに関する情報
    istruc drive            
        at drive.no, dw 0               ; ドライブ
        at drive.cyln, dw 0             ; C:シリンダ
        at drive.head, dw 0             ; H:ヘッド
        at drive.sect, dw 2             ; S:セクタ
    iend

;********************************************
; モジュール
;********************************************
%include "../modules/real/puts.s"
%include "../modules/real/reboot.s"
%include "../modules/real/read_chs.s"

;********************************************
; ブートフラグ（先頭512バイトの終了）
;********************************************
    times 510 - ($ - $$) db 0x00
    db 0x55, 0xAA

;********************************************
; リアルモード時に取得した情報
;********************************************
FONT:
.seg: dw 0
.off: dw 0
ACPI_DATA:
.adr: dd 0
.len: dd 0

;********************************************
; モジュール（先頭512バイト以降に配置)
;********************************************
%include "../modules/real/itoa.s"
%include "../modules/real/get_drive_param.s"
%include "../modules/real/get_font_adr.s"
%include "../modules/real/get_mem_info.s"

;********************************************
; ブート処理の第2ステージ
;********************************************
stage_2:
    ;---------------------------
    ; 文字列を表示
    ;---------------------------
    cdecl puts, .s0

    ;---------------------------
    ; ドライブ情報を取得
    ;---------------------------
    cdecl get_drive_param, BOOT         ; get_drive_param(DX, BOOT.CYLN);
    cmp ax, 0                           ; if (0 == AX)
.10Q: jne .10E                          ; {
.10T: cdecl puts, .e0                   ;   puts(.e0);
    call reboot                         ;   reboot; //再起動
.10E:                                   ; }

    ;---------------------------
    ; ドライブ情報を表示
    ;---------------------------
    mov ax, [BOOT + drive.no]           ; AX = ブートドライブ;
    cdecl itoa, ax, .p1, 2, 16, 0b0100  ;
    mov ax, [BOOT + drive.cyln]         ;
    cdecl itoa, ax, .p2, 4, 16, 0b0100  ;
    mov ax, [BOOT + drive.head]         ; AX = ヘッド数;
    cdecl itoa, ax, .p3, 2, 16, 0b0100  ;
    mov ax, [BOOT + drive.sect]         ; AX = トラックあたりのセクタ数;
    cdecl itoa, ax, .p4, 2, 16, 0b0100  ;
    cdecl puts, .s1
    
    ;---------------------------
    ; 次のステージへ移行
    ;---------------------------
    jmp stage_3rd

    ;---------------------------
    ; データ
    ;---------------------------
.s0 db "2nd stage...", 0x0A, 0x0D, 0
.s1 db " Drive:0x"
.p1 db "  , C:0x"
.p2 db "    , H:0x"
.p3 db "  , S:0x"
.p4 db "  ", 0x0A, 0x0D, 0
.e0 db "Can't get drive parameter.", 0

;********************************************
; ブート処理の第３ステージ
;********************************************
stage_3rd:
    ;--------------------------
    ; 文字列を表示
    ;--------------------------
    cdecl puts, .s0

    ;--------------------------
    ; プロテクトモードで使用するフォントは
    ; BIOSに内臓されたものを流用する
    ;--------------------------
    cdecl get_font_adr, FONT            ;// BIOSのフォント

    ;--------------------------
    ; フォントアドレスの表示
    ;--------------------------
    cdecl itoa, word [FONT.seg], .p1, 4, 16, 0b0100
    cdecl itoa, word [FONT.off], .p2, 4, 16, 0b0100
    cdecl puts, .s1

    ;--------------------------
    ; メモリ情報の取得と表示
    ;--------------------------
    cdecl get_mem_info                  ; get_mem_info();

    mov eax, [ACPI_DATA.adr]            ; EAX = ACPI_DATA.adr;
    cmp eax, 0                          ; if (EAX)
    je .10E                             ; {

    cdecl itoa, ax, .p4, 4, 16, 0b0100  ;   itoa(AX); // 下位アドレスを変換
    shr eax, 0                          ;   EAX >>= 16;
    cdecl itoa, ax, .p3, 4, 16, 0b0100  ;   itoa(AX); // 上位アドレスを変換

    cdecl puts, .s2                     ;   puts(.s2); // アドレスを表示
.10E:                                   ; }

    ;--------------------------
    ; 処理の終了
    ;--------------------------
    jmp $

    ;--------------------------
    ; データ
    ;--------------------------
.s0 db "3rd stage...", 0x0A, 0x0D, 0

.s1 db "Font Address="
.p1 db "ZZZZ"
.p2 db "ZZZZ", 0x0A, 0x0D, 0
    db 0x0A, 0x0D, 0

.s2 db "ACPI data="
.p3 db "ZZZZ"
.p4 db "ZZZZ", 0x0A, 0x0D, 0

.e0 db "Cannot get drive parameter.", 0

;********************************************
; バディング（このファイルは8Kバイトとする)
;********************************************
    times BOOT_SIZE - ($ - $$) db 0 ; バディング