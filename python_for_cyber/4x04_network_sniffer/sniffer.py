#!/usr/bin/env python3

import argparse
from scapy.sendrecv import sniff
from scapy.utils import PcapWriter


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

args = parser.parse_args()
sniff_args = {"store": False}

if args.interface:
    sniff_args["iface"] = args.interface
if args.filter:
    sniff_args["filter"] = args.filter

if args.write:
    writer = PcapWriter(args.write, append=True)
else:
    writer = None


def packet_handler(packet) -> None:
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

        if writer is not None:
            writer.write(packet)
        else:
            print(total_state)


def main() -> None:
    """Entry Point
    """
    print("[INFO] PySniffer initialized.")

    try:
        sniff(prn=packet_handler, **sniff_args)
    except KeyboardInterrupt:
        print("\n[INFO] Stopping capture...")
    finally:
        if writer:
            writer.close()


if __name__ == '__main__':
    main()
