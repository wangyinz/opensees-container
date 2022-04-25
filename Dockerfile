######################################################
#
# OpenSees image
# Tag: wangyinz/opensees-container
#
# This is a vanilla installation of OpenSees 3.3.0 on Ubuntu 20.04.
# You can run the app demo by running the container with no
# arguments.
#
# docker run -it --rm wangyinz/opensees-container
#
# To run your own input, mount your data to the /data volume and
# specify the traditional invocation command
#
# docker run -it --rm -v `pwd`:/data wangyinz/opensees-container /bin/sh -c 'OpenSees < /data/myinput.tcl'
#
# The data will appear in your current directory at the end of the run.
#
######################################################
FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt-get -y update && \
    apt-get -y install git emacs make tcl8.6 tcl8.6-dev gcc g++ gfortran python3-dev && \
    useradd --create-home ubuntu 
RUN cd /home/ubuntu && \
    mkdir bin lib && \
    git clone https://github.com/OpenSees/OpenSees.git && \
    cd OpenSees && \
    git checkout v3.3.0 && \
    cp MAKES/Makefile.def.EC2-UBUNTU Makefile.def && \
    sed -i 's/= .\/home/= \/home\/ubuntu/g' Makefile.def && \
    sed -i 's/.\/usr\/local/\/usr\/local/g' Makefile.def && \
    make -j 28 && \
    cd SRC/interpreter && \
    make -j 28 && \
    cd ../.. && \
    sed -i 's/INTERPRETER_LANGUAGE = PYTHON/INTERPRETER_LANGUAGE = TCL/g' Makefile.def && \
    make wipe && \
    make -j 28

COPY inputs /data
RUN chown -R ubuntu:ubuntu /home/ubuntu /data
USER ubuntu
WORKDIR /data
ENV PATH $PATH:/home/ubuntu/bin
VOLUME ["/data"]
CMD [ "/bin/sh", "-c", "OpenSees < /data/SimpleCyclicShear/1elem_woutput_debug.tcl" ]
