#!/usr/bin/env python3

import argparse
import configparser
import sys
from utils import *

""" FRAMEWORK - BreachCheck - v1.0
"""


# Setting up the configuration parser [FOR CHECKER ONLY]
config = configparser.ConfigParser()

if not config.read("config.ini"):
    logging.error("Config file missing")
    exit(1)


def main():
    """ Mainline execution process
    """

    logging.info("BreachCheck v1.0 startup...")

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

    logging.info("Command parsing...")
    args = parser.parse_args()

    logging.info("File processing...")
    logging.debug("Opening file...")
    input_file = read_file(args.file)

    logging.debug("File opened successfully.")
    logging.debug("Weak-Passwords research...")
    logging.info("Password analysis...")
    pass_hash_list = []

    for data in clean_data(input_file):
        if validate_line(data):
            password = data.split(':')[1]
            if check_policy(password) == 'WEAK':
                salt = config["SECURITY"]["Salt"]
                pass_hash_list.append(hash_password(password, salt))


if __name__ == '__main__':
    main()
