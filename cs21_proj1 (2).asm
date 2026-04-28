###########################################################
# Members:
# Dash Ceñido - 202306831
# Justin Chuah - 202300514
# Mateo Cruz - 202200802
###########################################################

.text
#### GAME STATE - JUSTIN ####
li s0, 1 # new game
li s1, 2 # start from state
li s2, 0 # where input will be
li s3, 9

before_game_loop:
la a0, before_start #print game select option (pick 1 or 2)
li a7, 4
ecall

li a7, 63
li a0, 0
la a1, input # get user input
li a2, 20
ecall

lb s2, 0(a1)
mv a0, s2
addi a0, a0, -48 # convert ascii code to decimal

beq a0, s0, blank_random_game # branch to new game if a1 equal to 1
beq a0, s1, start_state # branch to start from state if a2 equal to 2
j before_game_loop # jump back to ask for another input

blank_random_game: # initialize blank board
li s9, 0x10000040
li s8, 0x10000064
li s7, 0

make_adr_blank: #set all grids to be 0
beq s9, s8, place_random
sw s7, 0(s9)
addi s9, s9, 4
j make_adr_blank

place_random: #get time since epoch for random seed
li a7, 30
ecall
rem a0, a0, s3 #modulo 9 for random cell/position picking

li s0, 0 #top-left
li s1, 1 #top-middle
li s2, 2 #top-right
li s3, 3 #middle-left
li s4, 4 #middle
li s5, 5 #middle-right
li s6, 6 #bottom-left
li s7, 7 #bottom-middle
li s8, 8 #bottom-right
li s9, 0x10000040 #base address

#all of this is self explanatory (hard coded checks to see which cell to place the '2' tile in)
beq a0, s0, tl
beq a0, s1, tm
beq a0, s2, tr
beq a0, s3, ml
beq a0, s4, m
beq a0, s5, mr
beq a0, s6, bl
beq a0, s7, bm
beq a0, s8, br

#also self explanatory (hard coded address increments to reach each cell)
br:
addi s9, s9, 4
bm:
addi s9, s9, 4
bl:
addi s9, s9, 4
mr:
addi s9, s9, 4
m:
addi s9, s9, 4
ml:
addi s9, s9, 4
tr:
addi s9, s9, 4
tm:
addi s9, s9, 4
tl:
sw s2, 0(s9)
j new_game #begin game

#option 2 (when user selects state 2)
start_state:
li t6, 0x10000064 #limit of board memory
li s3, 0x10000040
li s4, 4
li s5, 8
li s6, 16
li s7, 32
li s8, 64
li s9, 128
li s10, 256
li s11, 512

la a0, enter_config #print enter configuration message
li a7, 4
ecall

start_state_input: #loop to read 9 integers for board setup
beq s3, t6, new_game #start new game once all 9 integers are read and stored in the grid memory

#read number input
li a0, 0
la a1, number
li a2, 32
li a7, 63
ecall

#initialize stack
addi sp, sp, -20
sw t3, 16(sp) #for integer value
sw t2, 12(sp) #for negative tracking
sw t1, 8(sp) #free rn
sw t0, 4(sp) #for byte addressing in s0's address
sw s0, 0(sp) #pointer to bits in number memory

la s0, number #pointer to the storage of num
addi t3, zero, 0 #for making the integer

lb t0, 0(s0) #accesses the 0th byte in the address s0 points to (first digit access)
li t1, 45
bne t0, t1, loop
addi t2, zero, 1 #Bool for negative integer
addi s0, s0, 1 #move on to next byte of memory (like from 0x..0 to 0x..01)

loop:
lb t0, 0(s0)

#stop conditions
beq t0, zero, print
li t1, 10
beq t0, t1, print

#number conversions
li t1, 48 #ASCII 0
sub t0, t0, t1 #sub digit w/ ASCII 0 for conversion to int
blt t0, zero, print #case: not a digit
addi t1, zero, 9
bgt t0, t1, print #case not a digit (bigger than 9)

#compiling digits
addi t1, zero, 10
mul t3, t3, t1
add t3, t3, t0

#loop back
addi s0, s0, 1
j loop

print:  
jal read_int
lw t3, 16(sp)
lw t2, 12(sp)
lw t1, 8(sp)
lw t0, 4(sp)
lw s0, 0(sp)
addi sp, sp, 20
j done

read_int:
beq t2, zero, u_read_int #if code doesn't branch, number is negative
sub t3, zero, t3
mv a0, t3
li a7, 1
ecall
jr ra

u_read_int:
mv a0, t3
jr ra

done: # store the input number into the board memory
beq a0, zero, add_none  # if input equal to 0
beq a0, s1, add_two  # if input equal to 2
beq a0, s4, add_four
beq a0, s5, add_eight
beq a0, s6, add_sixteen
beq a0, s7, add_thirty_two
beq a0, s8, add_sixty_four
beq a0, s9, add_one_hundred_twenty_eight
beq a0, s10, add_two_hundred_fifty_six
beq a0, s11, add_five_hundred_twelve
j start_state_input

#hardcoded storage of input values into board memory
add_none:
add_two:
add_four:
add_eight:
add_sixteen:
add_thirty_two:
add_sixty_four:
add_one_hundred_twenty_eight:
add_two_hundred_fifty_six:
add_five_hundred_twelve:
sw a0, 0(s3)

update_address:
addi s3, s3, 4
j start_state_input #loop back to read next integer

#### GAME STATE - JUSTIN ####

new_game:
li s0, 0x77 # 'w'
li s1, 0x61 # 'a'
li s2, 0x73 # 's'
li s3, 0x64 # 'd'
li s9, 0x78 # 'x'
li s4, 0
li s6, 0

addi s4, s4, 3
addi s6, s6, 9
li s7, 0x10000040
li s5, 2
li s8, 0

# WORD-BASED BOARD
# Row 1: 0x40 0x44 0x48
# Row 2: 0x4C 0x50 0x54
# Row 3: 0x58 0x5C 0x60

#### BOARD PRINTING - CRUZ ####
# Nested loop with two loop counters (t0, t1) to indicate amount of #
# rows and columns respectively.                                    #
# Inside 'inner loop', condition checks (using branch instructions) #
# are in place to check what to print for the value in each cell.   #
print_border:
    li a7, 4
    la a0, border
    ecall
    beq t0, s4, after_print #user_input intercepted for board scanning!

print_row:
    li a7, 4
    la a0, wall
    ecall
    addi t1, t1, 1
    lw t4, 0(s7)
    bne t4, zero, print_num

print_blank:
    li a7, 4
    la a0, space
    ecall
    addi s7, s7, 4
    beq t1, s4, end_row
    j print_row

print_num:
    li t2 100
    bgt t4 t2 print_int
    li a7, 4
    la a0, single_space
    ecall
    li t2 10
    print_int:
    li a7, 1
    mv a0, t4
    ecall
    bgt t4 t2 end_num
    li a7, 4
    la a0, single_space
    ecall
    end_num:
    addi s7, s7, 4
    beq t1, s4, end_row
    j print_row

end_row:
    addi t0, t0, 1
    li t1, 0
    li a7, 4
    la a0, wall
    ecall
    la a0, newline
    ecall
    j print_border
#### BOARD PRINTING - CRUZ ####

#### CHECK IF PLAYABLE - CENIDO ####

after_print:
    li t0, 0
    li t1, 0
    li t2, 0
    li s7, 0x10000040
    j check_if_win

check_if_win: #initial board scan iterates through all cells to check if it contains 512
    lw t0, 0(s7)
    li t1, 512
    li t3, 9

    beq t0, t1, win_game #branch to win_game if 512 found
    addi s7, s7, 4
    addi t2, t2, 1
    bne t2, t3, check_if_win
    li s7, 0x10000040
    li t1, 0
    li t2, 0
    li t3, 0
    j check_can_move

check_can_move: #second scan checks if there are any possible moves left
#second scan initally scans if there are empty cells (zeroes) before checking for possible merges
#list of adjacent cell checks:

#right-adjacent and down-adjcent: 0x40, 0x44, 0x4C, 0x50
#down adjacent only: 0x48, 0x54
#right-adjacent only: 0x58, 0x5C
#no adjacents: 0x60

# RECALL: WORD-BASED BOARD
# Row 1: 0x40 0x44 0x48
# Row 2: 0x4C 0x50 0x54
# Row 3: 0x58 0x5C 0x60

#NOTE: each cell check was hardcoded for convenience

#### CELL 1 (0x40) ####
    lw t0, 0(s7)
    beq t0, zero, user_input
    li s7, 0x10000044
    lw t1, 0(s7)
    beq t0, t1, user_input
    li s7, 0x1000004C
    lw t1, 0(s7)
    beq t0, t1, user_input

    #### CELL 2 (0x44) ####
    li s7, 0x10000044
    lw t0, 0(s7)
    beq t0, zero, user_input
    li s7, 0x10000048
    lw t1, 0(s7)
    beq t0, t1, user_input
    li s7, 0x10000050
    lw t1, 0(s7)
    beq t0, t1, user_input

    #### CELL 3 (0x48) ####
    li s7, 0x10000048
    lw t0, 0(s7)
    beq t0, zero, user_input
    li s7, 0x10000054
    lw t1, 0(s7)
    beq t0, t1, user_input

    #### CELL 4 (0x4C) ####
    li s7, 0x1000004C
    lw t0, 0(s7)
    beq t0, zero, user_input
    li s7, 0x10000050
    lw t1, 0(s7)
    beq t0, t1, user_input
    li s7, 0x10000058
    lw t1, 0(s7)
    beq t0, t1, user_input

    #### CELL 5 (0x50) ####
    li s7, 0x10000050
    lw t0, 0(s7)
    beq t0, zero, user_input
    li s7, 0x10000054
    lw t1, 0(s7)
    beq t0, t1, user_input
    li s7, 0x1000005C
    lw t1, 0(s7)
    beq t0, t1, user_input

    #### CELL 6 (0x54) ####
    li s7, 0x10000054
    lw t0, 0(s7)
    beq t0, zero, user_input
    li s7, 0x10000060
    lw t1, 0(s7)
    beq t0, t1, user_input

    #### CELL 7 (0x58) ####
    li s7, 0x10000058
    lw t0, 0(s7)
    beq t0, zero, user_input
    li s7, 0x1000005C
    lw t1, 0(s7)
    beq t0, t1, user_input

    #### CELL 8 (0x5C) ####
    li s7, 0x1000005C
    lw t0, 0(s7)
    beq t0, zero, user_input
    li s7, 0x10000060
    lw t1, 0(s7)
    beq t0, t1, user_input

    #### CELL 9 (0x60) ####
    li s7, 0x10000060
    lw t0, 0(s7)
    beq t0, zero, user_input

    #no branches here means playable
    j full_board

#### CHECK IF PLAYABLE - CENIDO ####

######## ADD 2 - CRUZ ########
add_2:
    sw s5, 0(s7)
    li s7, 0x10000040
    j print_border

scan_board:
    li a3, 0
    beq s8, s6, full_board
    lw t6, 0(s7)
    beq t6, zero, add_2
    addi s7, s7, 4
    addi s8, s8, 1
    j scan_board
######## ADD 2 - CRUZ ########

######## MOVEMENT LOGIC - CENIDO ########

######## MOVEMENT LOGIC - UP (WORD, WITH MERGE) ########
#in general we process the board one row (or column) at a time
# for each row, tiles are shifted toward the movement direction
# and we start with the middle row/column
# movement is done first to create space followed by merge checks
# a second pass is performed to ensure that tiles can slide as far as possible
# a merge flag is used to ensure only one merge occurs during a single move, prioritizing the merge nearest to the desired direction
# a global change flag is used to track whether any movement or merge occurs
# the movement flag is used to ensure that a new '2' tile is spawned after each movement

#all addresses are hardcoded for convenience
move_up:
    li s11, 0 #flag for merges (avoids double merges in one move)
    li s10, 1 #constant for flag comparison
    li a3, 0 #flag to check if any movement/merge happened. If movement/merge happened, a3 > 0 and we can add a new '2' tile

    #### COLUMN 1 ####
    #middle -> top
    li t2, 0x1000004C
    lw t3, 0(t2)
    beq t3, zero, u1_down
    li t4, 0x10000040
    lw t5, 0(t4)
    beq t5, zero, u1_move_mid #if top is empty, move middle to top
    beq t5, t3, u1_merge_mid #if values are equal, merge
    j u1_down

u1_move_mid: #move middle tile to top
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j u1_down

u1_merge_mid: #merge middle tile to top (logic here applies to every other merge function below)
    beq s11, s10, u1_down
    add t6, t3, t5 #merge values
    sw t6, 0(t4)
    sw zero, 0(t2) #make current cell 0
    addi a3, a3, 1
    addi s11, s11, 1

u1_down:
    #bottom -> middle
    li t2, 0x10000058
    lw t3, 0(t2)
    beq t3, zero, u1_pass2
    li t4, 0x1000004C
    lw t5, 0(t4)
    beq t5, zero, u1_move_bot #if middle is empty, move bottom to middle
    beq t5, t3, u1_merge_bot #if values are equal, merge
    j u1_pass2

u1_move_bot: #move bottom tile to middle
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j u1_pass2

u1_merge_bot: #merge bottom tile to middle
    beq s11, s10, u1_pass2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

u1_pass2:
    #second pass: middle -> top
    li t2, 0x1000004C
    lw t3, 0(t2)
    beq t3, zero, col2_u
    li t4, 0x10000040
    lw t5, 0(t4)
    beq t5, zero, u1_move_mid2 #if top is empty, move middle to top
    beq t5, t3, u1_merge_mid2 #if values are equal, merge
    j col2_u

u1_move_mid2:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j col2_u

u1_merge_mid2:
    beq s11, s10, col2_u
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

    #### COLUMN 2 ####
col2_u: #same process as col1
    li s11, 0
    li t2, 0x10000050
    lw t3, 0(t2)
    beq t3, zero, u2_down
    li t4, 0x10000044
    lw t5, 0(t4)
    beq t5, zero, u2_move_mid
    beq t5, t3, u2_merge_mid
    j u2_down

u2_move_mid:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j u2_down

u2_merge_mid:
    beq s11, s10, u2_down
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

u2_down:
    li t2, 0x1000005C
    lw t3, 0(t2)
    beq t3, zero, u2_pass2
    li t4, 0x10000050
    lw t5, 0(t4)
    beq t5, zero, u2_move_bot
    beq t5, t3, u2_merge_bot
    j u2_pass2

u2_move_bot:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j u2_pass2

u2_merge_bot:
    beq s11, s10, u2_pass2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

u2_pass2:
    li t2, 0x10000050
    lw t3, 0(t2)
    beq t3, zero, col3_u
    li t4, 0x10000044
    lw t5, 0(t4)
    beq t5, zero, u2_move_mid2
    beq t5, t3, u2_merge_mid2
    j col3_u

u2_move_mid2:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j col3_u

u2_merge_mid2:
    beq s11, s10, col3_u
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

    #### COLUMN 3 ####
col3_u: #same process as col1 and col2
    li s11, 0
    li t2, 0x10000054
    lw t3, 0(t2)
    beq t3, zero, u3_down
    li t4, 0x10000048
    lw t5, 0(t4)
    beq t5, zero, u3_move_mid
    beq t5, t3, u3_merge_mid
    j u3_down

u3_move_mid:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j u3_down

u3_merge_mid:
    beq s11, s10, u3_down
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

u3_down:
    li t2, 0x10000060
    lw t3, 0(t2)
    beq t3, zero, u3_pass2
    li t4, 0x10000054
    lw t5, 0(t4)
    beq t5, zero, u3_move_bot
    beq t5, t3, u3_merge_bot
    j u3_pass2

u3_move_bot:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j u3_pass2

u3_merge_bot:
    beq s11, s10, u3_pass2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

u3_pass2:
    li t2, 0x10000054
    lw t3, 0(t2)
    beq t3, zero, end_move_u
    li t4, 0x10000048
    lw t5, 0(t4)
    beq t5, zero, u3_move_mid2
    beq t5, t3, u3_merge_mid2
    j end_move_u

u3_move_mid2:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j end_move_u

u3_merge_mid2:
    beq s11, s10, end_move_u
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

end_move_u:
    beq a3, zero, print_border
    j scan_board
######## MOVEMENT LOGIC - UP (WORD, WITH MERGE) ########

######## MOVEMENT LOGIC - DOWN (WORD, WITH MERGE) ########
move_down: #same process as move_up but in reverse order
    li s11, 0
    li s10, 1
    li a3, 0

    #### COLUMN 1 ####
    #middle -> bottom
    li t2, 0x1000004C
    lw t3, 0(t2)
    beq t3, zero, d1_up

    li t4, 0x10000058
    lw t5, 0(t4)

    beq t5, zero, d1_move_mid
    beq t5, t3, d1_merge_mid
    j d1_up

d1_move_mid:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j d1_up

d1_merge_mid:
    beq s11, s10, d1_up
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

d1_up:
    #top -> middle
    li t2, 0x10000040
    lw t3, 0(t2)
    beq t3, zero, d1_pass2

    li t4, 0x1000004C
    lw t5, 0(t4)

    beq t5, zero, d1_move_top
    beq t5, t3, d1_merge_top
    j d1_pass2

d1_move_top:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j d1_pass2

d1_merge_top:
    beq s11, s10, d1_pass2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

d1_pass2:
    #second pass: middle -> bottom
    li t2, 0x1000004C
    lw t3, 0(t2)
    beq t3, zero, col2_d

    li t4, 0x10000058
    lw t5, 0(t4)

    beq t5, zero, d1_move_mid2
    beq t5, t3, d1_merge_mid2
    j col2_d

d1_move_mid2:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j col2_d

d1_merge_mid2:
    beq s11, s10, col2_d
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

    #### COLUMN 2 ####
col2_d:
    li s11, 0

    li t2, 0x10000050
    lw t3, 0(t2)
    beq t3, zero, d2_up

    li t4, 0x1000005C
    lw t5, 0(t4)

    beq t5, zero, d2_move_mid
    beq t5, t3, d2_merge_mid
    j d2_up

d2_move_mid:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j d2_up

d2_merge_mid:
    beq s11, s10, d2_up
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

d2_up:
    li t2, 0x10000044
    lw t3, 0(t2)
    beq t3, zero, d2_pass2

    li t4, 0x10000050
    lw t5, 0(t4)

    beq t5, zero, d2_move_top
    beq t5, t3, d2_merge_top
    j d2_pass2

d2_move_top:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j d2_pass2

d2_merge_top:
    beq s11, s10, d2_pass2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

d2_pass2:
    li t2, 0x10000050
    lw t3, 0(t2)
    beq t3, zero, col3_d

    li t4, 0x1000005C
    lw t5, 0(t4)

    beq t5, zero, d2_move_mid2
    beq t5, t3, d2_merge_mid2
    j col3_d

d2_move_mid2:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j col3_d

d2_merge_mid2:
    beq s11, s10, col3_d
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

    #### COLUMN 3 ####
col3_d:
    li s11, 0

    li t2, 0x10000054
    lw t3, 0(t2)
    beq t3, zero, d3_up

    li t4, 0x10000060
    lw t5, 0(t4)

    beq t5, zero, d3_move_mid
    beq t5, t3, d3_merge_mid
    j d3_up

d3_move_mid:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j d3_up

d3_merge_mid:
    beq s11, s10, d3_up
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

d3_up:
    li t2, 0x10000048
    lw t3, 0(t2)
    beq t3, zero, d3_pass2

    li t4, 0x10000054
    lw t5, 0(t4)

    beq t5, zero, d3_move_top
    beq t5, t3, d3_merge_top
    j d3_pass2

d3_move_top:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j d3_pass2

d3_merge_top:
    beq s11, s10, d3_pass2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

d3_pass2:
    li t2, 0x10000054
    lw t3, 0(t2)
    beq t3, zero, end_move_d

    li t4, 0x10000060
    lw t5, 0(t4)

    beq t5, zero, d3_move_mid2
    beq t5, t3, d3_merge_mid2
    j end_move_d

d3_move_mid2:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j end_move_d

d3_merge_mid2:
    beq s11, s10, end_move_d
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

end_move_d:
    beq a3, zero, print_border
    j scan_board
######## MOVEMENT LOGIC - DOWN (WORD, WITH MERGE) ########

######## MOVEMENT LOGIC - LEFT (WORD, WITH MERGE) ########
move_left: #same process as move_up and move_down, but for rows
    li s7, 0x10000040
    li t0, 0
    li t1, 0
    li s11, 0
    li s10, 1
    li a3, 0

    #### ROW 1 ####
    li t2, 0x10000044
    lw t3, 0(t2)
    beq t3, zero, l1_right
    li t4, 0x10000040
    lw t5, 0(t4)
    beq t5, zero, l1_move_mid #if left is empty, move middle to left
    beq t5, t3, l1_merge_mid #if values are equal, merge
    j l1_right

l1_move_mid: #move middle tile to left
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j l1_right

l1_merge_mid: #merge middle tile to left
    beq s11, s10, l1_right
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

l1_right: #right -> middle
    li t2, 0x10000048
    lw t3, 0(t2)
    beq t3, zero, l1_pass2
    li t4, 0x10000044
    lw t5, 0(t4)
    beq t5, zero, l1_move_right #if middle is empty, move right to middle
    beq t5, t3, l1_merge_right #if values are equal, merge
    j l1_pass2

l1_move_right: #move right tile to middle
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j l1_pass2

l1_merge_right: #merge right tile to middle
    beq s11, s10, l1_pass2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

l1_pass2: #second pass: middle -> left
    li t2, 0x10000044
    lw t3, 0(t2)
    beq t3, zero, row2_l
    li t4, 0x10000040
    lw t5, 0(t4)
    beq t5, zero, l1_move_mid2 #if left is empty, move middle to left
    beq t5, t3, l1_merge_mid2 #if values are equal, merge
    j row2_l

l1_move_mid2: #move middle tile to left
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j row2_l

l1_merge_mid2: #merge middle tile to left
    beq s11, s10, row2_l
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

    #### ROW 2 ####
row2_l: #same process as row1
    li s11, 0
    li t2, 0x10000050
    lw t3, 0(t2)
    beq t3, zero, l2_right
    li t4, 0x1000004C
    lw t5, 0(t4)
    beq t5, zero, l2_move_mid
    beq t5, t3, l2_merge_mid
    j l2_right

l2_move_mid:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j l2_right

l2_merge_mid:
    beq s11, s10, l2_right
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

l2_right:
    li t2, 0x10000054
    lw t3, 0(t2)
    beq t3, zero, l2_pass2
    li t4, 0x10000050
    lw t5, 0(t4)
    beq t5, zero, l2_move_right
    beq t5, t3, l2_merge_right
    j l2_pass2

l2_move_right:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j l2_pass2

l2_merge_right:
    beq s11, s10, l2_pass2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

l2_pass2:
    li t2, 0x10000050
    lw t3, 0(t2)
    beq t3, zero, row3_l
    li t4, 0x1000004C
    lw t5, 0(t4)
    beq t5, zero, l2_move_mid2
    beq t5, t3, l2_merge_mid2
    j row3_l

l2_move_mid2:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j row3_l

l2_merge_mid2:
    beq s11, s10, row3_l
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

    #### ROW 3 ####
row3_l: #same process as row1 and row2
    li s11, 0
    li t2, 0x1000005C
    lw t3, 0(t2)
    beq t3, zero, l3_right
    li t4, 0x10000058
    lw t5, 0(t4)
    beq t5, zero, l3_move_mid
    beq t5, t3, l3_merge_mid
    j l3_right

l3_move_mid:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j l3_right

l3_merge_mid:
    beq s11, s10, l3_right
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

l3_right:
    li t2, 0x10000060
    lw t3, 0(t2)
    beq t3, zero, l3_pass2
    li t4, 0x1000005C
    lw t5, 0(t4)
    beq t5, zero, l3_move_right
    beq t5, t3, l3_merge_right
    j l3_pass2

l3_move_right:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j l3_pass2

l3_merge_right:
    beq s11, s10, l3_pass2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

l3_pass2:
    li t2, 0x1000005C
    lw t3, 0(t2)
    beq t3, zero, end_move_l
    li t4, 0x10000058
    lw t5, 0(t4)
    beq t5, zero, l3_move_mid2
    beq t5, t3, l3_merge_mid2
    j end_move_l

l3_move_mid2:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j end_move_l

l3_merge_mid2:
    beq s11, s10, end_move_l
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

end_move_l:
    beq a3, zero, print_border
    j scan_board
######## MOVEMENT LOGIC - LEFT (WORD, WITH MERGE) ########

######## MOVEMENT LOGIC - RIGHT (WORD, WITH MERGE) ########
move_right: #same process as move_left but in reverse order
    li s7, 0x10000040
    li t0, 0
    li t1, 0
    li s11, 0
    li s10, 1
    li a3, 0

    #### ROW 1 ####
    li t2, 0x10000044
    lw t3, 0(t2)
    beq t3, zero, r1_left
    li t4, 0x10000048
    lw t5, 0(t4)
    beq t5, zero, r1_move_mid
    beq t5, t3, r1_merge_mid
    j r1_left

r1_move_mid:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j r1_left

r1_merge_mid:
    beq s11, s10, r1_left
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

r1_left:
    li t2, 0x10000040
    lw t3, 0(t2)
    beq t3, zero, r1_pass2
    li t4, 0x10000044
    lw t5, 0(t4)
    beq t5, zero, r1_move_left
    beq t5, t3, r1_merge_left
    j r1_pass2

r1_move_left:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j r1_pass2

r1_merge_left:
    beq s11, s10, r1_pass2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

r1_pass2:
    li t2, 0x10000044
    lw t3, 0(t2)
    beq t3, zero, row2
    li t4, 0x10000048
    lw t5, 0(t4)
    beq t5, zero, r1_move_mid2
    beq t5, t3, r1_merge_mid2
    j row2

r1_move_mid2:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j row2

r1_merge_mid2:
    beq s11, s10, row2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

    #### ROW 2 ####
row2:
    li s11, 0
    li t2, 0x10000050
    lw t3, 0(t2)
    beq t3, zero, r2_left
    li t4, 0x10000054
    lw t5, 0(t4)
    beq t5, zero, r2_move_mid
    beq t5, t3, r2_merge_mid
    j r2_left

r2_move_mid:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j r2_left

r2_merge_mid:
    beq s11, s10, r2_left
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

r2_left:
    li t2, 0x1000004C
    lw t3, 0(t2)
    beq t3, zero, r2_pass2
    li t4, 0x10000050
    lw t5, 0(t4)
    beq t5, zero, r2_move_left
    beq t5, t3, r2_merge_left
    j r2_pass2

r2_move_left:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j r2_pass2

r2_merge_left:
    beq s11, s10, r2_pass2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

r2_pass2:
    li t2, 0x10000050
    lw t3, 0(t2)
    beq t3, zero, row3
    li t4, 0x10000054
    lw t5, 0(t4)
    beq t5, zero, r2_move_mid2
    beq t5, t3, r2_merge_mid2
    j row3

r2_move_mid2:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j row3

r2_merge_mid2:
    beq s11, s10, row3
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

    #### ROW 3 ####
row3:
    li s11, 0
    li t2, 0x1000005C
    lw t3, 0(t2)
    beq t3, zero, r3_left
    li t4, 0x10000060
    lw t5, 0(t4)
    beq t5, zero, r3_move_mid
    beq t5, t3, r3_merge_mid
    j r3_left

r3_move_mid:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j r3_left

r3_merge_mid:
    beq s11, s10, r3_left
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

r3_left:
    li t2, 0x10000058
    lw t3, 0(t2)
    beq t3, zero, r3_pass2
    li t4, 0x1000005C
    lw t5, 0(t4)
    beq t5, zero, r3_move_left
    beq t5, t3, r3_merge_left
    j r3_pass2

r3_move_left:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j r3_pass2

r3_merge_left:
    beq s11, s10, r3_pass2
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

r3_pass2:
    li t2, 0x1000005C
    lw t3, 0(t2)
    beq t3, zero, end_move_r
    li t4, 0x10000060
    lw t5, 0(t4)
    beq t5, zero, r3_move_mid2
    beq t5, t3, r3_merge_mid2
    j end_move_r

r3_move_mid2:
    sw t3, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    j end_move_r

r3_merge_mid2:
    beq s11, s10, end_move_r
    add t6, t3, t5
    sw t6, 0(t4)
    sw zero, 0(t2)
    addi a3, a3, 1
    addi s11, s11, 1

end_move_r:
    beq a3, zero, print_border #if no movement happened, reprint board without adding a new tile
    j scan_board #if movement happened, branch to scan_board (which eventually adds a new '2' tile)

######## MOVEMENT LOGIC - RIGHT (WORD, WITH MERGE) ########

######## MOVEMENT LOGIC - CENIDO ########


######## USER INPUT HANDLING - CRUZ ########
# After resetting the values of registers used in previous game     #
# states, the input called (and stored in register a1) is compared  #
# with the ascii values of 'w', 'a', 's', and 'd' and branches to   #
# their corresponding board movement code block.                    #
# If an input 'x' is given, the code branches to the game over      #
# state. If an invalid input is given, the board reprints/stays the #
# same and requests for another user input.                         #

user_input:
    li s7, 0x10000040
    li t0, 0
    li t1, 0
    li t2, 0
    li t3, 0
    li t4, 0
    li t5, 0
    li t6, 0
    li s8, 0
    
    li a7, 63
    li a0, 0
    la a1, input
    li a2, 20
    ecall
    lb t5, 0(a1)
    beq t5, s0, move_up #move up
    beq t5, s1, move_left
    beq t5, s2, move_down #move down
    beq t5, s3, move_right
    beq t5, s9, full_board
    j user_input
 
full_board:
    li a7, 4
    la a0, game_over
    ecall
    j gameEnd

win_game:
    li a7, 4
    la a0, win_message
    ecall

gameEnd:
    li a7, 10
    ecall

######## USER INPUT HANDLING - CRUZ ########

.data
border:
    .string "+---+---+---+\n"
wall:
    .string "|"
space:
    .string "   "
single_space:
    .string " "
newline:
    .string "\n"
game_over:
    .string "Game over!"
win_message:
    .string "You win!"
input:
    .zero 5
before_start:
    .string "\nChoose [1] or [2]:\n[1] New Game\n[2] Start from a State\n"
number:
    .zero 32
enter_config:
    .string "\nEnter a board configuration:\n"