FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Create non-root user
RUN useradd -m abiotic

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
   && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources \
   \
   # Enable multiverse for steamcmd
   && add-apt-repository multiverse \
   \
   # Enable 32-bit architecture
   && dpkg --add-architecture i386 \
   \
   # Pin Wine to version 8.x
   && mkdir -p /etc/apt/preferences.d \
   && printf "Package: winehq-stable wine-stable wine-stable-amd64 wine-stable-i386\nPin: version 10.*\nPin-Priority: 1001\n" \
      > /etc/apt/preferences.d/wine \
   \
   && apt-get update \
   \
   # Install Wine and required tools
   && apt-get install -y --install-recommends \
      winehq-stable \
      cabextract \
      winbind \
      screen \
      xvfb \
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

# Switch to non-root user
USER abiotic

ENTRYPOINT ["/bin/bash", "abioticserver/AbioticFactor/Binaries/Win64/runserver.sh"]