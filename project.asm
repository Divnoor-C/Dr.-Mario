################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
    

Width:     
    .word 23      # Width of the box
Height:    
    .word 25        # Height of the box
Color:  
    .word 0xffffff  # Grey border color


##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    lw $t0, ADDR_DSPL   # $t0 = base address for display
    addi $t0, $t0, 648 # start at 8 line
    
    lw $t1, Color       # load color

    lw $a0, Width   # load width
    lw $a1, Height  # load height

    add $t2, $t0, $zero      # Starting x
    add $t3, $t0, $zero     # Starting y
    
    addi $t7, $zero, 2
    div $t4, $a0, $t7
    sub $t4, $t4, $t7       # t4 Has value of howmany pixels will be drawn for first half of top
    
    addi, $t7, $zero, 0 
    
draw_top_first:
    beq $t4, $t7, draw_top_second_before # Check if all first half of top is drawn
    sw $t1, 0($t2)  # Drawing pixel
    addi $t7, $t7, 1
    addi $t2, $t2, 4
    j draw_top_first


draw_top_second_before:
    add $t6, $t2, $zero
    sw $t1, -132($t2) # adds left pixel at the top
    addi, $t2, $t2, 20 # This creates gap at the top to be 5 pixels
    sw $t1, -128($t2) # adds right pixel at the top
    addi, $t7, $zero, 0


draw_top_second:
    beq $t4, $t7, draw_vertical_before # Check if all second half of top is drawn
    sw $t1, 0($t2)  # Drawing pixel
    addi $t7, $t7, 1
    addi $t2, $t2, 4
    j draw_top_second
    
# At the end t2 has value of ending x
draw_vertical_before: 
    addi, $t7, $zero, 0
    add, $t5, $t0, $t5 


draw_vertical:
    beq $a1, $t7, draw_buttom_before # Check if all second half of top is drawn
    
    sw $t1, 0($t2)  # Drawing pixel
    sw $t1, 0($t5)  # Drawing pixel
    
    addi $t7, $t7, 1
    addi $t2, $t2, 128
    addi $t5, $t5, 128
    j draw_vertical
  
# At end t5 has first pixel of buttom boundary
draw_buttom_before:
    addi, $t7, $zero, -1  # Handles off by one case, if 0, we miss buttom right pixel
    
draw_buttom:
    beq $a0, $t7, first_capsule # Check if all first half of top is drawn
    sw $t1, 0($t5)  # Drawing pixel
    addi $t7, $t7, 1
    addi $t5, $t5, 4
    j draw_buttom
    
    first_capsule:
    sw $t1 8($t6)
    sw $t1, -120($t6)  # Drawing pixel
	li $v0, 10                      # Quit gracefully
	syscall
	
game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop
