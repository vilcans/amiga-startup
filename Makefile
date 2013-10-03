EXECUTABLE=out

$(EXECUTABLE) : main.s
	vasmm68k_mot -Fhunkexe -o $@ -nosym main.s
