.include "convenience.inc"
.include "math.inc"

.data
	# mzr - корень, посчитанный до машииного нуля
	# pr - точность
	# lb - левая граница
	# rb - правая граница
	# out - вышел ли корень за пределы интревала
	
	.align 3
	mzr1: .double 1.0447617000755527
	pr1: .double 0.00001
	lb1: .double 1
	rb1: .double 1.1
	.eqv out1 0
	
	mzr2: .double 1.0447617000755527
	pr2: .double 0.0001
	lb2: .double 1.1
	rb2: .double 1.2
	.eqv out2 1
	
	mzr3: .double -0.9420868656245839
	pr3: .double 0.000001
	lb3: .double -1
	rb3: .double -0.5
	.eqv out3 0
	
	mzr4: .double -0.20032258905094197
	pr4: .double 0.00000001
	lb4: .double -0.5
	rb4: .double 0
	.eqv out4 0
	
	mzr5: .double -0.9420868656245839
	pr5: .double 0.00001
	lb5: -100
	rb5: -10
	.eqv out5 1
	
	stestcase: .asciz "Testcase "
	sok: .asciz "OK\n"
	serr_out: .asciz "Ошибка: неверная оценка вхождения в диапазон\n"
	scorr: .asciz "Должно быть: "
	sact: .asciz "Вывод: "
	
	serr_prec: .asciz "Ошибка: недостаточная точность\n"
	scorr_root: .asciz "Корень (с точностью до машинного нуля): "
	sprec: .asciz "Необходимая точность: "
	sdiff: .asciz "Модуль разности: "

.macro testcase (%num, %mzr, %pr, %lb, %rb, %out)
.text
	print_str (stestcase)
	li a0 %num
	print_int ()
	print_char (' ')
	print_char ('|')
	print_char (' ')
	
	fld fs0 %pr t0
	fld fs1 %mzr t0
	li s0 %out
	
	secant_method (%lb, %rb, fs0, t0)
	mv t0 a0
	
	beq s0 a0 check_prec  # если out неправильный
		print_str (serr_out)
		print_str (scorr)
		print_int (s0)
		nl()
		print_str (sact)
		print_int (t0)
		nl()
		b end
		
	check_prec:
	fsub.d ft0 fa0 fs1
	fabs.d ft0 ft0
	fle.d t0 ft0 fs0
	fmv.d ft1 fa0
	
	bnez t0 ok  # Если корень недостаточно точный
		print_str (serr_prec)
		print_str (scorr_root)
		print_double (fs1)
		nl()
		print_str (sact)
		print_double (ft1)
		nl()
		print_str (sprec)
		print_double (fs0)
		nl()
		print_str (sdiff)
		print_double (ft0)
		nl()
		b end
	ok:
	
	print_str (sok)
	
	end:
.end_macro

.globl main

.text
main:
	testcase (1, mzr1, pr1, lb1, rb1, out1)
	testcase (2, mzr2, pr2, lb2, rb2, out2)
	testcase (3, mzr3, pr3, lb3, rb3, out3)
	testcase (4, mzr4, pr4, lb4, rb4, out4)
	testcase (5, mzr5, pr5, lb5, rb5, out5)
	exit ()