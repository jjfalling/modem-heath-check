#!/usr/bin/env bash

#sanity check to see if cable modem is working and restart if a failure is detected.
#take care if using dual wan
#you probally should not run this more then every 10 min as your modem could take a while to boot!

#checks first external ping host
#if fails checks second external ping host
#if fails checks to ensure local gw responds, exit if its down
#if gw is up check modem
#make note of modem state and attempt reboot regardless of state

modemRebootCommand='curl --data "CmRNDISEnable=0&saveChanges=0&RestoreFactoryDefault=0&ResetReq=1" http://192.168.100.1/goform/RgConfig'
externalPingHost1="4.2.2.4"
externalPingHost2="204.13.250.1"
localGateway="192.168.5.1"
modemManagementIp="192.168.100.1"

printf "\nRunning check at "
date
printf "\n\n"

ping -c 4 $externalPingHost1
if [ $? -ne 0 ]
 then
  printf "\nlooks like primary external host is down, trying secondary host\n\n"
  ping -c 4 $externalPingHost2

  if [ $? -ne 0 ]
   then
    printf "\nlooks like external external host is down, trying local gateway\n\n"
   else
    printf "\neverything is ok, exiting\n\n"
    exit 0
 fi

else
 printf "\neverything is ok, exiting\n\n"
 exit 0
fi

ping -c 4 $localGateway
if [ $? -ne 0 ]
 then
  printf "\nlooks like local gateway is down, not attempting to restart modem...\n\n"
  exit 1
fi

ping -c 4 $modemManagementIp
if [ $? -ne 0 ]
 then
  printf "\nlooks like modem management ip is not responding, trying to reboot anyway\n\n"
fi

logger CABLE MODEM SEEMS TO HAVE FAILED! Automagically attempting to reboot it now!
$modemRebootCommand
if [ $? -ne 0 ]
 then
  printf "\nlooks like cant connect to modem management webui is not responding, all hope has failed...\n\n"
else
 printf "\ncurl seems to have succeded\n\n"
fi
