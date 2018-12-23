FROM danora/openemr-secure:pre

ARG DEBIAN_FRONTEND=noninteractive

RUN git clone https://github.com/danehrlich1/openemr.git
WORKDIR /openemr/config/linux/ubuntu/ubuntu-docker
RUN chmod 770 ./ubuntu1804.sh && ./ubuntu1804.sh

EXPOSE 80 443
