.macro secant_method (%x1, %x2, %delta, %temp)
	fld fa0 %x1 %temp
	fld fa1 %x2 %temp
	fmv.d fa2 %delta
	jal _secant_method
.end_macro
