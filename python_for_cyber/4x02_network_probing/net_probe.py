#!/usr/bin/env python3

import logging
import select
import socket

logger = logging.getLogger()


def check_port(ip: str, port: int) -> bool:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client_read, client_write, except_hands = select.select([s], [], [], 5)

        s.connect((ip, port))
        return True
    except select.error:
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
