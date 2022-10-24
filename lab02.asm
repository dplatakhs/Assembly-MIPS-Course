
# lab02.asm - Binary search in an array of 32bit signed integers
#   coded in  MIPS assembly using MARS
# for MYΥ-505 - Computer Architecture, Fall 2020
# Department of Computer Science and Engineering, University of Ioannina
# Instructor: Aris Efthymiou

        .globl bsearch # declare the label as global for munit
        
###############################################################################
        .data
sarray: .word 1, 5, 9, 20, 321, 432, 555, 854, 940

###############################################################################
        .text 
# label main freq. breaks munit, so it is removed...
        la         $a0, sarray
        li         $a1, 9
		li         $a2, 1  # the number sought


bsearch:
###############################################################################
# Write you code here.
# Any code above the label bsearch is not executed by the tester! 
###############################################################################
	counters:
		srl	$t0, $a1, 1 #index of middle
		#!!!!!!!!!!!!!!!!1 den prepei na paiksw me k0,k1, tha to allaksw
		li	$t6, 0 #index of start
		li	$t7, 9 #index of end
		la	$s6, sarray	#s6 will be a fake array to get our values
		sll	$t1, $t0, 2	#middle multiplied by 4 so we can "have" it on bits
		add	$s6, $t1, $s6	#fakeArray <= middle
	
	
	

	loop:
		lw 	$s0, 0($s6)	#get the middle element		
		slt	$t8, $s0, $a2	

		beq	$s0, $a2, exitSuccess	  #if middle == goal, exit suceessfuly
		beq	$t6, $t7, exitFailure	  #if (index)end == (index)start we failed
		beq	$zero, $t8, goTotheLeft  #if middle is greater than our goal go to the lower half of the array
		j	goTotheRight		  #else go the upper half of the array
	

	goTotheLeft:
		sub	$t7, $t7, $t7
		add	$t7, $t7, $t0 #(index)end <== (index)middle

		sub	$t0, $t7, $t6
		srl	$t0, $t0, 1	#(index)middle / 2
		#----
		beq	$t0, $zero, specialLeft 
		sub	$t0, $t7, $t0		
		#----
		sll	$t1, $t0, 2	#(index)middle * 4
		la	$s6, sarray	#set fakeArray(s6) to the START of the array
		add	$s6, $t1, $s6
		j	loop
		
	#changespecialLeft
	specialLeft:
		li $t0, 1		#here if there is distance of 1 between end and start
		sub $t7, $t7, $t0	#we take care of the infinite loop
		j loop
		
	goTotheRight:
		sub	$t6, $t6, $t6 
		add	$t6, $t6, $t0 #(index)start <== (index)middle
		
		sub	$s4, $t7, $t6
		srl	$s4, $s4, 1	#I am dividing (index)middle/2 and adding it later(line 79) to the (index)start 
					
		#change
		beq	$s4, $zero, specialRight 
		add	$t0, $t0, $s4	#here is the addition
		#change
		
		sll	$t1, $t0, 2		
		la	$s6, sarray	#set fakeArray(s6) to the START of the array
		add	$s6, $t1, $s6
		j	loop
	
	specialRight:
		li $t0, 1
		add $t6, $t6, $t0	#we take care of the infinite loop
		j loop
		   
	exitSuccess:
		li	$s7, 0
		add 	$s7, $s7, $s6 #we take the ADDRESS of our goal
		j	exit
	
	exitFailure:
		li	$s7, 0 	      #we failed, s7 <== 0
		j	exit

	

###############################################################################
# End of your code.
###############################################################################
exit:
        addiu      $v0, $zero, 10    # system service 10 is exit
        syscall                      # we are outta here.


