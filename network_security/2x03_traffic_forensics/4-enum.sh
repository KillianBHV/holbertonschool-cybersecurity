#!/bin/bash
tshark -r $1 -T fields -e frame.number -Y 'http.response.code==404' | wc -l
