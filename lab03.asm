
# DO NOT DELCARE main IN THE .globl DIRECTIVE. BREAKS MUNIT!
          .globl strcmp, rec_b_search

          .data

aadvark:  .asciiz "aadvark"
ant:      .asciiz "ant"
elephant: .asciiz "elephant"
gorilla:  .asciiz "gorilla"
hippo:    .asciiz "hippo"
empty:    .asciiz ""

          # make sure the array elements are correctly aligned
          .align 2
sarray:   .word aadvark, ant, elephant, gorilla, hippo
endArray: .word 0  # dummy

.text

main:
            la   $a0, empty
            addi $a1, $a0,   0 # 16
	    
            #jal  strcmp

            la   $a0, sarray
            la   $a1, endArray
			addi $a1, $a1,     -4  # point to the last element of sarray
            la   $a2, hippo
            
            addi $sp, $sp, -12		#make room for a0,a1 AND v0
	    sw $a1, 8($sp)		#push a0	!!! I ADDED THESE 4 LINES !!!
	    sw $a0, 4($sp)		#push a1
	    sw $v0, 0($sp)
	    
            jal  rec_b_search

            addiu      $v0, $zero, 10    # system service 10 is exit
            syscall                      # we are outa here.
 

# a0 - address of string 1
# a1 - address of string 2
strcmp:
######################################################
#  strcmp code here!
	
	### this function will receive a stack {goal(top), mid(bottom)} and will return a stack
	### that's {result(top), goal(middle), mid(bottom)} 
	
	add $s0, $zero, $zero 	#i=0
	lw $a0, 0($sp)		#pop(a0)
	lw $a1, 4($sp)		#pop(a1)
	addi $sp, $sp, 8	#delete 2 positions in the stack
	
	
	loop:
		add $t6, $a0, $s0	#get address of a0(goal)
		add $t7, $a1, $s0	#get address of a1(mid)
		#lw $t0, 0($t6)		#go to where a0 points
		#lw $t2, 0($t7)		#go to where a1 points
		
    		lb $t0, 0($t6)		#get first bit of t6. IMPORTANT: t0 = goal
    		lb $t2, 0($t7)		#get first bit of t7. IMPORTANT: t2 = mid

    		beq $t0, $t2, equalBits #if they have equal 1 bit, go to the next one 
    		
    		slt $s5, $t0, $t2		#if t0 < t2, s5<=1 ||||| t0=goal, t2=mid
    		beq $s5, $zero, upperHalf	#now if t0>t2 that means the goal is on the upper half
  		  		
    		j   lowerHalf			#now if t0<t2 that means the goal is on the lower half
    		

	upperHalf:
		addi $sp, $sp, -12	#make room for a0,a1 AND v0
    		addi $v0, $zero, 2	#v0 = 2, it's on the upper half
		sw $a1, 8($sp)		#push a1, first we push our mid
		sw $a0, 4($sp)		#push a0, then we push our goal
		sw $v0, 0($sp)		#we push our result, so we return a stack: {result(top), goal(middle), mid(bottom)} 
		j skip
	lowerHalf:
		addi $sp, $sp, -12	#make room for a0,a1 AND v0
    		addi $v0, $zero, 0	#v0 = 0, it's on the lower half
		sw $a1, 8($sp)		#push a1
		sw $a0, 4($sp)		#push a0
		sw $v0, 0($sp)		#we push our result, so we return a stack: {result(top), goal(middle), mid(bottom)} 
		j skip
	equalBits:		    		
    		addi $s0, $s0, 1	   #i++, to get to the next bit
    		beq $t0, $zero, success   #they are EQUAL and they have reached the end
		j loop
	success:
		addi $sp, $sp, -12	#make room for a0,a1 AND v0
		addi $v0, $zero, 1	#v0 = 1, WE FOUND IT!
		sw $a1, 8($sp)		#push a1, first we push our mid
		sw $a0, 4($sp)		#push a0, then we push our goal
		sw $v0, 0($sp)		#we push our result, so we return a stack: {result(top), goal(middle), mid(bottom)} 
		j skip			
    	skip:
    		j rec_b_search 
######################################################
            jr   $ra


# a0 - base address of array
# a1 - address of last element of array
# a2 - pointer to string to try to match
rec_b_search:
######################################################
#  rec_b_search code here!
	lw $s7, 0($sp)		#we receive a stack: {result(top), goal(middle), mid(bottom)}, so we pop the first element
	lw $a0, 4($sp)		#pop(a0) the start
	lw $a1, 8($sp)		#pop(a1) the end
	addi $sp, $sp, 12	#delete 2 positions in the stack
	
	sub $a3, $a1, $a0	#it overflows we we do: mid = (start + middle)/2 so we
	sra $a3, $a3, 1		#mid = start + (end - start)/2
	add $a3, $a3, $a0
	
	addi $sp, $sp, -8	#make room for a3(mid) and a2(goal)
	sw $a3, 4($sp)		#push a3(mid)
	sw $a2, 0($sp)		#push a2, so we return a stack: {goal(at the top), mid(at the bottom)}
	jal  strcmp
	#and now we receive a stack from compare:{result(v0|on the top), goal(a2|in the middle), mid(a3\ at the bottom)}
	lw $t8, 0($sp)		#pop(v0) the result of our
	lw $a2, 4($sp)		#pop(a2), because we assume that it has change, as we were told in the class
	lw $a3, 8($sp)		#pop(a3), again we pop our mid because we assume it has changed
	addi $sp, $sp, 12	#delete 3 positions in the stack
	
	beq $t8, $zero, exit	#if res==0 we succeeded
	
	slt $s5, $t8, $zero	#if t8 < 0, s5<=1 ||||| go to upperHalf
	beq $s5, $zero, upperJump #we check the opposite, if t8>0
	#here we continue working on the lowerHalf
	lw $a1, 0($a3) 		#a0<--mid, end goes to mid
	addi $sp, $sp, -8
	sw $a1, 4($sp) #we loop with a stack = {start(top|a0), end(bottom|a1)}
	sw $a0, 0($sp)
	j rec_b_search
	
	upperJump:
		sw $a0, 0($a3) #a0<--mid, start goes to mid
		addi $sp, $sp, -8
		sw $a1, 4($sp) #we loop with a stack = {start(top|a0), end(bottom|a1)}
		sw $a0, 0($sp)
		j rec_b_search
	exit:
		lw $v0, 0($a3) #we push our result since we know result==0
		addi $sp, $sp, -4
		sw $v0, 0($sp)
		
######################################################
            jr   $ra


