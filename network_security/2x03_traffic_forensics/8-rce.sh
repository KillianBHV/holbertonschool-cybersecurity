#!/bin/bash
tshark -r $1 -T fields -e frame.number -Y 'frame contains "/bin/sh"'
