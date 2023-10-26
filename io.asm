.include "convenience.inc"
.include "mfunc.inc"

.macro input_delta_body  # (d.left_boundary, d.right_boundary) -> d.number
.data
	sinput: .asciz "Введите число от "
	sto: .asciz "до "
	scolon: .asciz ": "
	serror: .asciz "Ошибка: число не попадает в заданный диапазон\n"
.text
	fmin.d ft0 fa0 fa1
	fmax.d ft1 fa0 fa1
	
	print_str (sinput)
	print_double ()
	print_char (' ')
	print_str (sto)
	print_double (fa1)
	print_str (scolon)
	
	li a7 7
	ecall
	fle.d t0 fa0 ft1
	fge.d t1 fa0 ft0
	beqz t0 error
	beqz t1 error
	b valid
	error:
		print_str (serror)
		exit (1)	
	valid:
.end_macro

gfunc(_input_delta, input_delta_body)

.macro print_results_body  # (d.x, ch)
.data
	sans1:.asciz "Корень x^5 - x - 0.2 равен "
	schanged: .asciz " (в исходном диапозоне корней нет)"
.text
	fmv.d ft0 fa0
	mv t0 a0
	
	print_str (sans1)
	print_double (ft0)
	
	beqz t0 end
		print_str (schanged)
	end:
	print_char ('\n')
.end_macro

gfunc(_print_results, print_results_body)
