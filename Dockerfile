#
# Quantum Espresso : a program for electronic structure calculations
#    ssh version
#
#
# For many reasons we need to fix the ubuntu release:
FROM ubuntu:16.04
#
MAINTAINER roberto innocente <inno@sissa.it>
#
# we replace the standard http://archive.ubuntu.com repository
# that is very slow, with the new mirror method :
# deb mirror://mirror.ubuntu.com/mirrors.txt ...
ADD  http://people.sissa.it/~inno/qe/sources.list /etc/apt/
RUN  chmod 644 /etc/apt/sources.list
#
# we update the apt database
# and because for the docker repository we use the https transport
# we install it
#
RUN  apt update \
	&& apt install -y apt-transport-https 
#
# we add to the repositories the dockerproject repo and add its key
#
RUN echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" >>/etc/apt/
sources.list 
#
RUN  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58
118E89F3A912897C070ADBF76221572C52609D 
#
#
# we update the package list 
# and install vim openssh, sudo, wget, gfortran, openblas, blacs,
# fftw3, openmpi , ...
# and run ssh-keygen -A to generate all possible keys for the host
#
RUN apt install -y vim \
		openssh-server \
		sudo \
		wget \
        	ca-certificates \
		gfortran-5 \
		libgfortran-5-dev \
		openmpi-bin  \
		libopenmpi-dev \
        	libopenblas-base \
        	libopenblas-dev \
        	libfftw3-3 \
        	libfftw3-double3  \
		libblacs-openmpi1 \
		libblacs-mpi-dev \
		net-tools \
		make \
		autoconf \
	&& ssh-keygen -A
#
# we need to update the package database after including 
# the new docker repo
#
RUN	apt update \ 
	&&  apt install -y docker-engine
#
# we create the user 'qe' and add it to the list of sudoers
RUN  adduser -q --disabled-password --gecos qe qe \
	&& echo "qe 	ALL=(ALL:ALL) ALL" >>/etc/sudoers \
#
# we add /home/qe to the PATH of user 'qe'
	&& echo "export PATH=/home/qe/bin:${PATH}" >>/home/qe/.bashrc \
	&& mkdir -p /home/qe/.ssh/  \
	&& chown qe:qe /home/qe/.ssh
#
# we move to /home/qe
WORKDIR /home/qe
#
# we copy the 'qe' files and the needed shared libraries to /home/qe
# then we unpack them : the 'qe' directly there, the shared libs
# from /
RUN wget  --no-verbose  http://people.sissa.it/~inno/qe/qe.tgz \ 
	  http://people.sissa.it/~inno/qe/bin/qe-all-bins.tgz \
	  http://people.sissa.it/~inno/qe/mpibin.tgz \
	  http://people.sissa.it/~inno/qe/esp-mpi-test-src.tgz \
	  http://people.sissa.it/~inno/qe/pseudo_potentials.tgz \
	&& tar xzf qe.tgz \
	&& tar xzf qe-all-bins.tgz \
	&& tar xzf mpibin.tgz \
	&& tar xzf esp-mpi-test-src.tgz \
	&& tar xzf pseudo_potentials.tgz \
#
# we chown -R the files in /home/qe, make pw.x executable, set 'qe' passwd
	&& chown -R qe:qe /home/qe   \
	&& (echo "qe:mammamia"|chpasswd) \
#
# we remove the archives we copied
	&& rm qe.tgz qe-all-bins.tgz \
	mpibin.tgz \
 	esp-mpi-test-src.tgz \
	pseudo_potentials.tgz
#

RUN sed -i 's#^StrictModes.*#StrictModes no#' /etc/ssh/sshd_config \
	&& service   ssh  restart  \
	&& usermod -aG docker qe \
	&& echo "" >>/etc/hosts \
	&& for i in 1 2 3 4 5 6 7 ; do echo "192.168.0.2${i}	node${i}" ; done
 >>/etc/hosts


EXPOSE 22

#
# the container can be now reached via ssh
CMD [ "/usr/sbin/sshd","-D" ]

