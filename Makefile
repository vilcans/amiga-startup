EXECUTABLE=out

SOURCE=main.s
INCLUDES=DemoStartup.S debug.s
GENERATED=gen/hello.raw gen/hello-copper.s

DEPENDENCIES=$(SOURCE) $(INCLUDES) $(GENERATED) Makefile

VASM_OPTIONS=-showcrit -showopt -Fhunkexe -nosym -L $(EXECUTABLE).lst -Lnf

$(EXECUTABLE) : $(DEPENDENCIES)
	vasmm68k_mot $(VASM_OPTIONS) -DDEBUG -o $@ $(SOURCE)

$(EXECUTABLE)-nodebug : $(DEPENDENCIES)
	vasmm68k_mot  -o $@ $(SOURCE)

gen/hello.raw gen/hello-copper.s: assets/hello.png bitplanify.py
	python bitplanify.py $< --copper=gen/hello-copper.s gen/hello.raw

clean:
	rm -rf gen/*
	rm -f $(EXECUTABLE)

.PHONY: clean
