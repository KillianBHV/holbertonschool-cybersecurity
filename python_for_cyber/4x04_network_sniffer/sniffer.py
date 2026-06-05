#!/usr/bin/env python3

import argparse
from scapy.all import wrpcap, sniff, Packet, IP, TCP, ICMP, UDP

print(dir(Packet))


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
        if packet.haslayer(IP):
            tcp_check = packet.haslayer(TCP)
            udp_check = packet.haslayer(UDP)
            icmp_check = packet.haslayer(ICMP)

            if tcp_check:
                print("[TCP] ", end='')
            elif udp_check:
                print("[UDP] ", end='')
            elif icmp_check:
                print("[ICMP] ", end='')

            if tcp_check or udp_check or icmp_check:
                ip_src = packet[IP].src
                ip_dest = packet[IP].dst

                result = f"{ip_src}"
                if tcp_check:
                    result += f":{packet[TCP].sport}"
                result += f" -> {ip_dest}"
                if tcp_check:
                    result += f":{packet[TCP].dport}"
                    result += f" | Flags: {packet[TCP].flags}"

                if self.output_file:
                    wrpcap(self.output_file, packet)
                else:
                    print(result)


def main() -> None:
    """Entry Point
    """
    print("[INFO] PySniffer initialized.")
    sniffer = Sniffer()
    sniffer.start()


if __name__ == '__main__':
    main()
