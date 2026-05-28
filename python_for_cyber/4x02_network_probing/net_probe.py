#!/usr/bin/env python3

import logging
import re
import select
import socket

logger = logging.getLogger()


def check_port(ip: str, port: int) -> bool:
    """Checks if specified port on ip is open
    """
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(1)

        s.connect((ip, port))
        return True
    except socket.error:
        return False
    finally:
        s.close()


def ping_sweep(subnet: str) -> list:
    """Scan a specific range of ip on port 80
    """
    ips = []
    for k in range(1, 254):
        ip = f"{subnet}.{k}"
        print(ip)
        if check_port(ip, 80):
            ips.append(ip)

    return ips


def get_banner(ip: str, port: int) -> str:
    """Checks if a banner appears
    """
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(1)
        s.connect((ip, port))

        data = s.recv(1024)
        if not data:
            return "Unknown"

        return data.decode()
    except socket.error:
        return "Unknown"
    finally:
        s.close()


def main():
    logger.info("NetProbe v1.0 initialized...")
    print(get_banner("scanme.nmap.org", 22))


if __name__ == '__main__':
    main()
