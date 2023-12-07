# HW5 
# Adam Hanna
# 12/06/2023
# 

# Constants
DELAY_COUNTER    = 0x61A8
BLINK_PERIOD_MAX = 20000000   # 2 seconds
BLINK_PERIOD_MIN = 0          # 0 seconds
PERIOD_STEP      = 500000     # 0.5 second step
# Masks
S1_MASK = 0x80       # S1 mask
S2_MASK = 0x2000     # S2 mask
# ... (Include necessary headers and constants)
.text
.globl main
.ent main
main:
    # Configure I/O ports
    sw zero, TRISA
    sw zero, ANSELA
    li t0, 0x0880
    sw t0, TRISB
    sw zero, ANSELB
    sw zero, TRISC
    sw zero, ANSELC
    # Configure Timer1
    li t1, DELAY_COUNTER
    sw t1, TMR1
    li t1, BLINK_PERIOD_MAX
    sw t1, PR1
    li t1, 0x8000
    sw t1, T1CON
    # Configure interrupts
    li t1, 0x0001
    li t2, 0x0080
    li t3, 0x0100
    li t4, 0x2000
    li t5, 0x0008
    li t6, 0x0180
    li t7, 0x6000
    sw t1, INTCONSET
    sw t2, IPC1
    sw t3, IFS0CLR
    sw t4, IEC0SET
    sw t5, CNEN1B
    sw zero, CNEN0B
    sw t6, CNCONB
    sw t7, IPC2
    ei
mainloop:
    j mainloop
    nop
.end main
# Timer1 ISR handling
.text
.globl isrvector4
.ent isrvector4

isrvector4:
    li t1, 0x0008
    sw t1, IFS0CLR


    eret
    .end isrvector4


.text
.globl isrvector9
.ent isrvector9

isrvector9:
    li t1, 0x0100
    sw t1, IFS0CLR

    lw t2, CNFB
    and t3, t2, S1_MASK
    beq t3, zero, checkS2

    # S1 pressed
    sw S1_MASK, CNFBCLR
    jal delay
    lw t4, PORTB
    and t4, t4, S1_MASK

    beq t4, zero, checkS2
    li t0, 0x0001
    sw t0, LATAINV

checkS2:
    and t3, t2, S2_MASK
    beq t3, zero, intdone

    # S2 pressed
    sw S2_MASK, CNFBCLR
    jal delay
    lw t4, PORTB
    and t4, t4, S2_MASK

    beq t4, zero, intdone
    li t1, 0x0200
    sw t1, LATCINV

intdone:
    li t5, 0x0100
    sw t5, IFS0CLR
    eret
    .end isrvector9


.text
.globl delay
.ent delay

delay:
    li t7, DELAY_COUNTER

loop:
    addi t7, t7, -1
    bne t7, zero, loop
    nop

    jr ra
    nop

.end delay
