#!/usr/bin/env python3

import argparse
import json
import socket as skt
import concurrent.futures as crtf
import sys
import time

delay: float = 0.0


def check_port(ip: str, port: int) -> bool:
    """Checks the availability of a target

    Args:
        ip: IP Host to test (or hostname)
        port: Target port

    Returns:
        True if port is open else False
    """
    try:
        s = skt.socket(skt.AF_INET, skt.SOCK_STREAM)
        s.settimeout(1)
        s.connect((ip, port))

        return True
    except (OSError, TimeoutError):
        return False
    finally:
        if s:
            s.close()


def ping_sweep(subnet: str) -> list[str]:
    """Checks addresses with port 80 open

    Args:
        subnet: Network section, CIDR is supposed 24

    Returns:
        List of success IPs test
    """
    list_ip = []

    for e in range(1, 255):
        address = f"{subnet}.{e}"
        is_port_open = check_port(address, 8000)
        if is_port_open:
            list_ip.append(address)

    return list_ip


def get_banner(ip: str, port: int) -> str:
    """Extract banner from application-level protocol / service

    Args:
        ip: Target IP
        port: Port to scan

    Returns:
        Banner if succesfully handled else Unknown
    """
    try:
        s = skt.socket(skt.AF_INET, skt.SOCK_STREAM)
        s.connect((ip, port))

        if port == 80:
            s.send(b'HEAD / HTTP/1.0\r\n\r\n')
            data = s.recv(1024)
            if not data:
                return "Unknown"

            banner = data.decode().strip()
            for line in banner.split('\n'):
                if "Server" in line.replace('\r', ''):
                    return line.removeprefix('Server: ').removesuffix('\r')

            return "Unknown"
        elif port == 22:
            data = s.recv(1024)
            if not data:
                return "Unknown"

            banner = data.decode().strip()
            banner = banner.replace('\r', '')
            return banner.split()[0]
        elif port == 21:
            s.send(f"ftp {ip}".encode())
            data = s.recv(1024)
            if not data:
                return "Unknown"

            banner = data.decode().strip()
            for line in banner.split('\n'):
                if line.startswith('220'):
                    banner = line.removeprefix('220').removesuffix(')')
                    banner = banner.strip().removeprefix('(').lower()
                    return banner

            return "Unknown"
        else:
            return "Unknown"
    except OSError:
        print("[ERROR] Socket process problem occured")
        return "Unknown"
    except TimeoutError:
        print("Socket timeout reached")
        return "Unknown"
    finally:
        if s:
            s.close()


def scan_single_port(ip: str, port: int, d: float) -> dict:
    """Get one port state

    Args:
        ip: Target IP
        port: Single port to scan

    Returns:
        Metadata dictionary or empty one if port is not open
    """
    print(f"[DEBUG] Sleeping {d} before next packet...")
    time.sleep(d)

    is_open_port = check_port(ip, port)

    if is_open_port:
        banner = get_banner(ip, port)
        if check_vulnerability(banner):
            is_vulnerable_banner = 'YES'
        else:
            is_vulnerable_banner = 'NO'

        return {
            'port': port,
            'state': 'open',
            'service': banner,
            'vulnerability': is_vulnerable_banner
        }

    return {}


def scan_ports(ip: str,
               start_port: int,
               end_port: int) -> list:
    """Scan a range of ports

    Args:
        ip: Target IP
        start_port: Lower band port to scan
        end_port: Lower band port to scan

    Returns:
        Open ports report with banner grabbing
    """
    ports_report = []
    # raise Exception((sys.argv, delay, repr(delay)))
    raise Exception(str(delay))

    # with crtf.ThreadPoolExecutor(max_workers=50) as executor:
    #     for port in range(start_port, end_port + 1):
    #         future = executor.submit(scan_single_port, ip, port, 3)

    #         try:
    #             data = future.result()
    #             if data:
    #                 ports_report.append(data)
    #         except Exception:
    #             print(f"Error occured!")

    return ports_report


def print_infos(ip: str,
                sport: int, dport: int,
                ports_analysis: list[dict]) -> None:
    """Print informations after analysis

    Args:
        IP: Target Ip
        sport: Lower Band Port to scan
        dport: Upper Band Port to scan
        ports_analysis: extracted ports
    """
    print(f"Scanning {ip} from {sport} to {dport}...")
    if ports_analysis:
        for port in ports_analysis:
            if port:
                print(
                    f"[+] Port {port['port']} Open: {port['service']} "
                    f"{check_vulnerability(port['service'])}"
                )
    else:
        print("No Port Discovered")


def guess_service(ip: str, port: int) -> str:
    """If banner is Unknown, try to guess service on port

    Args:
        ip: Target IP
        port: Port to scan

    Returns:
        Guessed service or "No Guessed Service"
    """
    COMMON_PORTS = {
        21: "FTP",
        22: "SSH",
        80: "HTTP",
        443: "HTTPS",
        3306: "MySQL"
    }

    banner = get_banner(ip, port)
    if banner == "Unknown":
        if port in COMMON_PORTS.keys():
            return f"{COMMON_PORTS.get(port)} (Guessed)"
        else:
            return "No Service Guessed"

    return ""


def check_vulnerability(banner: str) -> str:
    """Checks for a potential backdoor with the banner

    Args:
        banner: The actual banner to test

    Returns:
        Banner Vulnerability Check
    """
    BAD_SIGNS = {
        "vsftpd 2.3.4",
        "vsftpd 3.0.5",
        "Apache 2.2.8"
    }

    for sign in BAD_SIGNS:
        if banner.lower() in sign.lower():
            return "[VULNERABLE]"

    return ""


def generate_json_report(filename: str, ports_analytics: list[dict]) -> None:
    """Generate human-readable report with JSON format

    Args:
        filename: path or direct filename to write
        ports_analytics: data to write
    """
    to_json_str_data = json.dumps(ports_analytics, indent=2)
    with open(filename, "w") as file:
        file.write(to_json_str_data)
        file.write('\n')


def main() -> None:
    """Program Entry Point"""
    # print("NetProbe v1.0 initialized...")
    # print(f"Port 80 is open: {check_port('google.com', 80)}")
    # print(f"Port 81 is open: {check_port('google.com', 81)}")

    # print(ping_sweep("192.168.1"))
    # print(get_banner("scanme.nmap.org", 80))

    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--target",
                        help="Target IP",
                        required=True)
    parser.add_argument("-p", "--ports",
                        required=True,
                        help="Port range to scan")
    parser.add_argument("-o", "--output",
                        help="Generate report to file")
    parser.add_argument("-d", "--delay",
                        help="Set a delay between ports analysis")

    args = parser.parse_args()
    sep_port = args.ports.find('-')

    ip = args.target
    lower_port = int(args.ports[:sep_port])
    upper_port = int(args.ports[sep_port + 1:])

    global delay
    if args.delay:
        delay = float(args.delay)

    ports = scan_ports(ip, lower_port, upper_port)
    # print_infos(ip, lower_port, upper_port, ports)

    # if args.output and ports:
    #     generate_json_report(args.output, ports)

    # scan_ports(args.target, 21, 22)
    # print(guess_service("192.168.1.28", 80))
    # print(get_banner("localhost", 21))


if __name__ == '__main__':
    main()
