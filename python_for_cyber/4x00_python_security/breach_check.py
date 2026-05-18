#!/usr/bin/env python3

import argparse
import logging
import re
import sys


""" FRAMEWORK - BreachCheck - v1.0
"""

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

file_handler = logging.FileHandler("breach_check.log")
file_handler.setLevel(logging.DEBUG)
file_handler.setFormatter(formatter)

stream_handler = logging.StreamHandler()
stream_handler.setLevel(logging.INFO)
stream_handler.setFormatter(formatter)

logger.addHandler(file_handler)
logger.addHandler(stream_handler)


def main():
    """ Mainline execution process
    """

    logger.info("BreachCheck v1.0 startup...")

    parser = argparse.ArgumentParser()
    fwrite_help = "Write into file. If not specified, standard output"

    parser.add_argument("-f", "--file",
                        type=str, required=True,
                        help="File path to process")
    parser.add_argument("-v", "--verbose",
                        help="Verbose mode",
                        action="store_true")
    parser.add_argument("-o", "--output",
                        type=argparse.FileType('w'),
                        nargs='?', default=sys.stdout,
                        help=fwrite_help)

    logger.info("Command parsing...")
    args = parser.parse_args()

    logger.info("File processing...")
    logger.debug("Opening file...")
    input_file = read_file(args.file)

    logger.debug("File opened successfully.")
    logger.debug("Data extraction...")
    input_file = clean_data(input_file)

    for data in input_file:
        validate_line(data)


def read_file(filename: str) -> list:
    """ Checks if file exists and its rights
    """

    try:
        with open(filename, "r") as file:
            return file.readlines()
    except FileNotFoundError:
        logger.error(f"File not found: {filename}")
        exit(1)
    except PermissionError:
        logger.error(f"Permission denied: {filename}")
        exit(1)


def clean_data(lines: list) -> list:
    """Clean characters
    """
    final_data = []

    for i in range(len(lines)):
        if lines[i] and not lines[i].startswith("#"):
            final_data.append(lines[i].strip())

    return final_data


def validate_line(line: str) -> bool:
    pattern_line = r"^[^:]+:[^:]+$"

    if re.match(pattern_line, line):
        pattern_mail = r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"

        if re.match(pattern_mail, line.split(':')[0]):
            return True
        return False
    else:
        return False


if __name__ == '__main__':
    main()
