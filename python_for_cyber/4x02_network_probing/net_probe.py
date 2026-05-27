#!/usr/bin/env python3

import logging
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
    return [f"{subnet}.{k}" for k in range(136, 149) if check_port(f"{subnet}.{k}", 8000)]


def main():
    logger.info("NetProbe v1.0 initialized...")
    print(ping_sweep("192.168.248"))


if __name__ == '__main__':
    main()
