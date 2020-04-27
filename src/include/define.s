BOOT_SIZE           equ (1024 * 8)                      ; ブートコードサイズ
KERNEL_SIZE         equ (1024 * 8)                      ; カーネルサイズ

BOOT_LOAD           equ 0x7C00                          ; ブートプログラムのロード位置
BOOT_END            equ (BOOT_LOAD + BOOT_SIZE)

SECT_SIZE           equ (512)                           ; セクタサイズ

BOOT_SECT           equ (BOOT_SIZE / SECT_SIZE)         ; ブートプログラムのセクタ数
KERNEL_SECT         equ (KERNEL_SIZE / SECT_SIZE)

E820_RECORD_SIZE    equ 20

KERNEL_LOAD         equ 0x0010_1000

VECT_BASE           equ 0x0010_0000

STACK_BASE          equ 0x0010_3000                     ; タスク用スタックエリア
STACK_SIZE          equ 1024                            ; スタックサイズ

SP_TASK_0           equ STACK_BASE + (STACK_SIZE * 1)
SP_TASK_1           equ STACK_BASE + (STACK_SIZE * 2)
SP_TASK_2           equ STACK_BASE + (STACK_SIZE * 3)
SP_TASK_3           equ STACK_BASE + (STACK_SIZE * 4)
SP_TASK_4           equ STACK_BASE + (STACK_SIZE * 5)
SP_TASK_5           equ STACK_BASE + (STACK_SIZE * 6)
SP_TASK_6           equ STACK_BASE + (STACK_SIZE * 7)

CR3_BASE            equ 0x0010_5000                     ; ページ変換テーブル：タスク３用

PARAM_TASK_4        equ 0x0010_8000
PARAM_TASK_5        equ 0x0010_9000
PARAM_TASK_6        equ 0x0010_A000

CR3_TASK_4          equ 0x0020_0000
CR3_TASK_5          equ 0x0020_2000
CR3_TASK_6          equ 0x0020_4000

FAT_SIZE            equ (1024 * 128)
ROOT_SIZE           equ (1024 * 16)

FAT1_START          equ (KERNEL_SIZE)
FAT2_START          equ (FAT1_START + FAT_SIZE)
ROOT_START          equ (FAT2_START + FAT_SIZE)
FILE_START          equ (ROOT_START + ROOT_SIZE)

ATTR_VOLUME_ID      equ 0x08
ATTR_ARCHIVE        equ 0x20