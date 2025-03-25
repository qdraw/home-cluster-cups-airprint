
FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install \
      cups-daemon \
      cups-client \
      cups-pdf \
      avahi-daemon \
      libnss-mdns \
      whois \
      curl \
      inotify-tools \
      libpng16-16t64 \
      python3-cups \
      samba-client \
      printer-driver-gutenprint \
      cups-browsed \
      colord \
      avahi-utils \
      hplip \
      cups-ipp-utils \
      foomatic-db \
      hpijs-ppds \
      printer-driver-hpijs \
      libcupsimage2t64 \
      system-config-printer \
      xauth \
      usbutils \
      net-tools \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

RUN sed -i "s/^#\ \+\(en_US.UTF-8\)/\1/" /etc/locale.gen \
&& locale-gen en_US en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en

RUN useradd \
    --groups=sudo,lp,lpadmin \
    --create-home \
    --home-dir=/home/print \
    --shell=/bin/bash \
    --password=$(mkpasswd print) \
    print \
    && sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers    

# Install Airprint
COPY airprint/ /opt/airprint/

COPY healthcheck.sh /
RUN mkdir -p /opt
COPY start-cups.sh /opt/
RUN chmod +x /healthcheck.sh /opt/start-cups.sh

ENV TZ="GMT" \
    CUPS_ADMIN_USER="admin" \
    CUPS_ADMIN_PASSWORD="secr3t" \
    CUPS_WEBINTERFACE="yes" \
    CUPS_SHARE_PRINTERS="yes" \
    CUPS_REMOTE_ADMIN="yes" \
    CUPS_ENV_DEBUG="yes" \
    CUPS_IP="" \
    CUPS_ACCESS_LOGLEVEL="config" \
    # example: lpadmin -p Air-Brother-HL-2270DW -D 'Airprinter Brother-HL-2270DW' -m 'HL2270DW.ppd' -o PageSize=A4 -v lpd://<ip>/BINARY_P1"
    CUPS_LPADMIN_PRINTER1=""

# This will use port 631
EXPOSE 631

ENTRYPOINT ["/opt/start-cups.sh"]
