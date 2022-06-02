libdir=/etc/slurm/spank
etcdir=/etc/slurm

all: singularity-exec.so

test:
	echo $(libdir) $(etcdir)

singularity-exec.so: main.cpp Makefile
	g++ -I/usr/include/slurm -std=c++17 -O2 -Wall -o singularity-exec.o -fPIC -c main.cpp
	g++ -shared -o singularity-exec.so singularity-exec.o


prepare-plugstack-conf:
	mkdir -p $(etcdir)/plugstack.conf.d
	test -f $(etcdir)/plugstack.conf || \
	  echo 'include $(etcdir)/plugstack.conf.d/*.conf' > $(etcdir)/plugstack.conf

install: singularity-exec.so prepare-plugstack-conf singularity-exec.conf
	install slurm-singularity-wrapper.sh $(libdir)/
	install singularity-exec.so          $(libdir)/
	install singularity-exec.conf        $(etcdir)/plugstack.conf.d/

help:
	@echo "... all"
	@echo "... install"

clean:
	rm -f singularity-exec.so

.PHONY: help clean prepare-plugstack-conf
