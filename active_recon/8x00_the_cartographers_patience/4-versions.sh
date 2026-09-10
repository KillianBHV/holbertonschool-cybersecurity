#!/bin/bash
nmap -Pn -T2 -sS -sV --version-all -p22,80 10.10.10.10
