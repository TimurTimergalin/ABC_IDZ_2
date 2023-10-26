.include "mfunc.inc"
.include "convenience.inc"

# ����� ������ (arg0, ..., arg7) -> res1, res2 ��������, ��� ������� ��������� �������� arg0 �� a0, ..., arg7 �� a7 � ����������
# res1 � a0, res2 � a1.
# ���� ����� ��������� ��������� ���� ��������� "d.", ������������ �������������� float-point �������

# ������� x^5 - x - 0.2
.macro target_func_body  # (d.x) -> d.r
.data
	.align 3
	neg_fifth: .double -0.2
.text
	fmul.d ft0 fa0 fa0  # � ft0 x^2
	fmul.d ft0 ft0 ft0  # � ft0 x^4
	fmsub.d fa0 ft0 fa0 fa0  # � fa0 x^5 - x
	fld ft0 neg_fifth t0  # � ft0 -0.2
	fadd.d fa0 fa0 ft0  # � fa0 x^5 - x - 0.2
.end_macro

func(_target_func, target_func_body)

# ���������� ���� �������� ������ ���� ��� target_func, ���������� ���� x2 � x3 ��� ��������� ��������, � ����� ������ �� ��������
.macro secant_method_iteration_body  # (d.x1, d.x2) -> d.x2, d.x3, d.delta
	# ��������� �������� s-��������� �� �����
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
	
	# ��������������� s-��������
	frestore.d (fs2)
	frestore.d (fs1)
	frestore.d (fs0)
.end_macro

func(_secant_method_iteration, secant_method_iteration_body)

# ����� ���� ��� target_func.
# ���������� �������������� ������.
#
# � ������� �������, ��� ���� ���������� �������� ������������, �� ����� ��������� ����������.
# ����� ���� �������� ���, ��� ���� � ���������� ��������� ���� �����, �� �� �������������� ����� ���� �� ���,
# � ���� �������� ��������, �� �� ����� ������ ������, ���� �� ����.
# ����� �������, ����� ����������, ��������� �� ��������, ���������� ����������, ����� �� ������ � ���� ��������� ��� ���.
# ��� ��� ����� ���� � ����� ������ ������ ������ � �������� ��������� (root), ��������� ��������, � ������� �� ����� - ����������� ������:
# ��������� ������ ����� � [root - ��������; root + ��������], ������� ��������� �� ������ �����, � ������ ���������� - ��������� ��
# ���������� �������� ��� ���. ���������� ���������� �������� (0 ��� 1) ������� ���������� � ������� a0.
.macro secant_method_body  # (d.x1, d.x2, d.delta) -> interval_changed, d.x
	# ��������� �������� s-��������� �� ����
	fsave.d (fs0)
	fsave.d (fs1)
	fsave.d (fs2)
	save (s0)
	save (s1)
	
	fmin.d fs0 fa0 fa1  # � s0 - ����� �������
	fmax.d fs1 fa0 fa1  # � s1 = ������ �������
	fmv.d fs2 fa2  # � s2 = ��������� ��������
	li s0 0  # � s0 - �������� �� �������� ��� ���

	
	fadd.d fa2 fs2 fs2  # ������ � fa2 �����, ������� fs2, ����� ���� �������
	
	loop:
	fle.d s1 fa2 fs2
	bnez s1 end_loop
		jal _secant_method_iteration  # ������ �������� ������
		b loop
	end_loop:
	# ������������ ��������
	flt.d t0 fa1 fs0
	or s0 s0 t0
	fgt.d t0 fa1 fs1
	or s0 s0 t0
	mv a0 s0
	fmv.d fa0 fa1
	
	# ��������������� �������� s-���������
	restore (s1)
	restore (s0)
	frestore.d (fs2)
	frestore.d (fs1)
	frestore.d (fs0)
.end_macro

gfunc(_secant_method, secant_method_body)
	
	
