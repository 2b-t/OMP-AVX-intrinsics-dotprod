#Basic Defintions for using INTEL compiler suite sequentially
#requires setting of COMPILER=ICC_

#BINDIR = /opt/intel/bin/

CC	= ${BINDIR}icc
CXX     = ${BINDIR}icpc
F77	= ${BINDIR}ifort
LINKER  = ${CXX}

WARNINGS = -Wall -Weffc++ -Woverloaded-virtual -Wfloat-equal -Wshadow -wd2015,2012 -wn3
           #-Winline -Wredundant-decls -Wunreachable-code
CXXFLAGS += -std=c++17 -fopenmp -mavx2 -march=native -funroll-all-loops -O3 -DNDEBUG ${WARNINGS} -mkl ${FOUND_CONFIG}

#profiling tools
#CXXFLAGS  += -pg
#LINKFLAGS += -pg

LINKFLAGS += -O3 -mkl

default:	${PROGRAM}

${PROGRAM}:	${OBJECTS}
	$(LINKER)  $^  ${LINKFLAGS} -o $@

clean:
	rm -f ${PROGRAM} ${OBJECTS}

clean_all:: clean
	@rm -f *_ *~ *.bak *.log *.out *.tar

run: clean ${PROGRAM}
	./${PROGRAM}

#tar the current directory
MY_DIR = `basename ${PWD}`
tar: clean_all
	@echo "Tar the directory: " ${MY_DIR}
	@cd .. ;\
	tar cf ${MY_DIR}.tar ${MY_DIR} *default.mk ;\
	cd ${MY_DIR}

doc:
	doxygen Doxyfile

#########################################################################

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $<

.c.o:
	$(CC) -c $(CFLAGS) $<

.f.o:
	$(F77) -c $(FFLAGS) $<

##################################################################################################
#some tools
#Cache behaviour (CXXFLAGS += -g  tracks down to source lines)
#   cache: ${PROGRAM}
# 	valgrind --tool=callgrind --simulate-cache=yes ./$^
#   kcachegrind callgrind.out.<pid> &
#
#Check for wrong memory accesses, memory leaks, ...
#use smaller data sets
#   mem: ${PROGRAM}
# 	valgrind -v --leak-check=yes --tool=memcheck --undef-value-errors=yes --track-origins=yes --log-file=$^.addr.out --show-reachable=yes ./$^
#
#Simple run time profiling of code
#    CXXFLAGS += -g -pg
#    LINKFLAGS += -pg
#    prof: ${PROGRAM}
# 	 ./$^
# 	 gprof -b ./$^ > gp.out
#    kprof -f gp.out -p gprof &
#

mem: inspector
prof: amplifier
cache: amplifier

gap_par_report:
	${CXX}  -c -guide -parallel $(SOURCES) 2> gap.txt

#GUI for performance report
amplifier: ${PROGRAM}
	echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
#alternatively to the solution above:
#edit file  /etc/sysctl.d/10-ptrace.conf     and set variable   kernel.yama.ptrace_scope   variable to 0 .
	amplxe-gui &

#GUI for Memory and Thread analyzer (race condition)
inspector: ${PROGRAM}
	echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
	inspxe-gui &

advisor:
	echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
	advixe-gui &

icc-info:
	icpc -# main.cpp
