#!/usr/bin/env python3

import requests


MOCK_BASE_API = "http://localhost:5000"
REQUEST_TIMEOUT = 5


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


if __name__ == '__main__':
    print(query_virustotal('1.2.3.4'))
    print(query_abuseipdb('9.8.7.6'))
