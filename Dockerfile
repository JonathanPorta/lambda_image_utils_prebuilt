FROM lambci/lambda:build-python3.6

RUN  yum install -y gcc g++ gcc-c++ cmake wget

WORKDIR /var/task

RUN wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz && \
  tar -xJf Python-3.6.1.tar.xz && \
  cd Python-3.6.1 && \
  ./configure --prefix=/var/lang && \
  make -j$(getconf _NPROCESSORS_ONLN) libinstall inclinstall

ENV CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/var/task/Python-3.6.1/:/var/task/Python-3.6.1/Include

RUN wget https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz && \
  tar -xvf boost_1_65_1.tar.gz && \
  cd boost_1_65_1/ && \
  ./bootstrap.sh --with-python=python3.6 --with-libraries=python --prefix=/var/task/Python-3.6.1/ && \
  ./b2

ENV BOOST_INCLUDEDIR=/var/task/boost_1_65_1/ BOOST_ROOT=/var/task/boost_1_65_1/ BOOST_LIBRARYDIR=/var/task/boost_1_65_1/stage/lib/
RUN wget http://dlib.net/files/dlib-19.7.tar.bz2 && \
  tar -xvf dlib-19.7.tar.bz2 && \
  cd dlib-19.7/ && \
  mkdir build && \
  cd build && \
  cmake .. && \
  cmake --build . && \
  cd ../ && \
  python3 setup.py install

ENV LD_LIBRARY_PATH=/var/task/boost_1_65_1/stage/lib/:$LD_LIBRARY_PATH
RUN ldconfig && pip3 install --target /var/task/ face_recognition

# TODO: Update to use the new nest Dockerfile magic when lesss tired
RUN rm /var/task/boost_1_65_1.tar.gz && rm /var/task/dlib-19.7.tar.bz2 && rm /var/task/Python-3.6.1.tar.xz
RUN mv /var/task/boost_1_65_1/stage /var/task/keep && rm -rf /var/task/boost_1_65_1 && mkdir /var/task/boost_1_65_1 && mv /var/task/keep /var/task/boost_1_65_1/stage
RUN mv /var/task/dlib-19.7/build /var/task/keep && rm -rf /var/task/dlib-19.7 && mkdir /var/task/dlib-19.7 && mv /var/task/keep /var/task/dlib-19.7/build
RUN rm -rf /var/task/Python-3.6.1
RUN ldconfig && \
  pip3 install -r prebuilt-requirements.txt

ENTRYPOINT '/bin/bash'
