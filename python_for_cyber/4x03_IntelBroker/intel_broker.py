#!/usr/bin/env python3

import argparse
import requests
import subprocess
import sys
import xml.etree.ElementTree as mod_ET


MOCK_BASE_API = "http://localhost:5000"
REQUEST_TIMEOUT = 5


class TargetDossier:
    """Group VirusTotal, AbuseIPDB and NMAP in order
    """
    def __init__(self, ip: str):
        self.ip = ip
        self.vt_data = query_virustotal(ip)
        self.vt_abuse = query_abuseipdb(ip)
        self.nmap_ports = []

        try:
            self.nmap_ports = parse_nmap_xml(run_nmap(ip))
        except (FileNotFoundError, RuntimeError):
            self.nmap_ports = []

    def print_summary(self) -> None:
        """Prints human-readable summary
        """
        score_vt = self.vt_data.get("reputation_score", "N/A")
        malicious_vt = self.vt_data.get("malicious", "N/A")
        score_abuse = self.vt_data.get("abuse_confidence_score", "N/A")
        reports_abuse = self.vt_data.get("reports", "N/A")

        print(f"= IntelBroker Dossier For <{self.ip}> =")
        print(
            f"VirusTotal:\nscore = {score_vt}\n"
            f"malicious = {malicious_vt}"
        )
        print(
            f"AbuseIPDB:\nconfidence = {score_abuse}\n"
            f"reports={reports_abuse}"
        )
        print(f"Nmap open ports: {self.nmap_ports}")


def query_virustotal(ip: str) -> dict["str", any]:
    """Query the mock VirusTotal API

    Args:
        ip: IPv4 or IPv6 string

    Returns:
        Parsed JSON or empty dict if it fails
    """
    url = f"{MOCK_BASE_API}/virustotal/{ip}"
    try:
        response = requests.get(url, timeout=REQUEST_TIMEOUT)
        if response.status_code == 200:
            return response.json()

        print(f"[ERROR] VirusTotal API returned status ", end='')
        print(response.status_code)

        return {}
    except requests.exceptions.ConnectionError:
        print("[ERROR] Could not connet at localhost:5000")
    except requests.exceptions.RequestException as ex:
        print(f"[ERROR] VirusTotal request failed: {ex}")


def query_abuseipdb(ip: str) -> dict["str", any]:
    """Query the mock AbuseIPDB API

    Args:
        ip: IPv4 or IPv6 string

    Returns:
        Parsed JSON or empty dict if it fails
    """
    url = f"{MOCK_BASE_API}/abuseipdb/{ip}"
    try:
        response = requests.get(url, timeout=REQUEST_TIMEOUT)
        if response.status_code == 200:
            return response.json()

        print(f"[ERROR] AbuseIPDB API returned status ", end='')
        print(response.status_code)

        return {}
    except requests.exceptions.ConnectionError:
        print("[ERROR] Could not connet at localhost:5000")
    except requests.exceptions.RequestException as ex:
        print(f"[ERROR] AbuseIPDB request failed: {ex}")


def run_nmap(ip: str) -> str:
    """Run nmap on common ports

    Args:
        ip: IPv4 or IPv6 to scan ports

    Returns:
        Raw XML output given by -oX Nmap option

    Raises:
        RuntimeError: If NMAP exits with non-zero return code
        FileNotFoundError: nmap binary not installed or unable to find
    """
    try:
        result = subprocess.run(
            ["nmap", "-p", "22,80", ip, "-oX", "-"],
            capture_output=True,
            check=False,
            text=True
        )
        if result.returncode == 0:
            return result.stdout
        else:
            err = result.stderr.strip() or "Unknown Error"
            raise RuntimeError(
                f"[ERROR] NMAP failed, exit with status {result.returncode}: "
                f"{err}"
            )
    except FileNotFoundError:
        print(
            "[ERROR] NMap not found. Please install/reinstall and try again",
            file=sys.stderr
        )
        raise


def parse_nmap_xml(xml_data: str) -> list:
    """Run nmap on common ports

    Args:
        xml_data: Raw XML data get from nmap

    Returns:
        List of open ports (numbers - e.g. [22, 80])
    """
    open_ports = []

    try:
        root = mod_ET.fromstring(xml_data)
        for host in root.findall("hosts"):
            ports = host.find("ports")
            if ports is None:
                continue

            for p in ports.findall("port"):
                state = port.find("state")
                if state is None or state.get("state") != "open":
                    continue

                port_id = port.get("portid")
                if port_id is not None:
                    open_ports.append(int(port_id))
    except mod_ET.ParseError as ex:
        print(f"[ERROR] Failed to parse Nmap XML: {ex}")

    return sorted(open_ports)


if __name__ == '__main__':
    """CLI Entry point
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("ip", help="Target IP address for investigation")
    args = parser.parse_args()

    dossier = TargetDossier(args.ip)
    dossier.print_summary()
