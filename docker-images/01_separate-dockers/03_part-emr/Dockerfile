FROM local/gcp/openemr-secure/secure:latest

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root
RUN git clone https://github.com/openemr/docker-madness
WORKDIR /root/docker-madness
RUN chmod 770 /root/docker-madness/helper-files/helper-scripts/debian9.sh && ./root/docker-madness/helper-files/helper-scripts/debian9.sh

RUN service apache2 start
EXPOSE 80 443
