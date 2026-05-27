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
        s.settimeout(5)

        return s.connect((ip, port)) == 0
    except socket.error:
        return False
    finally:
        s.close()


def main():
    logger.info("NetProbe v1.0 initialized...")
    print(f"Port 8000 is open: {check_port('localhost', 8000)}")
    print(f"Port 8001 is open: {check_port('localhost', 8001)}")


if __name__ == '__main__':
    main()
    check_port("localhost", 8000)
