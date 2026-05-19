#!/usr/bin/env python3

import configparser
import hashlib
import logging
import re

# Setting up the logger
root_logger = logging.getLogger()
root_logger.setLevel(logging.DEBUG)

formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

file_handler = logging.FileHandler("breach_check.log")
file_handler.setLevel(logging.DEBUG)
file_handler.setFormatter(formatter)

stream_handler = logging.StreamHandler()
stream_handler.setLevel(logging.INFO)
stream_handler.setFormatter(formatter)

if not root_logger.handlers:
    root_logger.addHandler(file_handler)
    root_logger.addHandler(stream_handler)

# Setting up the configuration parser
config = configparser.ConfigParser()

if not config.read("config.ini"):
    logging.error("Config file missing")
    exit(1)


def clean_data(lines: list) -> list:
    """Clean characters
    """
    final_data = []

    for line in lines:
        if line and not line.startswith("#"):
            final_data.append(line.strip())

    return final_data


def validate_line(line: str) -> bool:
    """Checks string:string presence and mail-specific
    """
    pattern_line = r"^[^:]+:[^:]+$"

    if re.match(pattern_line, line):
        pattern_mail = r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"

        if re.match(pattern_mail, line.split(':')[0]):
            return True
        return False
    else:
        return False


def check_policy(password: str) -> str:
    """Checks passwords strength level
    """
    min_length = config.getint("SECURITY", "MinLength")
    if len(password) < min_length or password.isalpha():
        return 'WEAK'

    COMMON_PASSWORD = {
        "admin",
        "password",
        "123456",
        "qwerty",
        "azerty",
        "pass"
    }

    if password.lower() in COMMON_PASSWORD:
        return 'WEAK'

    return 'COMPLIANT'


def hash_password(password: str, salt: str) -> str:
    """Get SHA-256 calculated hash form
    """
    bytes_salt = salt.encode()
    bytes_password = password.encode()

    return hashlib.sha256(bytes_password + bytes_salt).hexdigest()
