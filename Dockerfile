FROM ghcr.io/osgeo/gdal:ubuntu-full-3.9.2

WORKDIR /data

RUN apt-get update -qq \
    && apt-get install --no-install-recommends -y \
    python3-pip wget \
    && rm -rf /var/lib/apt/lists/*

# install conda
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 

# install python packages and set default env (pin numpy=1.21 to avoid issues https://github.com/geopandas/geopandas/issues/2521)
RUN conda install -n base conda-libmamba-solver 
RUN conda config --set solver libmamba
RUN conda create -n myenv -c conda-forge geopandas rasterio notebook pyarrow psycopg2 sqlalchemy geoalchemy2 pandas=1.4 numpy=1.22 shapely=2.0.0 -y 
SHELL ["conda", "run", "-n", "myenv", "/bin/bash", "-c"]
RUN echo "source activate myenv" > ~/.bashrc
ENV PATH /opt/conda/envs/myenv/bin:$PATH

RUN pip3 install rio-mbtiles rio-cogeo

# install pmtiles
RUN wget https://github.com/protomaps/go-pmtiles/releases/download/v1.19.1/go-pmtiles_1.19.1_Linux_x86_64.tar.gz
RUN tar xzf go-pmtiles_1.19.1_Linux_x86_64.tar.gz
RUN cp pmtiles /usr/bin/pmtiles

RUN rm /data/*

EXPOSE 8888
ENTRYPOINT [ "/bin/bash" ]

# docker compose up -d
# docker compose exec notebook /bin/bash
# jupyter notebook --ip 0.0.0.0 --no-browser --allow-root



