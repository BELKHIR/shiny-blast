FROM rocker/r-ver:3.5.2

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget \
    libbz2-dev \
    blast2


# Download and install shiny server
RUN R -e "install.packages(c('shiny', 'rmarkdown'),Ncpus=8, repos='https://cloud.r-project.org/')" 
RUN Rscript -e 'install.packages("shinydashboard",Ncpus=8, repos="https://cloud.r-project.org/")'
RUN Rscript -e 'install.packages("shinyjs",Ncpus=8, repos="https://cloud.r-project.org/")'


RUN Rscript -e "install.packages('stringr',Ncpus=8, repos='https://cloud.r-project.org/')" 
RUN Rscript -e "install.packages('knitr',Ncpus=8, repos='https://cloud.r-project.org/')" 
RUN Rscript -e "install.packages('DT',Ncpus=8, repos='https://cloud.r-project.org/')" 


RUN Rscript -e "install.packages('msaR',Ncpus=8, repos='https://cloud.r-project.org/')" 
RUN Rscript -e "install.packages('dplyr',Ncpus=8, repos='https://cloud.r-project.org/')" 
RUN Rscript -e "install.packages('plyr',Ncpus=8, repos='https://cloud.r-project.org/')" 

RUN Rscript -e "install.packages('Cairo',Ncpus=8, repos='https://cloud.r-project.org/')" 

RUN apt-get install -y libxml2-dev
RUN Rscript -e "install.packages('XML',Ncpus=8, repos='https://cloud.r-project.org/')" 
RUN Rscript -e 'install.packages("shinyFiles",dependencies=T,Ncpus=8, repos="https://cloud.r-project.org/")'

EXPOSE 3838

RUN mkdir /Results
RUN mkdir /ShinyBlast
COPY R /ShinyBlast/R
COPY server /ShinyBlast/server
COPY www /ShinyBlast/www
COPY pages /ShinyBlast/pages
COPY db /Results/db
COPY app.R /ShinyBlast/


CMD ["Rscript", "-e", "shiny::runApp('/ShinyBlast/app.R', port=3838 , host='0.0.0.0')"]
