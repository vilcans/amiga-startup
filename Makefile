EXECUTABLE=out

SOURCE=main.s

$(EXECUTABLE) : $(SOURCE) gen/hello.raw gen/hello-copper.s
	vasmm68k_mot -showcrit -showopt -Fhunkexe -o $@ -nosym $(SOURCE)

gen/hello.raw gen/hello-copper.s: assets/hello.png bitplanify.py
	python bitplanify.py $< --copper=gen/hello-copper.s gen/hello.raw
