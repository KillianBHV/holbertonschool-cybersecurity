#!/usr/bin/env python3

import argparse
import os
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
    try:
        if not os.path.isfile(args.file):
            print("[ERROR] Is not a regular file")
            exit(1)
    except FileNotFoundError:
        print("[ERROR] File not found or does not exist.", file=sys.stderr)


if __name__ == '__main__':
    main()
