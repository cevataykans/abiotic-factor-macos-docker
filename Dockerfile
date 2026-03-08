FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /home/abiotic

# Install dependencies, Wine (pinned to 8.x), and steamcmd
RUN apt-get update \
   && apt-get install -y --no-install-recommends \
      software-properties-common \
      lsb-release \
      wget \
      ca-certificates \
   && mkdir -pm755 /etc/apt/keyrings \
   \
   # Add WineHQ repository
   && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
   && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources \
   \
   # Enable multiverse for steamcmd
   && add-apt-repository multiverse \
   \
   && mkdir -p /etc/apt/preferences.d \
   && printf "Package: winehq-stable\nPin: version 10.*\nPin-Priority: 1001\n" \
      > /etc/apt/preferences.d/wine \
   \
   # Enable 32-bit architecture
   && dpkg --add-architecture i386 \
   \
   && apt-get update \
   \
   # Install Wine and required tools
   && apt-get install -y --install-recommends --allow-downgrades winehq-stable \
   && apt-get install -y cabextract winbind screen xvfb \
   \
   # Install steamcmd
   && echo steam steam/question select "I AGREE" | debconf-set-selections \
   && echo steam steam/license note '' | debconf-set-selections \
   && apt-get install -y steamcmd \
   \
   # Cleanup apt cache
   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Abiotic Factor dedicated server
RUN mkdir /home/abiotic/abioticserver \
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