#!/bin/bash

ping -c1 -w1 $* &> /dev/null && echo $* is up || echo $* is down
