#!/bin/bash

echo "master ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "deb-src http://gb.archive.ubuntu.com/ubuntu/ trusty main restricted" >> /etc/apt/sources.list
