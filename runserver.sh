#!/bin/bash

# Initialize Wine prefix
if [ ! -d "/home/abiotic/.wine" ]; then
    wineboot --init
fi

# Check for updates
if [[ $AutoUpdate == "true" ]]; then
   echo ""
   echo "***********"
   echo "Checking for auto updates..."
   echo "***********"
   echo ""
   /usr/games/steamcmd +@sSteamCmdForcePlatformType windows \
   +force_install_dir /home/abiotic/abioticserver \
   +login anonymous \
   +app_update 2857200 \
   +quit
fi

# Default variables
MaxServerPlayers="${MaxServerPlayers:-6}"
Port="${Port:-7777}"
QueryPort="${QueryPort:-27015}"
ServerPassword="${ServerPassword:-}"
SteamServerName="${SteamServerName:-Dedicated Server}"
WorldSaveName="${WorldSaveName:-Cascade}"
AdminPassword="${AdminPassword:-}"
OverrideSandboxPath="${OverrideSandboxPath:-}"
OverrideAdminPath="${OverrideAdminPath:-}"
AdditionalArgs="${AdditionalArgs:-}"

SetUsePerfThreads="-useperfthreads"
if [[ $UsePerfThreads == "false" ]]; then
    SetUsePerfThreads=""
fi

SetNoAsyncLoadingThread=""
if [[ $DisableAsyncLoadingThread == "true" ]]; then
    SetNoAsyncLoadingThread="-DisableAsyncLoadingThread"
fi

SetAdminPassword=""
if [[ $AdminPassword != "" ]]; then
    SetAdminPassword="-AdminPassword=${AdminPassword}"
fi

# Copy the default SandboxSettings.ini if it does not exist inside Saved/ Volume
if [ ! -f /home/abiotic/abioticserver/AbioticFactor/Saved/DefaultSandboxSettings.ini ]; then
    cp /home/abiotic/abioticserver/DefaultSandboxSettings.ini /home/abiotic/abioticserver/AbioticFactor/Saved/DefaultSandboxSettings.ini
fi

# Copy the default Admin.ini if it does not exist inside Saved/ Volume
if [ ! -f /home/abiotic/abioticserver/AbioticFactor/Saved/Admin.ini ]; then
    cp /home/abiotic/abioticserver/Admin.ini /home/abiotic/abioticserver/AbioticFactor/Saved/Admin.ini
fi

echo ""
echo "***********"
echo "Launching abiotic game server..."
echo "***********"
echo ""
WINEDEBUG=fixme-all wine64 abioticserver/AbioticFactor/Binaries/Win64/AbioticFactorServer-Win64-Shipping.exe \
   -log -newconsole \
   $SetUsePerfThreads $SetNoAsyncLoadingThread \
   -PORT=$Port -QUERYPORT=$QueryPort -tcp \
   -MaxServerPlayers=$MaxServerPlayers -WorldSaveName="$WorldSaveName" \
   -SteamServerName="$SteamServerName" -ServerPassword=${ServerPassword} $SetAdminPassword \
   $OverrideSandboxPath \
   $OverrideAdminPath \
   $AdditionalArgs