#!/bin/bash
IFS='.' read -ra ip <<< "$1"; IFS='.' read -ra mask <<< "$2"; for i in 0 1 2 3; do echo -n "" $(( (${ip[i]} & ${mask[i]}) | ~${mask[i]} & 0xFF )); done | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/ /\./g'
