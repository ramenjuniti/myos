draw_str:
    ;---------------------------
    ; スタックフレーム構築
    ;---------------------------
    push ebp
    mov ebp, esp

    ;---------------------------
    ; レジスタの保存
    ;---------------------------
    push eax
    push ebx
    push ecx
    push edx
    push esi

    ;---------------------------
    ; 文字列を描画する
    ;---------------------------
    mov ecx, [ebp + 8]              ; ECX = 列;
    mov edx, [ebp + 12]             ; EDX = 行;
    movzx ebx, word [ebp + 16]      ; EBX = 表示色;
    mov esi, [ebp + 20]             ; ESI = 文字列へのアドレス;

    cld                             ; DF = 0; // アドレス加算
.10L:                               ; do
                                    ; {
    lodsb                           ;   AL = *ESI++; // 文字を取得
    cmp al, 0                       ;   if (0 == AL)
    je .10E                         ;       break;

%ifdef USE_SYSTEM_CALL
    int 0x81                            ; sys_call(1, X, Y, 色, 文字)
%else
    cdecl draw_char, ecx, edx, ebx, eax ; draw_char();
%endif

    inc ecx                         ;   ECX = 0; // 列を加算
    cmp ecx, 80                     ;   if (80 <= ECX) // 80文字以上?
    jl .12E                         ;   {
    mov ecx, 0                      ;       ECX = 0; // 列を初期化
    inc edx                         ;       EDX++; // 行を加算
    cmp edx, 30                     ;       if (30 <= EDX) // 30行以上?
    jl .12E                         ;       {
    mov edx, 0                      ;           EDX = 0; // 行を初期化
                                    ;       }
.12E:                               ;   }
    jmp .10L
.10E:                               ; } while (1);

    ;-----------------------------------------
    ; 【レジスタの復帰】
    ;-----------------------------------------
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