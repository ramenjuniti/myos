puts:
    ; スタックフレームの構築
    push bp
    mov bp, sp
    
    ; レジスタの保存
    push ax
    push bx
    push si

    ; 引数を取得
    mov si, [bp + 4] ; SI = 文字列へのアドレス

    ; 処理の開始
    mov ah, 0x0E    ; テレタイプ式1文字出力
    mov bx, 0x0000  ; ページ番号と文字色を0に設定
    cld             ; DF = 0; // アドレス加算
.10L:               ; do
                    ; {
    lodsb           ;   AL = *SI++;
                    ;
    cmp al, 0       ; if (0 == AL)
    je .10E         ;   break;
                    ;
    int 0x10        ; int 10(0x0E, AL); // 文字出力
    jmp .10L        ;
.10E:               ; } while (1);

    ; レジスタの復帰
    pop si
    pop bx
    pop ax

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret