EXECUTABLE=out

SOURCE=main.s
INCLUDES=DemoStartup.S debug.s
GENERATED=gen/hello.raw gen/hello-copper.s

DEPENDENCIES=$(SOURCE) $(INCLUDES) $(GENERATED) Makefile

$(EXECUTABLE) : $(DEPENDENCIES)
	vasmm68k_mot -DDEBUG -showcrit -showopt -Fhunkexe -o $@ -nosym $(SOURCE)

$(EXECUTABLE)-nodebug : $(DEPENDENCIES)
	vasmm68k_mot -showcrit -showopt -Fhunkexe -o $@ -nosym $(SOURCE)

gen/hello.raw gen/hello-copper.s: assets/hello.png bitplanify.py
	python bitplanify.py $< --copper=gen/hello-copper.s gen/hello.raw

clean:
	rm -r gen/*
	rm -f $(EXECUTABLE)

.PHONY: clean
