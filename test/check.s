.text
.globl _start
_start:
  call main
  li a7, 93
  mv a0, a0
  ecall

.globl main

main:
  addi sp, sp, -40
  sw ra, 36(sp)
  sw s0, 32(sp)
  addi s0, sp, 40
  li t0, 1
  sw t0, -20(s0)
  li t0, 1
  sw t0, -24(s0)
L1:
  lw t0, -20(s0)
  addi sp, sp, -4
  sw t0, 0(sp)
  li t0, 1
  lw t1, 0(sp)
  addi sp, sp, 4
  sgt t0, t1, t0
  beqz t0, L2
  lw t0, -24(s0)
  addi sp, sp, -4
  sw t0, 0(sp)
  lw t0, -20(s0)
  lw t1, 0(sp)
  addi sp, sp, 4
  mul t0, t1, t0
  sw t0, -24(s0)
  lw t0, -20(s0)
  addi sp, sp, -4
  sw t0, 0(sp)
  li t0, 1
  lw t1, 0(sp)
  addi sp, sp, 4
  sub t0, t1, t0
  sw t0, -20(s0)
  j L1
L2:
  lw t0, -24(s0)
  mv a0, t0
  j main_ret
main_ret:
  lw ra, 36(sp)
  lw s0, 32(sp)
  addi sp, sp, 40
  ret
