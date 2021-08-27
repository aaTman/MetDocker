FROM ubuntu:20.04 AS eccodes_install
RUN set -ex \
    && apt-get update --fix-missing

RUN set -ex \
    && apt-get install -y software-properties-common

# RUN set -ex \
#     && apt-get install -y python3-pip

# RUN set -ex \
#     && add-apt-repository ppa:deadsnakes/ppa \
#     && apt update \
#     && apt install -y python3.9

RUN set -ex \
    && apt-get install --yes --no-install-suggests --no-install-recommends \
        wget \
        git

RUN set -ex \
    && apt-get install --yes --no-install-suggests --no-install-recommends \
      bison \
      bzip2 \
      ca-certificates \
      curl \
      file \
      flex \
      g++-8 \
      gcc-8 \
      gfortran-8 \
      git \
      make \
      patch \
      sudo \
      swig

RUN set -ex \
    && ln -sf /usr/bin/g++-8 /usr/bin/g++ \
    && ln -sf /usr/bin/gcc-8 /usr/bin/gcc \
    && ln -sf /usr/bin/gfortran-8 /usr/bin/gfortran

# Install build-time dependencies.
# RUN set -ex \
#     && apt-get install --yes --no-install-suggests --no-install-recommends \
#       libarmadillo-dev \
#       libatlas-base-dev \
#       libboost-dev \
#       libbz2-dev \
#       libc6-dev \
#       libcairo2-dev \
#       libcurl4-openssl-dev \
#       libeigen3-dev \
#       libexpat1-dev \
#       libfreetype6-dev \
#       libgdal-dev \
#       libgeos-dev \
#       libharfbuzz-dev \
#       libhdf5-dev \
#       libjpeg-dev \
#       liblapack-dev \
#       libncurses5-dev \
#       libnetcdf-dev \
#       libpango1.0-dev \
#       libpcre3-dev \
#       libpng-dev \
#       libreadline6-dev \
#       libsqlite3-dev \
#       libssl-dev \
#       libxml-parser-perl \
#       libxml2-dev \
#       libxslt1-dev \
#       libyaml-dev 

RUN apt-get install -y cmake

RUN wget https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.22.1-Source.tar.gz?api=v2 \
    && tar -xzf eccodes-2.22.1-Source.tar.gz?api=v2 \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/eccodes ../eccodes-2.22.1-Source -DENABLE_ECCODES_THREADS=ON \
    && make \
    && ctest \
    && make install 

FROM continuumio/miniconda3
COPY . /met
COPY --from=eccodes_install /eccodes /eccodes
RUN conda config --append channels conda-forge

RUN conda env create --name met --file met/met_requirements.yaml
RUN conda install --y -c conda-forge cfgrib
RUN conda install --y -c conda-forge eccodes
RUN echo "conda activate met" >> ~/.bashrc

SHELL ["/bin/bash", "--login", "-c"]
