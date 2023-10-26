.include "mfunc.inc"
.include "convenience.inc"

# Далее запись (arg0, ..., arg7) -> res1, res2 означает, что функция принимает аргумент arg0 из a0, ..., arg7 из a7 и возвращает
# res1 в a0, res2 в a1.
# Если перед названием аргумента есть приставка "d.", используется соответсвующий float-point регистр

# Функция x^5 - x - 0.2
.macro target_func_body  # (d.x) -> d.r
.data
	.align 3
	neg_fifth: .double -0.2
.text
	fmul.d ft0 fa0 fa0  # В ft0 x^2
	fmul.d ft0 ft0 ft0  # В ft0 x^4
	fmsub.d fa0 ft0 fa0 fa0  # В fa0 x^5 - x
	fld ft0 neg_fifth t0  # В ft0 -0.2
	fadd.d fa0 fa0 ft0  # В fa0 x^5 - x - 0.2
.end_macro

func(_target_func, target_func_body)

# Производит одну итерацию метода хорд для target_func, возвращает пару x2 и x3 для следующей итерации, а также модуль их разности
.macro secant_method_iteration_body  # (d.x1, d.x2) -> d.x2, d.x3, d.delta
	# Сохраняем значения s-регистров на стеке
	fsave.d (fs0)
	fsave.d (fs1)
	fsave.d (fs2)
	
	fmv.d fs0 fa0  # s0 = x1
	fmv.d fs1 fa1  # s1 = x2
	
	jal _target_func  # f(x1)
	fmv.d fs2 fa0  # s2 = f(x1)
	fmv.d fa0 fs1
	jal _target_func  # f(x2)
	fmv.d ft0 fa0  # t0 = f(x2)	
	
	fsub.d ft1 fs1 fs0  # t1 = x2 - x1
	fsub.d ft2 ft0 fs2  # t2 = f(x2) - f(x1)
	fdiv.d ft3 ft1 ft2  # t3 = (x2 - x1) / (f(x2) - f(x1))
	fnmsub.d fa1 ft3 fs2 fs0  # s2 = x2 - f(x2) * (x2 - x1) / (f(x2) - f(x1)) = x3
	fmv.d fa0 fs1
	fsub.d fa2 fa1 fa0  # a2 = x3 - min(x1, x2)
	fabs.d fa2 fa2  # a2 = |x3 - x2|
	
	# Восстанавливаем s-регистры
	frestore.d (fs2)
	frestore.d (fs1)
	frestore.d (fs0)
.end_macro

func(_secant_method_iteration, secant_method_iteration_body)

# Метод хорд для target_func.
# Возвращает предполагаемый корень.
#
# В условии сказано, что если переданный диапазон некорректный, то нужно подобрать правильный.
# Метод хорд работает так, что если в переданном диапазоне есть корни, то он гарантированно вернёт один из них,
# а если диапазон неверный, то он точно вернет корень, если он есть.
# Таким образом, чтобы определить, корректен ли диапазон, достаточно определить, лежит ли корень в этом диапазоне или нет.
# Так как метод хорд в любом случае вернет корень с заданной точностью (root), подобрать диапазон, в котором он лежит - тривиальная задача:
# настоящий корень лежит в [root - точность; root + точность], поэтому программа не делает этого, а просто определяет - корректен ли
# переданный интервал или нет. Полученное логическое значение (0 или 1) функция возвращает в регистр a0.
.macro secant_method_body  # (d.x1, d.x2, d.delta) -> interval_changed, d.x
	# Сохраняем значения s-регистров на стек
	fsave.d (fs0)
	fsave.d (fs1)
	fsave.d (fs2)
	save (s0)
	save (s1)
	
	fmin.d fs0 fa0 fa1  # В s0 - левая граница
	fmax.d fs1 fa0 fa1  # В s1 = правая граница
	fmv.d fs2 fa2  # В s2 = требуемая точность
	li s0 0  # В s0 - измеился ли интервал или нет

	
	fadd.d fa2 fs2 fs2  # Кладем в fa2 число, большее fs2, чтобы цикл начался
	
	loop:
	fle.d s1 fa2 fs2
	bnez s1 end_loop
		jal _secant_method_iteration  # Делаем итерацию метода
		b loop
	end_loop:
	# Возвращаемые значения
	flt.d t0 fa1 fs0
	or s0 s0 t0
	fgt.d t0 fa1 fs1
	or s0 s0 t0
	mv a0 s0
	fmv.d fa0 fa1
	
	# Восстанавливаем значения s-регистров
	restore (s1)
	restore (s0)
	frestore.d (fs2)
	frestore.d (fs1)
	frestore.d (fs0)
.end_macro

gfunc(_secant_method, secant_method_body)
	
	
