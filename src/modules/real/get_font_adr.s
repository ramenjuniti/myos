get_font_adr:
    ; スタックフレームの構築
                        ; -------+---------------------
                        ;    + 4 | フォントアドレス格納位置
                        ;    + 2 | IP
    push bp             ; BP + 0 | BP
    mov bp, sp          ; -------+---------------------

    ; レジスタの保存
    push ax
    push bx
    push si
    push es
    push bp

    ; 引数を取得
    mov si, [bp + 4]    ; dst = FONTアドレスの保存先;

    ; フォントアドレスの取得
    mov ax, 0x1130      ; //フォントアドレスの取得
    mov bh, 0x06        ; 8x16 font(vga/mcga)
    int 10h             ; ES:BP=FONT ADDRESS

    ; FONTアドレスを保存
    mov [si + 0], es    ; dst[0] = セグメンt;
    mov [si + 2], bp    ; dst[1] = オフセット;

    ; レジスタの復帰
    pop bp
    pop es
    pop si
    pop bx
    pop ax

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret