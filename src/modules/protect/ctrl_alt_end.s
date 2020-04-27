ctrl_alt_end:
        ;--------------------------------
        ; スタックフレームの構築
        ;--------------------------------
        push ebp
        mov ebp, esp

        ;--------------------------------
        ; キー状態保存
        ;--------------------------------
        mov eax, [ebp + 8]
        btr eax, 7
        jc .10F
        bts [.key_state], eax
        jmp .10E
.10F:
        btc [.key_state], eax
.10E:

        ;--------------------------------
        ; キー押下判定
        ;--------------------------------
        mov eax, 0x1D
        bt [.key_state], eax
        jnc .20E

        mov eax, 0x38
        bt [.key_state], eax
        jnc .20E

        mov eax, 0x38
        bt [.key_state], eax
        jnc .20E

        mov eax, 0x4F
        bt [.key_state], eax
        jnc .20E

        mov eax, -1

.20E:
        sar eax, 8

        ;----------------------------------
        ; スタックフレームの破棄
        ;----------------------------------
        mov esp, ebp
        pop ebp

        ret

.key_state: times 32 db 0