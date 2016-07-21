#
# Quantum Espresso : a program for electronic structure calculations
#    full sources and binaries version
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
#
# we update the package list 
# and install openssh-server, sudo, wget, update-motd 
# and run ssh-keygen -A to generate all possible keys for the host
RUN apt update \
	&& apt install -y openssh-server sudo wget openmpi-bin libopenmpi1.10 libopenmpi-dev \
	&& ssh-keygen -A   
#
# we create the user 'qe' and add it to the list of sudoers
RUN  adduser -q --disabled-password --gecos qe qe \
	&& echo "qe 	ALL=(ALL:ALL) ALL" >>/etc/sudoers
#
# we add /home/qe to the PATH of user 'qe'
RUN echo "export PATH=/home/qe/bin:${PATH}" >>/home/qe/.bashrc
#
# we move to /home/qe
WORKDIR /home/qe
#
# we copy the 'qe' files and the needed shared libraries to /home/qe
# then we unpack them : the 'qe' directly there, the shared libs
# from /
RUN wget  http://people.sissa.it/~inno/qe/qe.tgz \
	  http://people.sissa.it/~inno/qe/bin/qe-all-bins.tgz \
	  http://people.sissa.it/~inno/qe/sl-03.tgz \
	  http://people.sissa.it/~inno/qe/esp-mpi-src.tgz \
	&& tar xzf qe.tgz \
	&& tar xzf qe-all-bins.tgz \
	&& tar xzf sl-03.tgz -C /  \
	&& tar xzf esp-mpi-src.tgz \
#
# we chown to files in /home/qe, make pw.x executable, set 'qe' passwd
	&& chown -R qe:qe /home/qe   \
	&& chmod a+x pw.x && (echo "qe:mammamia"|chpasswd) \
#
# we remove the archives we copied
	&& rm qe.tgz \
	qe-all-bins.tgz \
 	sl-03.tgz  \
	esp-mpi-src.tgz
#

RUN service   ssh  restart 

EXPOSE 22

#
# the container can be now reached via ssh
CMD [ "/usr/sbin/sshd","-D" ]
