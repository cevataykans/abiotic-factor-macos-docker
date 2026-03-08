FROM ubuntu:24.04

WORKDIR /home/abiotic

# Install all required packages in one go, dedicated server being last
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    software-properties-common \
    lsb-release \
    wget \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-stable \
    && apt-get install -y --no-install-recommends \
    cabextract \
    winbind \
    screen \
    xvfb \
    && add-apt-repository multiverse \
    && apt-get update \
    && echo steam steam/question select "I AGREE" | debconf-set-selections \
    && echo steam steam/license note '' | debconf-set-selections \
    && apt-get install steamcmd \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir /home/abiotic/abioticserver \
    && /usr/games/steamcmd +@sSteamCmdForcePlatformType windows \
    +force_install_dir /home/abiotic/abioticserver \
    +login anonymous \
    +app_update 2857200 validate \
    +quit

COPY runserver.sh abioticserver/AbioticFactor/Binaries/Win64/runserver.sh
RUN chmod +x abioticserver/AbioticFactor/Binaries/Win64/runserver.sh

COPY DefaultSandboxSettings.ini abioticserver/DefaultSandboxSettings.ini
COPY Admin.ini abioticserver/Admin.ini
VOLUME ["/home/abiotic/abioticserver/AbioticFactor/Saved"]

EXPOSE 7777/tcp 7777/udp 27015/tcp 27015/udp

ENTRYPOINT ["/bin/bash", "abioticserver/AbioticFactor/Binaries/Win64/runserver.sh"]