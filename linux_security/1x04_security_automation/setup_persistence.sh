#!/bin/bash
sudo cp sentinel.service /etc/systemd/system/
sudo cp sentinel.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now sentinel.timer
