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

 # y("PASS - test %d, got: %d for reg %d", test_num, expected_value, reg_number);TODO: add more tests here
li x1, 100 	# 1) x1 = 100 = 64 + 32 + 4 = 1100100
#li x2, 40	# 2) x2 = 40 = 32 + 8 = 101000
#li x11, 2	# 3) x11 = 2
#li x12, 1	# 4) x12 = 1
#sub x3, x1, x2	# 5) x3 = x1-x2 = 60
#add x4, x1, x2	# 6) x4 = x1+x2 = 140
#sll x5, x11, x12# 7) x5 = x11 << x12 = 4
#srl x6, x11, x12# 8) x6 = x11 >> x12 = 1
#slt x7, x1, x1	# 9) x7 = x1<x1 ?-> 0
#slt x8, x2, x1	# 10) x8 = x2<x1 > -> 1
#li x10, -10	# 11) x10 = -10
#and x3, x1, x2	# 12) x3 = 1100100 & 0101000 = 0100000 = 32
#or x4, x1, x2	# 13) x4 = 1100100 | 0101000 = 1101100 = 108
#or x5, x1, x2	# 14) x5 = 1100100 ^ 0101000 = 1001100 = 76
#sltu x6, x2, x10# 15) x6 = x2<x10 (unsigned) -> 1
#slt x7, x10, x2	# 16) x7 = x10<x2 (signed) -> 1
#srai x8, x10, 2 # 17) x8 = ..110110>>>2 -> FFFF...1101 = ...FFD
#srli x9, x10, 2 # 18) x9 = -10 >> 2 = 3F..FFFD
#sltiu x13, x11, -20 # 19) x13 = x11<-20(unsigned) -> 1
#sltiu x14, x11, 20 # 20) x14 = x11<20(unsigned) -> 1
#sltiu x15, x11, 1 # 21) x15 = x11<1 ->0
#li x0, 1	# 22) x0 should stay 0
#add x0, x0, 1	# 23) x0 should stay 0



#done: j done
