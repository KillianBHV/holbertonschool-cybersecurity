#!/usr/bin/env python3

import argparse
import json
import socket
from concurrent.futures import ThreadPoolExecutor, as_completed


def check_port(ip: str, port: int) -> bool:
    """Checks if specified port on ip is open
    """
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(1)

        s.connect((ip, port))
        return True
    except socket.error:
        return False
    finally:
        s.close()


def ping_sweep(subnet: str) -> list:
    """Scan a specific range of ip on port 80
    """
    ips = []
    for k in range(1, 254):
        ip = f"{subnet}.{k}"
        print(ip)
        if check_port(ip, 80):
            ips.append(ip)

    return ips


def get_banner(ip: str, port: int) -> str:
    """Checks if a banner appears
    """
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(2)
        s.connect((ip, port))

        s.send(b"HEAD / HTTP/1.0\r\n\r\n")

        data = s.recv(1024)
        if not data:
            return "Unknown"

        return data.decode().strip()
    except socket.error:
        return "Unknown"
    finally:
        if s:
            s.close()


def guess_service(port: int) -> str:
    COMMON_PORTS = {
        21: "FTP",
        22: "SSH",
        80: "HTTP",
        443: "HTTPS",
        3306: "MySQL"
    }

    return COMMON_PORTS.get(port, "Unknown")


def _scan_single_port(ip: str, port: int) -> dict:
    """Checks ONE port
    """
    if check_port(ip, port):
        banner = get_banner(ip, port)
        is_vulnerable = "YES" if check_vulnerability(banner) else "NO"

        print(f"[+] Port {port} Open: {banner} {is_vulnerable}")
        return {
            "port": port,
            "state": "open",
            "service": f"{banner}",
            "vulnerability": f"{is_vulnerable}"}

    return None


def check_vulnerability(banner: str) -> str:
    """Search for known bad signatures
    """
    MALICIOUS_SIGNATURES = [
        "vsftpd 2.3.4",
        "Apache 2.2.8"
    ]

    for bad in MALICIOUS_SIGNATURES:
        if bad.lower() in banner.lower():
            return "[VULNERABLE]"
    return ""


def scan_ports(ip: str, start_port: int, end_port: int) -> list:
    """Get open ports
    """
    ports = []

    print(f"Scanning {ip} from {start_port} to {end_port}...")

    with ThreadPoolExecutor(max_workers=50) as executor:
        futures = []

        for port in range(start_port, end_port+1):
            future = executor.submit(_scan_single_port, ip, port)
            futures.append(future)

        for future in as_completed(futures):
            result = future.result()
            if result:
                ports.append(result)

    return ports


parser = argparse.ArgumentParser()

parser.add_argument("-t", "--target", help="Target IP")
parser.add_argument("-p", "--ports", help="Port range to scan")
parser.add_argument("-o",
                    "--output",
                    required=False,
                    help="Output JSON file",
                    default="scan_results.json")

args = parser.parse_args()


def main():
    print("NetProbe v1.0 initialized...")
    with open(args.output, 'w') as output:
        json.dump(scan_ports("scanme.nmap.org", 77, 83), output)


if __name__ == '__main__':
    main()
