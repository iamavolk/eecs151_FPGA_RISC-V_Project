.section    .start
.global     _start

_start:

# Follow a convention
# x1 = result register 1
# x2 = result register 2
# x10 = argument 1 register
# x11 = argument 2 register
# x20 = flag register

# Test ADD
#li x10, 100         # Load argument 1 (rs1)
#li x11, 200         # Load argument 2 (rs2)
#add x1, x10, x11    # Execute the instruction being tested
#li x20, 1           # Set the flag register to stop execution and inspect the result register
                    # Now we check that x1 contains 300

# Test BEQ
#li x2, 100          # Set an initial value of x2
#beq x0, x0, branch1 # This branch should succeed and jump to branch1
#li x2, 123          # This shouldn't execute, but if it does x2 becomes an undesirable value
#branch1: li x1, 500 # x1 now contains 500
#li x20, 2           # Set the flag register
                    # Now we check that x1 contains 500 and x2 contains 100

# TODO: add more tests here
li x4, 80
beq x1, x2, label
sw x4, 0(x4)
sw x4, 0(x4)
li x14, 14
li x14, 14
li x14, 14
li x14, 14
add x0, x0, 1         
label: li x14, 14
#li x1, 80            # x1 = 80 = 0x20
#li x2, 128           # x2 = 128 = 0x10
#sw x2, 0(x1)         # 128 at addr 0x32
#li x4, 4             # x4 = 4
#li x29, 29           # x29 = 29
#lw x3, 0(x1)         # x3 = 128
#li x15, 15
#addi x5, x3, 3
#add x5, x5, x5
#add x5, x5, x5
#li x17, 17
#li x14, 14



#done: j done
