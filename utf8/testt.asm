.include "mfunc.inc"
.include "convenience.inc"

.data
	xx1: .double 3.2
	xx2: .double -8.4
	xx3: .double -1

.text
	fld fs0 xx1 t0
	fld fs1 xx2 t0
	fld fs2 xx3 t0
	li s0 4
	li s1 -82
	li s2 97
	
	save (s0)
	fsave.d (fs0)
	save (s1)
	fsave.d (fs1)
	fsave.d (fs2)
	save (s2)
	
	restore (s2)
	frestore.d (fs2)
	frestore.d (fs1)
	restore (s1)
	frestore.d (fs0)
	restore (s0)
	
	print_int (s0)
	print_char ('\n')
	print_int (s1)
	print_char ('\n')
	print_int (s2)
	print_char ('\n')
	print_double (fs0)
	print_char ('\n')
	print_double (fs1)
	print_char ('\n')
	print_double (fs2)
	print_char ('\n')
	

