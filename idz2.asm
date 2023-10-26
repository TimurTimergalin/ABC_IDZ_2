.include "convenience.inc"
.include "io.inc"
.include "math.inc"

.global main
.data
	.align 3
	dlb: .double 0.00000001
	drb: .double 0.001
	# Диапазон из условия
	lb: .double 1
	arb: .double 1.1
	# Некорректный диапазон (для демонстрации работы)
	# alb: .double 1.1
	# arb: .double 1.2
	
.text
main:
	input_delta (dlb, drb, t0)
	fmv.d ft0 fa0
	secant_method (alb, arb, ft0, t0)
	print_results (fa0, a0)
	exit ()
 
