.macro input_delta (%lb, %rb, %temp)
	fld fa0 %lb %temp
	fld fa1 %rb %temp
	jal _input_delta
.end_macro

.macro print_results (%x, %ch)
	fmv.d fa0 %x
	mv a0 %ch
	jal _print_results
.end_macro
