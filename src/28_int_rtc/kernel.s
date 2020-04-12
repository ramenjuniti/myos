;***********************************************************
;  マクロ
;***********************************************************
%include "../include/define.s"
%include "../include/macro.s"

        ORG KERNEL_LOAD

[BITS 32]
;***********************************************************
;  エントリポイント
;***********************************************************
kernel:
        ;------------------------------------------
        ; フォントアドレスを取得
        ;------------------------------------------
        mov esi, BOOT_LOAD + SECT_SIZE
        movzx eax, word[esi + 0]
        movzx ebx, word[esi + 2]
        shl eax, 4
        add eax, ebx
        mov [FONT_ADR], eax

        ;------------------------------------------
        ; 初期化
        ;------------------------------------------
        cdecl init_int                                  ; // 割り込みベクタの初期化
        cdecl init_pic                                  ; // 割り込みコントローラの初期化

        set_vect 0x00, int_zero_div                     ; // 割り込み処理の登録: 0徐算
        set_vect 0x28, int_rtc                          ; // 割り込み処理の登録: RTC

        ;------------------------------------------
        ; デバイスの割り込み許可
        ;------------------------------------------
        cdecl rtc_int_en, 0x10                         ; rtc_int_en(UIE); // 更新サイクル終了割り込み許可

        ;------------------------------------------
        ; IMR(割り込みマスクレジスタ)の設定
        ;------------------------------------------
        outp 0x21, 0b1111_1011                          ; // 割り込み有効: スレーブPIC
        outp 0xA1, 0b1111_1110                          ; // 割り込み有効: RTC

        ;------------------------------------------
        ; CPUの割り込み許可
        ;------------------------------------------
        sti                                             ; // 割り込み許可

        ;------------------------------------------
        ; フォントの一覧表示
        ;------------------------------------------
        cdecl draw_font, 63, 13
        cdecl draw_color_bar, 63, 4

        ;------------------------------------------
        ; 文字列を描画
        ;------------------------------------------
        cdecl draw_str, 25, 14, 0x010F, .s0

        ;------------------------------------------
        ; 時刻の表示
        ;------------------------------------------
.10L:
        mov eax, [RTC_TIME]
        cdecl draw_time, 72, 0, 0x0700, eax
        jmp .10L

        ;------------------------------------------
        ; 処理の終了
        ;------------------------------------------
        jmp $

.s0:    db " Hello, kernel! ", 0

ALIGN 4, db 0
FONT_ADR: dd 0
RTC_TIME: dd 0

;***********************************************************
;  モジュール
;***********************************************************
%include "../modules/protect/vga.s"
%include "../modules/protect/draw_char.s"
%include "../modules/protect/draw_font.s"
%include "../modules/protect/draw_str.s"
%include "../modules/protect/draw_color_bar.s"
%include "../modules/protect/draw_pixel.s"
%include "../modules/protect/draw_line.s"
%include "../modules/protect/draw_rect.s"
%include "../modules/protect/itoa.s"
%include "../modules/protect/rtc.s"
%include "../modules/protect/draw_time.s"
%include "../modules/protect/interrupt.s"
%include "../modules/protect/pic.s"
%include "../modules/protect/int_rtc.s"

;***********************************************************
;  パディング
;***********************************************************
        times KERNEL_SIZE - ($ - $$) db 0