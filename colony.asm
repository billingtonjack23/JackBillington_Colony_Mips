#
# FILE:         colony.asm
# AUTHOR:       Jack Billington, jrb9799@rit.edu, Section 3
#
# DESCRIPTION: Plays the Game of Life Colony Version
#              Cells spawn on the board in desired locations
#              And for n generations, cells live and die
#       
###########################################################
#
# DATA AREA: used to set up any data or labels we need to print
# or access throughout our time in the program
#
        .data
        .align  2
#
#
# NUMERIC CONSTANTS: (for syscalls)
PRINT_STRING = 4
PRINT_INT = 1
PRINT_CHAR = 11
READ_INT = 5
READ_STRING = 8
TERMINATE = 10

# FRAMESIZE CONSTANTS:
FRAMESIZE_40 = 40
FRAMESIZE_8 = 8

#BOARD CONSTANTS
MIN_BOARD = 4
MAX_BOARD = 30
MAX_BOARD_SIZE = 900    #30^2

#GENERATION CONSTANTS
MIN_GENERATIONS = 0
MAX_GENERATIONS = 20

# ASCII VALUES
A_ascii = 65
B_ascii = 66
Space_ascii = 32
Plus_ascii = 43
Dash_ascii = 45

#
# All labels used by the program to print the board
#
space_char:
        .ascii  " "

A_char:
        .ascii  "A"

B_char:
        .ascii  "B"

add_char:
        .ascii  "+"

dash_char:
        .ascii  "-"

line_char:
        .ascii  "|"

newline_char:
        .asciiz  "\n"

#
# Labels used by the program to print the starting banner
#
# Should look like this:
#
# **********************
# ****    Colony    ****
# **********************
#

stars:
        .asciiz "**********************\n"

mid_banner:
        .asciiz "****    Colony    ****\n"

#
# Labels to print bepfre prompting for user input
#
input_board_size:
        .asciiz "Enter board size: "

input_num_gen:
        .asciiz "Enter number of generations to run: "

input_num_live_cells_A:
        .asciiz "Enter number of live cells for colony A: "

input_num_live_cells_B:
        .asciiz "Enter number of live cells for colony B: "

start_entering_locations:
        .asciiz "Start entering locations\n"

generation_begin:
        .asciiz  "====    GENERATION "

generation_end:
        .asciiz "    ===="

#
# Labels for error messages
#
board_size_err:
        .asciiz "WARNING: illegal board size, try again: \n"

num_gen_err:
        .asciiz "WARNING: illegal number of generations, try again: \n"

colony_err:
        .asciiz "WARNING: illegal number of live cells, try again: \n"

illegal_location_err:
        .asciiz "ERROR: illegal point location\n:"


# Storing all inputs from user in one array
# [0] = Board Size
# [1] = Number of generations to run
# [2] = Live cells for A
# [3] = Live cels for B
# [4] = Current generation
store_input:
        .word   0:5

Board1:
        .space   MAX_BOARD_SIZE

BoardCopy:
        .space   MAX_BOARD_SIZE

############################################################
#
# TEXT AREA: used to store the instructions
#
        .text           #start of the text area
        .align  2       #must align memory to boundary

        .globl main     #global main label for Makefile

#
# Name: main
# Description: Program start. Init stack frame
# Args: None
# Return: None
#
main:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)

        jal     print_starting_banner
        jal     initialize_board1_start
        jal     initialize_board_copy_start
        jal     user_input_start
        jal     simulation_start
        jal     main_restore

#
# Name: print_starting_banner
# Description: prints the starting banner that appears when you first
# run the code
# Args: None
# Return: None
#
print_starting_banner:
        # Init return address
        addi    $sp, $sp,-FRAMESIZE_8
        sw      $ra, -4+FRAMESIZE_8($sp)

        # Prints blank line before banner
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall       

        # Prints line of stars
        li      $v0, PRINT_STRING
        la      $a0, stars
        syscall   
        
        # Prints mid banner point
        li      $v0, PRINT_STRING
        la      $a0, mid_banner
        syscall   

        # Prints line of stars
        li      $v0, PRINT_STRING
        la      $a0, stars
        syscall     

        #Prints newline
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        # Restoring the return address
        lw      $ra, -4+FRAMESIZE_8($sp)
        addi    $sp, $sp, FRAMESIZE_8
        jr      $ra

########################################
######     START Init boards    ########
########################################
#
# Name: initialize_board1_start
# Description: Init all registers
# Args: None
# Return: None
#
initialize_board1_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)

        la      $s0, store_input        #input arr
        lw      $s1, 0($s0)             #board size
        li      $s2, MAX_BOARD_SIZE     #900
        la      $s3, Board1             

        li      $s7, 0                  #counter

#
# Name: initialize_board1_space_loop
# Description: sets whole board to space chars to use for comparison later
# Args: None
# Return: None
#
initialize_board1_space_loop:
        beq     $s7, $s2, initialize_board1_restore

        add     $s4, $s3, $s7   #get to board
        li      $t0, Space_ascii
        sb      $t0, 0($s4)     #put space at place in board

        addi    $s7, $s7, 1     # += 1

        j       initialize_board1_space_loop

#
# Name: initialize_board1_restore
# Description: restore all registers
# Args: None
# Return: None
#
initialize_board1_restore:
        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra  

#
# Name: initialize_board_copy_start
# Description: Init all registers
# Args: None
# Return: None
#
initialize_board_copy_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)

        la      $s0, store_input        #input arr
        lw      $s1, 0($s0)             #board size
        li      $s2, MAX_BOARD_SIZE     #900
        la      $s3, BoardCopy             

        li      $s7, 0                  #counter

#
# Name: initialize_board1_space_loop
# Description: sets whole board to space chars to use for comparison later
# Args: None
# Return: None
#
initialize_board_copy_space_loop:
        beq     $s7, $s2, initialize_board_copy_restore

        add     $s4, $s3, $s7   #get to board
        li      $t0, Space_ascii
        sb      $t0, 0($s4)     #put space at place in board

        addi    $s7, $s7, 1     # += 1

        j       initialize_board_copy_space_loop

#
# Name: initialize_board_copy_restore
# Description: restore all registers
# Args: None
# Return: None
#
initialize_board_copy_restore:
                #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra  

#
# Name: copy_to_board1_start
# Description: init all registers
# Args: None
# Return: None
#
copy_to_board1_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)

        la      $s0, store_input        #input array
        lw      $s1, 0($s0)             #board size
        la      $s2, Board1
        la      $s3, BoardCopy 
        li      $s4, MAX_BOARD_SIZE     #900

        li      $s7, 0                  #counter

#
# Name: copy_to_board1_loop
# Description: copys the board_copy to the board1
# Args: None
# Return: None
#
copy_to_board1_loop:
        # when counter reaches 900
        beq     $s7, $s4, copy_to_board1_restore

        add     $s6, $s7, $s3   #get offset in BoardCopy
        add     $s5, $s7, $s2   #get offset in Board1

        lbu     $t0, 0($s6)     #load val from BoardCopy
        sb      $t0, 0($s5)     #put into Board1

        addi    $s7, $s7, 1     # += 1

        j       copy_to_board1_loop

#
# Name: copy_to_board1_restore
# Description: restore all registers
# Args: None
# Return: None
#
copy_to_board1_restore:
        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra  

######################################
######     END Init boards    ########
######################################

#
# Name: user_input_start
# Description: Init registers for user input
# Args: None
# Return: None
#
user_input_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)

        jal     board_size_input_start
        jal     gens_input_start
        jal     live_A_start
        jal     find_locations_A_start
        jal     live_B_start
        jal     find_locations_B_start

#
# Name: user_input_restore
# Description: restore all registers
# Args: None
# Return: None
#
user_input_restore:
                #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra   



########################################
######  START Board Size    ######
########################################
#
# Name: board_size_input_start
# Description: init all registers for block
# Args: None
# Return: Proper board size
#
board_size_input_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)

        la      $s0, store_input

        #Prints prompt for board size
        li      $v0, PRINT_STRING
        la      $a0, input_board_size
        syscall

#
# Name: board_user_input
# Description: Gets user input for board size
# Args: None
# Return: None 
#
board_user_input:


        #Read input
        li      $v0, READ_INT
        syscall
        move    $s1, $v0   

        j       board_err_check

#
# Name: board_err_check
# Description: checks to see if the board is a valid size
# Args: None
# Return: None 
#
board_err_check:
        #initialize the board boundaries
        li      $t0, MIN_BOARD
        li      $t1, MAX_BOARD
        # s1 < 4
        blt     $s1, $t0, board_err_msg
        # s1 > 30
        bgt     $s1, $t1, board_err_msg 

        j       board_size_input_end

#
# Name: board_err_msg
# Description: prints the error message associated with illegal board size
# Args: None
# Return: None 
#
board_err_msg:
        #printing newline
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        #printing error message
        li      $v0, PRINT_STRING
        la      $a0, board_size_err
        syscall

        j       board_user_input


#
# Name: board_size_input_end
# Description: restores all registers saves value in store_input arr
# Args: None
# Return: None 
#
board_size_input_end:
        sw      $s1, 0($s0)

                #printing newline
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra   

################################
######  END Board Size    ######
################################


########################################
######  START Num_Generations    #######
########################################
#
# Name: board_size_input_start
# Description: init all registers for block
# Args: None
# Return: Proper num of generations
#
gens_input_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)

        la      $s0, store_input

        #Prints prompt for board size
        li      $v0, PRINT_STRING
        la      $a0, input_num_gen
        syscall

#
# Name: gens_user_input
# Description: Gets user input for number of generations
# Args: None
# Return: None 
#
gens_user_input:


        #Read input
        li      $v0, READ_INT
        syscall
        move    $s1, $v0   

        j       gens_err_check

#
# Name: gens_err_check
# Description: checks to see if the gens if valid
# Args: None
# Return: None 
#
gens_err_check:
        #initialize the board boundaries
        li      $t0, MIN_GENERATIONS
        li      $t1, MAX_GENERATIONS
        # s1 < 0
        blt     $s1, $t0, gens_err_msg
        # s1 > 20
        bgt     $s1, $t1, gens_err_msg 

        j       gens_input_end

#
# Name: board_err_msg
# Description: prints the error message associated with illegal gen num
# Args: None
# Return: None 
#
gens_err_msg:
        #printing newline
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        #printing error message
        li      $v0, PRINT_STRING
        la      $a0, num_gen_err
        syscall

        j       gens_user_input


#
# Name: gens_input_end
# Description: restores all registers saves value in store_input arr
# Args: None
# Return: None 
#
gens_input_end:
        sw      $s1, 4($s0)

                #printing newline
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra   

#####################################
######  END Num_Generations    ######
#####################################

#####################################
###     START of generating A     ###
#####################################
#
# Name: live_A_start
# Description: init all registers for block
# Args: None
# Return: None
#
live_A_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)

        la      $s0, store_input

        #Prints prompt live cells A
        li      $v0, PRINT_STRING
        la      $a0, input_num_live_cells_A
        syscall
#
# Name: live_A_user_input
# Description: take user input
# Args: None
# Return: None
#
live_A_user_input:


        #Read input
        li      $v0, READ_INT
        syscall
        move    $s1, $v0

        j       live_A_err_check


#
# Name: live_A_err_check
# Description: checks to see if the colony size is valid
# Args: None
# Return: None 
#
live_A_err_check:
        #Load board size
        lw      $t0, 0($s0)
        mul     $t1, $t0, $t0
       
        # $s1 < 0
        blt     $s1, $zero, live_A_err_msg
        # $s1 > $t1
        bgt     $s1, $t1, live_A_err_msg 

        j       live_A_input_end

#
# Name: live_A_err_msg
# Description: prints the error message associated with illegal colony num
# Args: None
# Return: None 
#
live_A_err_msg:
        #printing newline
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        #printing error message
        li      $v0, PRINT_STRING
        la      $a0, colony_err
        syscall

        j       live_A_user_input

#
# Name:live_A_input_end
# Description: restores all registers saves value in store_input arr
# Args: None
# Return: None 
#
live_A_input_end:
        sw      $s1, 8($s0)

                #printing newline
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra 

#####################################
###     END of generating A     #####
#####################################


#####################################
###     START of generating B     ###
#####################################
#
# Name: live_B_start
# Description: init all registers for block
# Args: None
# Return: None
#
live_B_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)

        la      $s0, store_input

                #Prints prompt live cells B
        li      $v0, PRINT_STRING
        la      $a0, input_num_live_cells_B
        syscall

#
# Name: live_B_user_input
# Description: take user input
# Args: None
# Return: None
#
live_B_user_input:


        #Read input
        li      $v0, READ_INT
        syscall
        move    $s1, $v0

        j       live_B_err_check


#
# Name: live_B_err_check
# Description: checks to see if the colony size is valid
# Args: None
# Return: None 
#
live_B_err_check:
        #Load board size
        lw      $t0, 0($s0)
        mul     $t1, $t0, $t0
       
        # $s1 < 0
        blt     $s1, $zero, live_B_err_msg
        # $s1 > $t1
        bgt     $s1, $t1, live_B_err_msg 

        j       live_B_input_end

#
# Name: live_B_err_msg
# Description: prints the error message associated with illegal colony num
# Args: None
# Return: None 
#
live_B_err_msg:
        #printing newline
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        #printing error message
        li      $v0, PRINT_STRING
        la      $a0, colony_err
        syscall

        j       live_B_user_input

#
# Name:live_B_input_end
# Description: restores all registers saves value in store_input arr
# Args: None
# Return: None 
#
live_B_input_end:
        sw      $s1, 12($s0)

                #printing newline
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra 

#####################################
###     END of generating B     #####
#####################################


#####################################
###     LOCATION HELPER FUNCS     ###
#####################################
#
# Name: set_board_spot
# Description: sets board spot to whatever letter needed 
# Args: a0 - the ascii value of the letter we want to set (A/B)
# Return: None 
#
set_board_spot:
        li      $t9, 0
        #get offset of board
        mul     $t9, $s2, $s5   #board size * row num   
        add     $t9, $t9, $s6   #$t9 + col
        add     $t9, $t9, $s1   #add that value to the board so now we
                                #have the location

        li      $t2, Space_ascii
        lbu     $t4, 0($t9)
        #Check if spot is already filled
        bgt     $t4, $t2, find_locations_err_msg

        sb      $a0, 0($t9)     #A/B is now in correct spot

        jr      $ra

#
# Name: find_locations_err_msg
# Description: prints err msg and terminates
# Args: None
# Return: None
#
find_locations_err_msg:
        #printing newline
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        #Prints illegal location error message
        li      $v0, PRINT_STRING
        la      $a0, illegal_location_err
        syscall

                #printing newline
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        #Kills program execution
        li      $v0, TERMINATE
        syscall


        
########################################
###  START Find Location A block    ####
########################################
#
# Name: find_locations_A_start
# Description: initializes all registers
# Args: Letter being put into location_arr
# Return: None
#
find_locations_A_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)


        la      $s0, store_input        #input array
        la      $s1, Board1             #game board
        lw      $s2, 0($s0)             #size of board
        lw      $s3, 8($s0)             #cells for A
        li      $s7, 0                  #counter

        #Prints prompt to start entering locations
        li      $v0, PRINT_STRING
        la      $a0, start_entering_locations
        syscall

        j       find_locations_A_loop

#
# Name: find_locations_A_loop
# Description: Loops to find valid locations on board
# Args: None
# Return: None
#
find_locations_A_loop: 
        #counter == A cells
        beq     $s7, $s3, find_locations_A_restore
        #Read input X VALUE
        li      $v0, READ_INT
        syscall 
        move    $s5, $v0

        #Read input Y VALUE
        li      $v0, READ_INT
        syscall 
        move    $s6, $v0

        j       find_locations_A_err_check

#
# Name: find_locations_A_err_check
# Description: checks to see if coords are valid
# Args: None
# Return: None
#
find_locations_A_err_check:
        # --X VALUE--
        # $s5 < 0
        blt     $s5, $zero, find_locations_err_msg
        # --Y VALUE--
        # $s6 < 0
        blt     $s6, $zero, find_locations_err_msg

        # --X VALUE--
        # $s5 > $s2
        bgt     $s5, $s2, find_locations_err_msg
        # --Y VALUE--
        # $s6 > $s2
        bgt     $s6, $s2, find_locations_err_msg
        
        #set board to A value in coord spot
        li      $a0, A_ascii
        jal     set_board_spot
        
        #counter += 1
        addi    $s7, $s7, 1

        j       find_locations_A_loop


#
# Name: find_locations_A_restore
# Description: resotres all registers
# Args: None
# Return: None
#
find_locations_A_restore:
        #printing newline
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra   
        
######################################
#### END Find Location A block    ###
######################################


########################################
###  START Find Location B block    ####
########################################
#
# Name: find_locations_B_start
# Description: initializes all registers
# Args: Letter being put into location_arr
# Return: None
#
find_locations_B_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)


        la      $s0, store_input        #input array
        la      $s1, Board1             #game board
        lw      $s2, 0($s0)             #size of board
        lw      $s3, 12($s0)             #cells for B
        li      $s7, 0                  #counter



        #Prints prompt to start entering locations
        li      $v0, PRINT_STRING
        la      $a0, start_entering_locations
        syscall

        j       find_locations_B_loop

#
# Name: find_locations_B_loop
# Description: Loops to find valid locations on board
# Args: None
# Return: None
#
find_locations_B_loop: 
        #counter == B cells
        beq     $s7, $s3, find_locations_B_restore
        #Read input X VALUE
        li      $v0, READ_INT
        syscall 
        move    $s5, $v0

        #Read input Y VALUE
        li      $v0, READ_INT
        syscall 
        move    $s6, $v0

        j       find_locations_B_err_check

#
# Name: find_locations_B_err_check
# Description: checks to see if coords are valid
# Args: None
# Return: None
#
find_locations_B_err_check:
        # --X VALUE--
        # $s5 < 0
        blt     $s5, $zero, find_locations_err_msg
        # --Y VALUE--
        # $s6 < 0
        blt     $s6, $zero, find_locations_err_msg

        # --X VALUE--
        # $s5 > $s2
        bgt     $s5, $s2, find_locations_err_msg
        # --Y VALUE--
        # $s6 > $s2
        bgt     $s6, $s2, find_locations_err_msg
        
        #set board to B value in coord spot
        li      $a0, B_ascii
        jal     set_board_spot
        
        #counter += 1
        addi    $s7, $s7, 1

        j       find_locations_B_loop

#
# Name: find_locations_B_restore
# Description: resotres all registers
# Args: None
# Return: None
#
find_locations_B_restore:


        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra   
        
######################################
#### END Find Location B block    ###
######################################


######################################
#####     PRINT BOARD START        ###
######################################
#
# Name: print_board_start
# Description: init all registers
# Args: a0 - Generation Number For header printing grid
# Return: None
#
print_board_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)

        la      $s0, store_input        #input array
        la      $s1, Board1             #game board
        lw      $s2, 0($s0)             #size of board
        move    $s3, $a0                #generation number

        li      $s6, 0                  #row counter
        li      $s7, 0                  #col counter

        # Prints blank line before banner
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        # Generation Header
        li      $v0, PRINT_STRING
        la      $a0, generation_begin
        syscall  

        # Prints gen number
        li      $v0, PRINT_INT
        move    $a0, $s3
        syscall

        # Generation Header
        li      $v0, PRINT_STRING
        la      $a0, generation_end
        syscall

        # Prints blank line after banner banner
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        # Prints +
        li      $v0, PRINT_CHAR
        lbu     $a0, add_char
        syscall

        j       print_board_dash_top

#
# Name: print_board_dash_top
# Description: dash line at top of board
# Args: None
# Return: None
#
print_board_dash_top:
        # board size == col counter
        beq     $s2, $s7, print_board_temp
        
        # Prints -
        li      $v0, PRINT_CHAR
        lbu     $a0, dash_char
        syscall                 

        addi    $s7, $s7, 1     # col += 1
        j       print_board_dash_top
        
#
# Name: print_board_transition
# Description: prints a plus and a newline
# Args: None
# Return: None
#
print_board_transition:
        # Prints +
        li      $v0, PRINT_CHAR
        lbu     $a0, add_char
        syscall

        # Prints blank line after board
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        jr      $ra

#
# Name: print_board_temp
# Description: just calls a transition and then starts teh body
# Args: None
# Return: None
#
print_board_temp:
        jal     print_board_transition
        j       print_board_body_start

#
# Name: print_board_body_start
# Description: prints a line
# Args: None
# Return: None
#
print_board_body_start:
        # board size == row counter
        beq     $s2, $s6, print_board_dash_bottom_transition

        li      $s7, 0  #reset col counter

        # Prints |
        li      $v0, PRINT_CHAR
        lbu     $a0, line_char
        syscall 

        j       print_board_body_meat

#
# Name: print_board_body_meat
# Description: the MEAT of the board. prints all As, Bs, and spaces
# Args: None
# Return: None
#
print_board_body_meat:
        # counter == col counter
        beq     $s2, $s7, print_board_endline

        # get a copy of col to manipulate              
        move    $t0, $s6        

        mul     $t0, $t0, $s2   #row value * board size  
        add     $t0, $t0, $s7   #add col value to that
        add     $t0, $t0, $s1   #find offset on board

        lbu     $t1, 0($t0)     

        # Print location on board
        li      $v0, PRINT_CHAR
        move    $a0, $t1
        syscall                 

        addi    $s7, $s7, 1     # column += 1

        j       print_board_body_meat

#
# Name: print_board_endline
# Description: prints a line and newline
# Args: None
# Return: None
#
print_board_endline:
        # Prints |
        li      $v0, PRINT_CHAR
        lbu     $a0, line_char
        syscall 

        # Prints blank line after board
        li      $v0, PRINT_STRING
        la      $a0, newline_char
        syscall

        addi    $s6, $s6, 1

        j       print_board_body_start

#
# Name: print_board_dash_bottom_transition
# Description: resets col and prints plus
# Args: None
# Return: None
#
print_board_dash_bottom_transition:
        li      $s7, 0  #reset col counter

        # Prints +
        li      $v0, PRINT_CHAR
        lbu     $a0, add_char
        syscall 

        j       print_board_dash_bottom

#
# Name: print_board_dash_bottom
# Description: prints dashed line at bottom of grid
# Args: None
# Return: None
#
print_board_dash_bottom:
        # board size == col counter
        beq     $s2, $s7, print_board_restore
        
        # Prints -
        li      $v0, PRINT_CHAR
        lbu     $a0, dash_char
        syscall                 

        addi    $s7, $s7, 1     # col += 1
        j       print_board_dash_bottom


#
# Name: print_board_restore
# Description: resotres all registers
# Args: None
# Return: None
#
print_board_restore:
        jal     print_board_transition

        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra   

######################################
######     PRINT BOARD END        #####
######################################
#
# Name: simulation_start
# Description: init all registers and calls print, simulation and copy funcs
# Args: None
# Return: None
#
simulation_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)  

        la      $s0, store_input        #input arr
        lw      $s1, 4($s0)             #num generations
        addi    $s1, $s1, 1
        li      $s7, 0                  #generation counter

#
# Name: simulation_loop
# Description: Loops through printing board, changing board, and copying board
# Args: None
# Return: None
#
simulation_loop:
        # counter == num_generations from input arr
        beq     $s7, $s1, simulation_restore

        move    $a0, $s7        #this is for printing board generation header

        jal     print_board_start
        jal     generation_next_start
        jal     copy_to_board1_start

        addi    $s7, $s7, 1     # += 1

        j       simulation_loop

#
# Name: simulation_restore
# Description: Restores all registers
# Args: None
# Return: None
#
simulation_restore:
        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra   


######################################
#####     Generation Next Start   ####
######################################
#
# Name: generation_next_start
# Description: init all registers
# 
#
generation_next_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp)  

        la      $s0, store_input        #input arr
        lw      $s1, 0($s0)             #board size
        #reset $s0 because we dont care about any other value in arr right now
        mul     $s0, $s1, $s1           #total board size of sim
        la      $s2, Board1             #address of Board1
        la      $s3, BoardCopy          #address of BoardCopy

        li      $s4, 0                  #row counter
        li      $s5, 0                  #col counter

        j       generation_next_neighbors_loop_start

generation_next_neighbors_loop_start:
        #must check where we are
        mul     $t0, $s4, $s5  

        #if counters product == board size, end simulation
        beq     $t0, $s0, generation_next_restore

        li      $s5, 0  #reset col counter to zero

        j       generation_next_neighbors_nested_loop

generation_next_neighbors_nested_loop:
        # Once col count maxes out we must exit to reset and start next row
        beq     $s5, $s1, generation_next_neighbors_loop_end

        li      $s6, 0  #A neighbor counter
        li      $s7, 0  #B neighbor Counter


        # --- NEIGHBOR TIME!!! ---

        #top left
        # [row - 1][col - 1]
        addi    $a0, $s4, -1    #row
        addi    $a1, $s5, -1    #col
        jal     correct_neighbor_start    #takes two args above
        move    $a0, $v0        #correct row
        move    $a1, $v1        #correct col
        jal     find_offset_start
        move    $t9, $v0        #get offset
        add     $a0, $t9, $s2   #get address of where it is on board
        jal     cell_value_start
        add     $s6, $s6, $v0
        add     $s7, $s7, $v1

        #top middle
        # [row - 1][col]
        addi    $a0, $s4, -1    #row
        move    $a1, $s5    #col
        jal     correct_neighbor_start    #takes two args above
        move    $a0, $v0        #correct row
        move    $a1, $v1        #correct col
        jal     find_offset_start
        move    $t9, $v0        #get offset
        add     $a0, $t9, $s2   #get address of where it is on board
        jal     cell_value_start
        add     $s6, $s6, $v0
        add     $s7, $s7, $v1

        #top right
        # [row - 1][col + 1]
        addi    $a0, $s4, -1    #row
        addi    $a1, $s5, 1    #col
        jal     correct_neighbor_start    #takes two args above
        move    $a0, $v0        #correct row
        move    $a1, $v1        #correct col
        jal     find_offset_start
        move    $t9, $v0        #get offset
        add     $a0, $t9, $s2   #get address of where it is on board
        jal     cell_value_start
        add     $s6, $s6, $v0
        add     $s7, $s7, $v1

        #middle left
        # [row][col - 1]
        move    $a0, $s4        #row
        addi    $a1, $s5, -1    #col
        jal     correct_neighbor_start    #takes two args above
        move    $a0, $v0        #correct row
        move    $a1, $v1        #correct col
        jal     find_offset_start
        move    $t9, $v0        #get offset
        add     $a0, $t9, $s2   #get address of where it is on board
        jal     cell_value_start
        add     $s6, $s6, $v0
        add     $s7, $s7, $v1

        #middle right
        # [row][col + 1]
        move    $a0, $s4        #row
        addi    $a1, $s5, 1    #col
        jal     correct_neighbor_start    #takes two args above
        move    $a0, $v0        #correct row
        move    $a1, $v1        #correct col
        jal     find_offset_start
        move    $t9, $v0        #get offset
        add     $a0, $t9, $s2   #get address of where it is on board
        jal     cell_value_start
        add     $s6, $s6, $v0
        add     $s7, $s7, $v1

        #bottom left
        # [row + 1][col - 1]
        addi    $a0, $s4, 1        #row
        addi    $a1, $s5, -1    #col
        jal     correct_neighbor_start    #takes two args above
        move    $a0, $v0        #correct row
        move    $a1, $v1        #correct col
        jal     find_offset_start
        move    $t9, $v0        #get offset
        add     $a0, $t9, $s2   #get address of where it is on board
        jal     cell_value_start
        add     $s6, $s6, $v0
        add     $s7, $s7, $v1

        #bottom middle
        # [row + 1][col]
        addi    $a0, $s4, 1        #row
        move    $a1, $s5    #col
        jal     correct_neighbor_start    #takes two args above
        move    $a0, $v0        #correct row
        move    $a1, $v1        #correct col
        jal     find_offset_start
        move    $t9, $v0        #get offset
        add     $a0, $t9, $s2   #get address of where it is on board
        jal     cell_value_start
        add     $s6, $s6, $v0
        add     $s7, $s7, $v1

        #bottom right
        # [row + 1][col + 1]
        addi    $a0, $s4, 1        #row
        addi    $a1, $s5, 1    #col
        jal     correct_neighbor_start    #takes two args above
        move    $a0, $v0        #correct row
        move    $a1, $v1        #correct col
        jal     find_offset_start
        move    $t9, $v0        #get offset
        add     $a0, $t9, $s2   #get address of where it is on board
        jal     cell_value_start
        add     $s6, $s6, $v0
        add     $s7, $s7, $v1

        # middle
        move    $a0, $s4        #curr row
        move    $a1, $s5        #curr col
        jal     find_offset_start
        move    $a0, $s6        #A cell counter
        move    $a1, $s7        #B cell counter
        move    $a2, $v0        #offset of curr cell
        jal     generation_life_start


        addi    $s5, $s5, 1     # col += 1

        j       generation_next_neighbors_nested_loop
        

generation_next_neighbors_loop_end:
        addi    $s4, $s4, 1     # row += 1

        j       generation_next_neighbors_loop_start


generation_next_restore:
        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra   

######################################
######    Generation Next END   ######
######################################

#
# Name: correct_neighbor_start
# Description: init all registers
# Args: a0 - row pos
#       a1 - col pos
# Return: None
#
correct_neighbor_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp) 

        la      $s0, store_input        #input arr
        #reset $s0 because we dont care about any other value in arr right now
        lw      $s0, 0($s0)             #board size
        move    $s1, $a0                #row
        move    $s2, $a1                #col


#
# Name: correct_neighbor_calc
# Description: Gets correct cell for neighbors
# Args: None
# Return: None
#
correct_neighbor_calc:
        add     $s3, $s1, $s0   # used to account for off the board
        rem     $s3, $s3, $s0   # (row + board_size) % board_size
        add     $s4, $s2, $s0   # 
        rem     $s4, $s4, $s0   # (col + board_size) % board_size

        j       correct_neighbor_restore

#
# Name: correct_neighbor_restore
# Description: Restores all registers
# Args: None
# Return: v0 - row val of neighbor
#         v1 - col value of neighbor
#
correct_neighbor_restore:
        #return cell location for neighbors
        move    $v0, $s3
        move    $v1, $s4

        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra  

#
# Name: find_offset_start
# Description: Init all registers
# Args: a0 - row pos
#       a1 - col pos
# Return: None
#
find_offset_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp) 

        la      $s0, store_input        #input arr
        #reset $s0 because we dont care about any other value in arr right now
        lw      $s0, 0($s0)             #board size
        move    $s1, $a0                #row
        move    $s2, $a1                #col

#
# Name: find_offset_calc
# Description: Calculates where cell should be on board
# Args: None
# Return: None
#
find_offset_calc:
        mul     $s3, $s1, $s0   #row# * board size
        add     $s3, $s3, $s2   #add col value

        j       find_offset_restore


#
# Name: find_offset_restore
# Description: Restores all registers
# Args: None
# Return: v0 - correct offset of cell
#
find_offset_restore:
        #return location where cell is
        move    $v0, $s3

        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra 
#
# Name: cell_value_start
# Description: init all registers
# Args: a0 - address of position on Board1
# Return: None
#
cell_value_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp) 

        lbu     $s0, 0($a0)     #value at spot on Board1

        li      $s1, 0          #A cell counter
        li      $s2, 0          #B cell counter
        li      $s3, A_ascii    #A ascii value
        li      $s4, B_ascii    #B ascii value

        j       cell_value_choose

#
# Name: cell_value_chose
# Description: determine if cell is an A, B or nothing
# Args: None
# Return: None
#
cell_value_choose:
        #if cell is an A
        beq     $s3, $s0, cell_value_A
        #if cell is an b
        beq     $s4, $s0, cell_value_B

        j       cell_value_restore


#
# Name: cell_value_A
# Description: increment A counter
# Args: None
# Return: None
#
cell_value_A:
        addi    $s1, $s1, 1
        j       cell_value_restore

#
# Name: cell_value_B
# Description: increment B counter
# Args: None
# Return: None
#
cell_value_B:
        addi    $s2, $s2, 1
        j       cell_value_restore

#
# Name: cell_value_restore
# Description: Restore all registers
# Args: None
# Return: v0 - A cell counter
#         v1 - B cell counter
#
cell_value_restore:
        #return cell counters
        move    $v0, $s1
        move    $v1, $s2

        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra 

#
# Name: generation_life_start
# Description: init all registers
# Args: a0 - A cell count
#       a1 - B cell count
#       a2 - address of curr cell
# Return: None
#
generation_life_start:
        addi    $sp, $sp, -FRAMESIZE_40   #allocate stackframe
        sw      $ra, -4+FRAMESIZE_40($sp)
        sw      $s7, -8+FRAMESIZE_40($sp)
        sw      $s6, -12+FRAMESIZE_40($sp)
        sw      $s5, -16+FRAMESIZE_40($sp)
        sw      $s4, -20+FRAMESIZE_40($sp)
        sw      $s3, -24+FRAMESIZE_40($sp)
        sw      $s2, -28+FRAMESIZE_40($sp)
        sw      $s1, -32+FRAMESIZE_40($sp)
        sw      $s0, -36+FRAMESIZE_40($sp) 

        move    $s0, $a0        #A cell count
        move    $s1, $a1        #B cell count
        move    $s2, $a2        #address of curr cell

        la      $s3, Board1
        la      $s4, BoardCopy

        add     $s5, $s3, $s2   #curr cell on Board1

        lbu     $s6, 0($s5)     #value at curr cell on Board1

        #check if value is A
        li      $t0, A_ascii
        beq     $t0, $s6, generation_life_A

        #check if value is B
        li      $t1, B_ascii
        beq     $t1, $s6, generation_life_B

        j       generation_life_ressurect


#
# Name: generation_life_A
# Description: Check to bring an A to life
# Args: None
# Return: None
#
generation_life_A:
        sub     $t0, $s0, $s1   #A - B cells

        # if less than 2 As, death
        li      $t1, 2          
        blt     $t0, $t1, generation_life_set_death
        
        # if more than 4 As, death
        li      $t2, 4
        bge     $t0, $t2, generation_life_set_death

        j       generation_life_set_A

#
# Name: generation_life_set_A
# Description: Set cell to A
# Args: None
# Return: None
#
generation_life_set_A:
        add     $t3, $s2, $s4   #position on boardcopy
        li      $t4, A_ascii    #A ascii value
        sb      $t4, 0($t3)     #store A on boardCopy

        j       generation_life_restore

#
# Name: generation_life_B
# Description: Check to bring a B to life
# Args: None
# Return: None
#
generation_life_B:
        sub     $t0, $s1, $s0   #B - A cells

        # if less than 2 As, death
        li      $t1, 2          
        blt     $t0, $t1, generation_life_set_death
        
        # if more than 4 As, death
        li      $t2, 4
        bge     $t0, $t2, generation_life_set_death
        
        j       generation_life_set_B

#
# Name: generation_life_set_B
# Description: Set cell to B
# Args: None
# Return: None
#
generation_life_set_B:
        add     $t3, $s2, $s4   #position on boardcopy
        li      $t4, B_ascii    #B ascii value
        sb      $t4, 0($t3)     #store B on boardCopy

        j       generation_life_restore

#
# Name: generation_life_set_death
# Description: Set cell to death
# Args: None
# Return: None
#
generation_life_set_death:
        # puts a space on teh cell location, killing it
        add     $t3, $s2, $s4   #position on boardcopy
        li      $t4, Space_ascii    #space ascii value
        sb      $t4, 0($t3)     #store space on boardCopy

        j       generation_life_restore

#
# Name: generation_life_ressurect
# Description: Bring a cell to life
# Args: None
# Return: None
#
generation_life_ressurect:
        sub     $t0, $s0, $s1   #A - B cells
        sub     $t1, $s1, $s0   #B - A cells

        li      $t2, 3          #only value to ressurect cell

        # if 3 A neighbors, bring A to life
        beq     $t0, $t2, generation_life_set_A

        # if 3 B neighbors, bring B to life
        beq     $t1, $t2, generation_life_set_B

        j       generation_life_set_death

#
# Name: generation_life_restore
# Description: Restore all registers
# Args: None
# Return: None
#
generation_life_restore:
        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra 

#
# Name: main restore
# Description: Restores all registers in stack frame
# Args: None
# Return: None
#
main_restore:
        #must restore all registers 
        lw      $ra, -4+FRAMESIZE_40($sp)
        lw      $s7, -8+FRAMESIZE_40($sp)
        lw      $s6, -12+FRAMESIZE_40($sp)
        lw      $s5, -16+FRAMESIZE_40($sp)
        lw      $s4, -20+FRAMESIZE_40($sp)
        lw      $s3, -24+FRAMESIZE_40($sp)
        lw      $s2, -28+FRAMESIZE_40($sp)
        lw      $s1, -32+FRAMESIZE_40($sp)
        lw      $s0, -36+FRAMESIZE_40($sp)
        addi    $sp, $sp, FRAMESIZE_40          #clean up stack

        jr      $ra   

#####################################
#####   END OF COLONY ROUTINE   #####
#####################################
