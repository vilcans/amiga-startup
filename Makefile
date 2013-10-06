EXECUTABLE=out

SOURCE=main.s

$(EXECUTABLE) : $(SOURCE)
	vasmm68k_mot -showcrit -showopt -Fhunkexe -o $@ -nosym $(SOURCE)
