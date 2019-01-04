FROM local/gcp/openemr-secure/secure:latest

ARG DEBIAN_FRONTEND=noninteractive


RUN cd /root && git clone https://github.com/openemr/docker-madness
RUN chmod 770 /root/docker-madness/helper-files/helper-scripts/debian9.sh && ./root/docker-madness/helper-files/helper-scripts/debian9.sh
#@todo disable uneeded apache modules?
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80 443
