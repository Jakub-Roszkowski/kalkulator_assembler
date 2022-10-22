.data		


message:	.asciiz		"\n Podaj RÛwnanie \n"
buffert: 	.asciiz 	"\n Jaka operacje chcesz wykonac \n 0 - M+ \n 1 - M- \n 2 - MC \n 3 - Mr \n 4 - wyjdü z opcji bufora \n"
variable0:	.float 		0
variable1:	.float 		1
errord: 	.asciiz 	"\n nie dziel przez 0"
size:		.space		101		


.text



main:		
		la	$s0, size		
			
		la	$a0, message
		li	$v0, 4
		syscall
		
		la	$a0, size		
		li	$a1, 101		
		jal	input		
		
		lw	$t0, ($sp)		
		mtc1    $t0, $f7
		mtc1	$t0, $f12		

		li	$v0, 2
		syscall
		
		buffer: 
			la $a0,buffert
			li $v0, 4
			syscall	

			li $v0, 5
			syscall
		
			move $t4, $v0 
			beq $t4, 0,Mp
			beq $t4, 1,Mm
			beq $t4, 2,Mc
			beq $t4, 3,Mr
		
			add   $t5,$zero,10
			beq $t5,10,main
		
			Mp:
				add.s $f6,$f6,$f7
				b buffer
			Mm:
				sub.s $f6,$f6,$f7
				b buffer
			Mc:
				lwc1 $f6,variable0
				b buffer
			Mr:		
				mov.s $f12, $f6
				li	$v0, 2
				syscall
		
			j	main

input:
		li	$v0, 8			
		syscall 
calculation:		
		addi	$sp, $sp, -4		
		sw	$ra, ($sp)	
		jal	term
		
calculation_loop:
		lb	$t2, ($s0)		
		sne	$t3, $t2, 0	#null	
		seq	$t4, $t2, 45	#-	
		seq	$t5, $t2, 43	#+	
		
		
		addi	$sp, $sp, -4
		sw	$t5, ($sp)		
				
		or	$t4, $t4, $t5		
		and	$t3, $t3, $t4
		beq	$t3, 0, calculation_return
		addi	$s0, $s0, 1		
		
		jal	term
		
		lw	$t4, ($sp)		
		addi	$sp, $sp, 4
		lw	$t5, ($sp)		
		addi	$sp, $sp, 4
		lw	$t6, ($sp)		

		
		mtc1	$t6, $f2		
		mtc1	$t4, $f4		

		beq	$t5, 0, calculation_sub
		beq	$t5, 1, calculation_add
		
		
calculation_sub:
		
		sub.s	$f2, $f2, $f4		
		swc1	$f2, ($sp)		
		j	calculation_loop
calculation_add:
		add.s	$f2, $f2, $f4		
		swc1	$f2, ($sp)			
		j	calculation_loop

calculation_return:
		addi	$sp, $sp, 4
		lw	$t0, ($sp)		
		addi	$sp, $sp, 4
		lw	$ra, ($sp)		
		sw	$t0, ($sp)		
		jr	$ra
term:		
		addi	$sp, $sp, -4		
		sw	$ra, ($sp)
		jal	termi
		
term_loop:
		lb	$t2, ($s0)		
		sne	$t3, $t2, 0	#null	
		seq	$t4, $t2, 47	#/	
		seq	$t5, $t2, 42	#*	
		
		addi	$sp, $sp, -4
		sw	$t5, ($sp)		
				
		or	$t4, $t4, $t5		
		and	$t3, $t3, $t4
		beq	$t3, 0, term_return
		addi	$s0, $s0, 1		
		
		jal	termi
		
		lw	$t4, ($sp)		
		addi	$sp, $sp, 4
		lw	$t5, ($sp)		
		addi	$sp, $sp, 4
		lw	$t6, ($sp)		

		mtc1	$t6, $f2		
		mtc1	$t4, $f4			
		beq	$t5, 1, term_mul
		
term_div:	mov.s 	$f5,$f4
		add   	$t4,$zero,$zero
		cvt.w.s $f4, $f4
		mfc1 	$t2, $f4
		
		beq	$t2,$t4,derror
			
		div.s 	$f3,$f2,$f5
		b enddiv
		
		derror:
			la $a0,errord
			li $v0,4
			syscall 
				
			j main
			
		enddiv:	
		swc1	$f3, ($sp)		
		j	term_loop
		
term_mul:	mul.s	$f2, $f2, $f4		
		swc1	$f2, ($sp)		
		j	term_loop

term_return:	addi	$sp, $sp, 4
		lw	$t0, ($sp)		
		addi	$sp, $sp, 4
		lw	$ra, ($sp)		
		sw	$t0, ($sp)		
		jr	$ra
termi:		
		addi	$sp, $sp, -4		
		sw	$ra, ($sp)
		jal	brackets
		
termi_loop:
		lb	$t2, ($s0)		
		sne	$t3, $t2, 0	#null	
		seq	$t4, $t2, 94	#^		
		
		addi	$sp, $sp, -4
		sw	$t5, ($sp)		
					
		and	$t3, $t3, $t4
		beq	$t3, 0, term_return
		addi	$s0, $s0, 1		
		
		jal	brackets
		
		lw	$t4, ($sp)		
		addi	$sp, $sp, 4
		lw	$t5, ($sp)		
		addi	$sp, $sp, 4
		lw	$t6, ($sp)
		
		mtc1	$t6, $f2				
		mtc1	$t4, $f4			
		
		
termi_exponentiation:
		
		lwc1 $f3, variable1
		cvt.w.s $f4, $f4
		mfc1 $t2, $f4
		
		add   	$t5,$zero,$zero
			blt $t2,$t5,ex
			beq $t2,$t5,e
		a:	
		add   $t4,$zero,1
		lwc1 $f3, variable0
		add.s $f3,$f3,$f2
		
		loop: 	beq $t2,$t4,e
			addi $t4,$t4,1
			mul.s $f3,$f3,$f2
			j loop
		e:
		swc1	$f3, ($sp)		
		j	termi_loop					
		ex:
		lwc1 $f4, variable1
		div.s $f2,$f4,$f2
		mul $t2,$t2,-1
		b a

termi_return:	addi	$sp, $sp, 4
		lw	$t0, ($sp)		
		addi	$sp, $sp, 4
		lw	$ra, ($sp)		
		sw	$t0, ($sp)		
		jr	$ra
brackets:
		
		addi	$sp, $sp, -4
		sw	$ra, ($sp)		
		
		lb	$t0, ($s0)				
		bne	$t0, 40, no_new_brackets  #(
		
		addi	$s0, $s0, 1		
		jal	calculation		
		lb	$t0, ($s0)		
		sne	$t1, $t0, 41 	#)		
		seq	$t2, $t0, 0
		or	$t1, $t1, $t2		
		
		addi	$s0, $s0, 1		
		j	brackets_return

no_new_brackets:		
		jal	number
		
brackets_return:	
		lw	$t0, ($sp)
		addi	$sp, $sp, 4
		lw	$ra, ($sp)
		sw	$t0, ($sp)
		jr	$ra

number:		
		lb	$t1, ($s0)				
		seq     $t9, $t1, 77	#M
		beq 	$t9, 1, m
		seq     $t8, $t1, 80	#P
		beq 	$t8, 1, p
	
		li	$t0, 0		#d≥ugosc
				
number_loop:	lb	$t1, ($s0)		
		sle	$t2, $t1, 57	#9
		sge	$t3, $t1, 48	#0
		and	$t3, $t2, $t3		
		
		addi	$t0, $t0, 1		
		addi	$s0, $s0, 1		
		beq	$t3, 1, number_loop	
		
		addi	$t0, $t0, -1		
		move	$t1, $t0	#zamiana zapisu dlugosci	
		li	$t5, 1
		li	$t6, 0			
		li	$t7, 10
		addi	$s0, $s0, -2		
		
		li	$v0, 0
convert_loop:	lb	$t4, ($s0)		
		addi	$t4, $t4, -48	#0 w ASCII ma wartosc 48	
		addi	$t1, $t1, -1		
		mul	$t4, $t4, $t5		
		add	$t6, $t6, $t4		
		
		mul	$t5, $t5, $t7		
		addi	$s0, $s0, -1		
		bne	$t1, 0, convert_loop
		
		
		add	$s0, $s0, $t0		
		addi	$s0, $s0, 1	
		
		lb	$t1, ($s0)
		seq	$t8, $t1, 33	#! silnia
		beq 	$t8, 1, s
		
		lb	$t1, ($s0)
		seq	$t9, $t1, 96	#` odwrotnosc
		beq 	$t9, 1, od
		
						
number_return:	mtc1	$t6, $f0		
		cvt.s.w	$f0, $f0
		addi	$sp, $sp, -4
		swc1	$f0, ($sp)		
		jr	$ra			
		
m:	
		addi	$sp, $sp, -4
		swc1	$f6, ($sp)	
		addi	$s0, $s0, 1	
		jr	$ra	
p:	
		addi	$sp, $sp, -4
		swc1	$f7, ($sp)	
		addi	$s0, $s0, 1	
		jr	$ra		
		
s:		
		mtc1	$t6, $f0		
		cvt.s.w	$f0, $f0
			add   $t4,$zero,1
			add   $t5,$zero,$zero
			lwc1 $f3,variable1
			lwc1 $f4,variable1
			lwc1 $f5,variable1
			#konwersja float na int i zapis w rejestrze t1
			cvt.w.s $f0, $f0
			mfc1 $t1, $f0
			
			bgt $t1,$t5,loop2
			beq $t1,$t5,end
			
		
			loop2: beq $t1,$t4,end
				addi $t4,$t4,1
				add.s $f4,$f4,$f5
				mul.s $f3,$f3,$f4
				b loop2
		end:
		addi	$sp, $sp, -4
		swc1	$f3, ($sp)	
		addi	$s0, $s0, 1	
		jr	$ra	
		
		
od:		mtc1	$t6, $f1		
		cvt.s.w	$f1, $f1
		mov.s $f5,$f1
		#konwersja float na int i zapis w rejestrze t1
		cvt.w.s $f1, $f1
		mfc1 $t1, $f1
		add   $t4,$zero,$zero
		
		beq $t1,$t4,derror
			
		lwc1 $f4, variable1
		div.s $f3,$f4,$f5
		b endo
		
		endo:
		addi	$sp, $sp, -4
		swc1	$f3, ($sp)	
		addi	$s0, $s0, 1	
		jr	$ra
