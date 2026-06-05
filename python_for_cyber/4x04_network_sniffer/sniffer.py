#!/usr/bin/env python3

import argparse
from scapy.all import wrpcap, sniff

import scapy.all as scapy
print(dir(scapy))


class Sniffer:
    def __init__(self,
                 interface="",
                 filter_str="",
                 output_file=None):
        self.interface = interface
        self.filter_str = filter_str
        self.output_file = output_file

    def start(self):
        """sniffer start
        """
        args = self.get_cli_parser()
        sniff_args = {"store": False}

        if args.interface:
            self.interface = args.interface
            sniff_args["iface"] = self.interface

        if args.filter:
            self.filter_str = args.filter
            sniff_args["filter"] = self.filter_str

        if args.write:
            self.output_file = args.write

        try:
            sniff(prn=self._process_packet, **sniff_args)
        except KeyboardInterrupt:
            print("\n[INFO] Stopping capture...")

    def get_cli_parser(self):
        parser = argparse.ArgumentParser(
            prog="PySniffer",
            description="Capture packets"
        )

        parser.add_argument("-i", "--interface", help="Interface to sniff")
        parser.add_argument("-f", "--filter", help="BPF filter to use")
        parser.add_argument("-v",
                            "--verbose",
                            help="Verbose mode",
                            action="store_true")
        parser.add_argument("--write", help="Write result on file")
        return parser.parse_args()

    def _process_packet(self, packet):
        """Get packet details
        """
        pkt = packet.summary()
        if "IP" in pkt:
            centre_idx = pkt.find('>')
            ip_idx = pkt.find('IP')+5

            left_side = pkt[ip_idx:centre_idx-1]
            ip_idx += left_side.find(' ')+1
            left_side = pkt[ip_idx:centre_idx-1]

            right_side = pkt[centre_idx+2:]
            right_side = right_side[:right_side.find(' ')]

            total_state = left_side + ' > ' + right_side

            total_state = total_state.replace("https", "443")
            total_state = total_state.replace("http", "80")
            total_state = total_state.replace("ssh", "22")

            if self.output_file is not None:
                wrpcap(self.output_file, packet)
            else:
                print(total_state)


def main() -> None:
    """Entry Point
    """
    print("[INFO] PySniffer initialized.")
    sniffer = Sniffer()
    sniffer.start()


if __name__ == '__main__':
    main()
