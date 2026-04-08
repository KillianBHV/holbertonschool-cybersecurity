#!/bin/bash
grep "segfault" $1/kern.log $1/messages 2>/dev/null
