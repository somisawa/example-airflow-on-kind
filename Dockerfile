FROM python:3.9
RUN apt-get update && apt-get install -y git cmake protobuf-compiler
RUN adduser akari
USER akari
ENV HOME /home/akari
ARG GIT_ACCESS_TOKEN
RUN git config --global url."https://${GIT_ACCESS_TOKEN}@github.com".insteadOf "ssh://git@github.com"
RUN pip install --upgrade pip
RUN pip install numpy protobuf==3.16.0 pandas \
    && pip install onnx \
    && pip install skl2onnx
RUN pip install git+ssh://git@github.com/AKARI-Inc/blood-skl.git#egg=blood-skl \
    && pip install git+ssh://git@github.com/AKARI-Inc/jcon.git#egg=jcon 
WORKDIR /home/akari
