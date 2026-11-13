#!/bin/bash

PATH_SIG=""

ScanSignatures() {

}

RegisterSignatures() {

}

case $1 in
  --scan)
    ScanSignatures
  ;;
  --reg)
    RegisterSignatures
  ;;
esac