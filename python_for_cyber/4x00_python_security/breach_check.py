#!/usr/bin/env python3

import argparse
import sys


""" FRAMEWORK - BreachCheck - v1.0
"""


def main():
    """ Mainline execution process
    """

    print("BreachCheck v1.0 startup...")

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

    args = parser.parse_args()


def read_file(filename: str) -> list:
    """ Checks if file exists and its rights
    """

    try:
        with open(filename, "r") as file:
            return file.readlines()
    except FileNotFoundError:
        print(f"[ERROR] File not found: {filename}", file=sys.stderr)
        exit(1)
    except PermissionError:
        print(f"[ERROR] Permission denied: {filename}", file=sys.stderr)
        exit(1)


if __name__ == '__main__':
    main()
