# Install R version 4.0.5
FROM r-base:4.0.5

# Install Ubuntu packages
RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev/unstable \
    libxt-dev \
    libssl-dev \
    libxml2-dev \
 #   libnlopt-dev \
 #   libudunits2-dev \
 #   libgeos-dev \
 #   libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    git
 #   libgdal-dev
    
# Install Shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt) && \
    wget "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb
    
# Install R packages that are required
RUN R -e "install.packages(c('BiocManager','shiny','shinythemes','Seurat','shinybusy','tidyverse','enrichR','imager','waiter','DT','readxl','shinyWidgets','shinyjs','RColorBrewer'))"

RUN R -e "BiocManager::install('rDGIdb')"

# Copy configuration files into the Docker image
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN rm -rf /srv/shiny-server/*
# COPY /* /srv/shiny-server/

# Get the app code
RUN git clone https://github.com/uvarc/PlaqView.git
RUN cp -r PlaqView/* /srv/shiny-server/

# Make the ShinyApp available at port 80
EXPOSE 80

RUN chown shiny.shiny /usr/bin/shiny-server.sh && chmod 755 /usr/bin/shiny-server.sh

# Run the server setup script
CMD ["/usr/bin/shiny-server.sh"]

