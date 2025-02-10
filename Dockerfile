FROM --platform=linux/amd64 ubuntu:22.04

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    python3-pip \
    wget \
    libgeos-dev \
    libgdal-dev \
    && rm -rf /var/lib/apt/lists/*

# Install miniconda
ENV PATH="/root/miniconda3/bin:${PATH}"
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b && \
    rm Miniconda3-latest-Linux-x86_64.sh

# Create conda environment with core packages
RUN conda create -n geo -y -c conda-forge \
    python=3.10 \
    notebook \
    geopandas \
    && conda clean -a -y

# Install rio-mbtiles in conda environment
RUN conda run -n geo pip install rio-mbtiles python-dotenv boto3 psycopg2 SQLAlchemy

# Install pmtiles
RUN wget https://github.com/protomaps/go-pmtiles/releases/download/v1.25.0/go-pmtiles_1.25.0_Linux_x86_64.tar.gz && \
    tar xzf go-pmtiles_1.25.0_Linux_x86_64.tar.gz && \
    cp pmtiles /usr/bin/pmtiles && \
    rm go-pmtiles_1.25.0_Linux_x86_64.tar.gz

# Set default environment
RUN echo "source activate geo" > ~/.bashrc
ENV PATH /root/miniconda3/envs/geo/bin:$PATH

EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]