draw_line:
    ;------------------------
    ; ステックフレームの構築
    ;------------------------
    push ebp
    mov ebp, esp

    push dword 0                    ;   -4|   sum = 0; // 相対軸の積算値
    push dword 0                    ;   -8|    x0 = 0; // X座標
    push dword 0                    ;  -12|    dx = 0; // X増分
    push dword 0                    ;  -16| inc_x = 0; // X座標増分(1 or -1)
    push dword 0                    ;  -20|    x0 = 0; // Y座標
    push dword 0                    ;  -24|    dx = 0; // Y増分
    push dword 0                    ;  -28| inc_x = 0; // Y座標増分(1 or -1)

    ;------------------------
    ; レジスタに保存
    ;------------------------
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ;-------------------------
    ; 幅を計算（x軸）
    ;-------------------------
    mov eax, [ebp + 8]              ; EAX = X0;
    mov ebx, [ebp + 16]             ; EBX = X1;
    sub ebx, eax                    ; EBX = X1 - X0; // 幅
    jge .10F                        ; if (幅 < 0)
                                    ; {
    neg ebx                         ;   幅 *= -1;
    mov esi, -1                     ;   // X座標の増分
    jmp .10E                        ; }
.10F:                               ; else
                                    ; {
    mov esi, 1                      ;   // X座標
.10E:                               ; }

    ;--------------------------
    ; 高さを計算（y軸）
    ;--------------------------
    mov ecx, [ebp + 12]             ; ECX = Y0
    mov edx, [ebp + 20]             ; EDX = Y1
    sub edx, ecx                    ; EDX = Y1 - Y0; // 高さ
    jge .20F                        ; if (高さ < 0)
                                    ; {
                                        