#!/usr/bin/env python3
"""LogHunter — high-performance log analysis engine."""

import argparse
import json
import multiprocessing
import re
from collections import Counter, defaultdict, deque
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Iterable, Iterator, List, Optional, Union

GEOIP_DB = {"1.2.3.4": "US", "5.6.7.8": "RU"}
BLACKLIST = {"10.0.0.1", "192.168.1.66"}
_BOT_SIGNATURES = ("sqlmap", "nikto", "curl", "python")

_APACHE_PATTERN = re.compile(
    r"^(?P<ip>\S+) \S+ \S+ \[(?P<date>[^\]]+)\] "
    r'"(?P<method>\S+) (?P<path>.*?)(?: HTTP/[\d.]+)?" '
    r"(?P<status>\d+) (?P<size>\S+)"
    r'(?: "(?P<referer>[^"]*)" "(?P<user_agent>[^"]*)")?'
)

_SYSLOG_PATTERN = re.compile(
    r"^(?P<date>[A-Z][a-z]{2}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2}) "
    r"(?P<host>\S+) (?P<process>\S+): (?P<message>.+)$"
)

_SYSLOG_IP_PATTERN = re.compile(
    r"from\s+(?P<ip>\d{1,3}(?:\.\d{1,3}){3})"
)

_SQLI_PATTERNS = [
    re.compile(r"union\s+select", re.IGNORECASE),
    re.compile(r"'\s*or\s+", re.IGNORECASE),
    re.compile(r"or\s+['\"]?1['\"]?\s*=\s*['\"]?", re.IGNORECASE),
    re.compile(r"--", re.IGNORECASE),
]

_XSS_PATTERNS = [
    re.compile(r"<\s*script", re.IGNORECASE),
    re.compile(r"javascript\s*:", re.IGNORECASE),
    re.compile(r"onload\s*=", re.IGNORECASE),
    re.compile(r"onerror\s*=", re.IGNORECASE),
    re.compile(r"onclick\s*=", re.IGNORECASE),
]


class LogEntry:
    """Normalized representation of a parsed log line.

    Attributes:
        ip: Source IP address.
        timestamp: Event time string from the log.
        service: Logical service name (``http`` or ``ssh``).
        message: Human-readable event description.
        raw_line: Original unparsed log line.
        method: HTTP method (Apache only).
        path: Request path (Apache only).
        status: HTTP status code (Apache only).
        size: Response size from the access log (Apache only).
        user_agent: Client user agent (Apache only, when present).
        source: Optional source label (e.g. log file origin).
        country: GeoIP country code (set by enrich_ip).
        is_bot: Whether automated tooling was detected.
        alert_level: Threat level (``HIGH`` or ``LOW``).
        attack_type: Detected attack label (``SQLi`` or ``XSS``).
    """

    def __init__(
        self,
        ip: str = "",
        timestamp: str = "",
        service: str = "",
        message: str = "",
        raw_line: str = "",
        method: str = "",
        path: str = "",
        status: Optional[int] = None,
        size: str = "",
        user_agent: str = "",
        source: str = "",
        **extra_fields: Any,
    ) -> None:
        """Initialize a normalized log entry."""
        self.ip = ip
        self.timestamp = timestamp
        self.service = service
        self.message = message
        self.raw_line = raw_line
        self.method = method
        self.path = path
        self.status = status
        self.size = size
        self.user_agent = user_agent
        self.source = source
        self.attack_type = None
        for field_name, field_value in extra_fields.items():
            setattr(self, field_name, field_value)


def read_stream(file_path: str) -> Iterator[str]:
    """Yield log lines one at a time without loading the whole file.

    Args:
        file_path: Path to the log file to read.

    Yields:
        Individual lines stripped of trailing newlines.
    """
    try:
        with open(file_path, encoding="utf-8") as handle:
            for line in handle:
                yield line.rstrip("\n\r")
    except FileNotFoundError:
        print(f"[ERROR] File not found: {file_path}")


def parse_apache_line(line: str) -> Optional[Dict[str, str]]:
    """Parse a single Apache/Nginx combined access log line.

    Args:
        line: Raw log line text.

    Returns:
        Dict with keys ip, date, method, path, status, size (and optional
        user_agent) when the line matches; otherwise None.
    """
    match = _APACHE_PATTERN.search(line)
    if match is None:
        return None
    return match.groupdict()


def parse_syslog_line(line: str) -> Optional[Dict[str, str]]:
    """Parse a single syslog line.

    Args:
        line: Raw log line text.

    Returns:
        Dict with keys date, host, process, message when matched; else None.
    """
    match = _SYSLOG_PATTERN.search(line)
    if match is None:
        return None
    return match.groupdict()


def normalize_entry(
    parsed_dict: Dict[str, str],
    log_type: str,
    raw_line: str = "",
) -> LogEntry:
    """Convert a parsed Apache or syslog dict into a unified LogEntry.

    Args:
        parsed_dict: Output from parse_apache_line or parse_syslog_line.
        log_type: Either ``apache`` or ``syslog``.
        raw_line: Original log line for traceability.

    Returns:
        Normalized LogEntry instance.
    """
    if log_type == "apache":
        status_value = int(parsed_dict["status"])
        user_agent = parsed_dict.get("user_agent") or ""
        path = parsed_dict.get("path") or ""
        method = parsed_dict.get("method") or ""
        message = f"{method} {path}".strip()
        return LogEntry(
            ip=parsed_dict["ip"],
            timestamp=parsed_dict["date"],
            service="http",
            message=message,
            raw_line=raw_line,
            method=method,
            path=path,
            status=status_value,
            size=parsed_dict.get("size") or "",
            user_agent=user_agent,
        )

    message = parsed_dict.get("message") or ""
    ip_match = _SYSLOG_IP_PATTERN.search(message)
    ip_address = ip_match.group("ip") if ip_match else ""
    return LogEntry(
        ip=ip_address,
        timestamp=parsed_dict["date"],
        service="ssh",
        message=message,
        raw_line=raw_line,
    )


def parse_timestamp(timestamp: str) -> Optional[datetime]:
    """Parse Apache or syslog timestamp strings into datetime objects.

    Args:
        timestamp: Raw timestamp text from a log entry.

    Returns:
        Parsed datetime, or None if the format is not recognized.
    """
    if not timestamp:
        return None
    text = timestamp.strip()
    apache_formats = ("%d/%b/%Y:%H:%M:%S %z", "%d/%b/%Y:%H:%M:%S")
    for fmt in apache_formats:
        try:
            parsed = datetime.strptime(text, fmt)
            if parsed.tzinfo is None:
                parsed = parsed.replace(tzinfo=timezone.utc)
            return parsed
        except ValueError:
            continue
    syslog_formats = ("%b %d %H:%M:%S", "%b  %d %H:%M:%S")
    for fmt in syslog_formats:
        try:
            parsed = datetime.strptime(text, fmt).replace(
                year=2026,
                tzinfo=timezone.utc,
            )
            return parsed
        except ValueError:
            continue
    return None


def _normalize_status(entry: LogEntry) -> Optional[int]:
    """Return the HTTP status code as an integer when available.

    Args:
        entry: Log entry that may store status as int or str.

    Returns:
        Integer status code, or None if not applicable.
    """
    status = getattr(entry, "status", None)
    if status is None:
        return None
    if isinstance(status, int):
        return status
    try:
        return int(status)
    except (TypeError, ValueError):
        return None


def _format_sample(entry: LogEntry) -> str:
    """Format a LogEntry for the sample display line."""
    parts = [
        f"ip={entry.ip}",
        f"service={entry.service}",
    ]
    if entry.service == "http":
        parts.append(f"status={entry.status}")
        parts.append(f"path={entry.path}")
    return " | ".join(parts)


def filter_logs(
    stream: Iterable[LogEntry],
    status_codes: Optional[List[int]] = None,
) -> Iterator[LogEntry]:
    """Yield log entries whose HTTP status is in the watch list.

    Args:
        stream: Iterable of normalized log entries.
        status_codes: Status codes to keep (default 404 and 500).

    Yields:
        Entries with a matching status; entries without status are skipped.
    """
    if status_codes is None:
        status_codes = [404, 500]
    allowed = set(status_codes)
    for entry in stream:
        status = getattr(entry, "status", None)
        if status in allowed:
            yield entry


def enrich_ip(log_entry: LogEntry) -> None:
    """Attach a GeoIP country code to the log entry.

    Args:
        log_entry: Entry whose ``ip`` field is looked up in GEOIP_DB.
    """
    log_entry.country = GEOIP_DB.get(log_entry.ip, "UNKNOWN")


def analyze_user_agent(log_entry: LogEntry) -> None:
    """Detect scanner or script signatures in HTTP-related fields.

    Args:
        log_entry: Entry updated with ``is_bot`` True or False.
    """
    user_agent = getattr(log_entry, "user_agent", "") or ""
    combined = (
        f"{user_agent} {log_entry.message} {log_entry.raw_line}"
    ).lower()
    log_entry.is_bot = any(
        signature in combined for signature in _BOT_SIGNATURES
    )


def check_threat_intel(log_entry: LogEntry) -> None:
    """Flag entries from blacklisted source IPs.

    Args:
        log_entry: Entry updated with ``alert_level`` HIGH or LOW.
    """
    if log_entry.ip in BLACKLIST:
        log_entry.alert_level = "HIGH"
    else:
        log_entry.alert_level = "LOW"


def detect_sqli(log_entry: LogEntry) -> None:
    """Detect SQL injection patterns in HTTP path or message.

    Args:
        log_entry: Entry updated with ``attack_type`` set to ``SQLi`` on match.
    """
    path = getattr(log_entry, "path", "") or ""
    scan_text = f"{path} {log_entry.message}"
    for pattern in _SQLI_PATTERNS:
        if pattern.search(scan_text):
            log_entry.attack_type = "SQLi"
            return


def detect_xss(log_entry: LogEntry) -> None:
    """Detect cross-site scripting patterns in the request path.

    Does not overwrite an existing ``SQLi`` classification.

    Args:
        log_entry: Entry updated with ``attack_type`` set to ``XSS`` on match.
    """
    if getattr(log_entry, "attack_type", None) == "SQLi":
        return
    path = getattr(log_entry, "path", "") or ""
    for pattern in _XSS_PATTERNS:
        if pattern.search(path):
            log_entry.attack_type = "XSS"
            return
    message = getattr(log_entry, "message", "") or ""
    for pattern in _XSS_PATTERNS:
        if pattern.search(message):
            log_entry.attack_type = "XSS"
            return


def detect_bruteforce(
    entries: Iterable[LogEntry],
) -> Iterator[Dict[str, Any]]:
    """Yield brute-force alerts for IPs with excessive auth failures.

    Args:
        entries: Normalized log entries to analyze.

    Yields:
        Alert dicts when failure counts exceed five per IP.
    """
    http_failures: Counter = Counter()
    ssh_failures: Counter = Counter()
    for entry in entries:
        message = entry.message or ""
        if "Failed password" in message:
            ssh_ip = entry.ip
            if not ssh_ip:
                ip_match = _SYSLOG_IP_PATTERN.search(message)
                if ip_match:
                    ssh_ip = ip_match.group("ip")
            if ssh_ip:
                ssh_failures[ssh_ip] += 1
            continue

        status_code = _normalize_status(entry)
        if status_code == 401 and entry.ip:
            http_failures[entry.ip] += 1

    for ip_address, count in http_failures.items():
        if count > 5:
            yield {
                "ip": ip_address,
                "count": count,
                "alert_type": "BRUTE_FORCE",
            }
    for ip_address, count in ssh_failures.items():
        if count > 5:
            yield {
                "ip": ip_address,
                "count": count,
                "alert_type": "BRUTE_FORCE",
            }


def detect_burst(
    entries: Iterable[LogEntry],
    window_seconds: int = 60,
    threshold: int = 10,
) -> Iterator[Dict[str, Any]]:
    """Yield burst alerts when an IP exceeds a request rate threshold.

    Args:
        entries: Normalized log entries in chronological order.
        window_seconds: Sliding window size in seconds.
        threshold: Minimum requests in the window to trigger an alert.

    Yields:
        Alert dicts for IPs that exceed the burst threshold.
    """
    windows: Dict[str, deque] = defaultdict(deque)
    alerted: set = set()

    for entry in entries:
        if not entry.ip or entry.ip in alerted:
            continue
        event_time = parse_timestamp(entry.timestamp)
        if event_time is None:
            continue
        window = windows[entry.ip]
        window.append(event_time)
        cutoff = event_time - timedelta(seconds=window_seconds)
        while window and window[0] < cutoff:
            window.popleft()
        if len(window) >= threshold:
            alerted.add(entry.ip)
            yield {
                "ip": entry.ip,
                "count": len(window),
                "window": window_seconds,
                "alert_type": "BURST",
            }


def correlate_events(
    entries: Iterable[LogEntry],
) -> Iterator[Dict[str, Any]]:
    """Yield critical incidents when scanning is followed by SQLi.

    Args:
        entries: Entries with ``attack_type`` already set by detect_sqli.

    Yields:
        Critical incident alert dicts; per-IP state resets after each yield.
    """
    state: Dict[str, set] = defaultdict(set)
    for entry in entries:
        if not entry.ip:
            continue
        ip_address = entry.ip
        if _normalize_status(entry) == 404:
            state[ip_address].add("scanner")
        attack_type = getattr(entry, "attack_type", None)
        if attack_type == "SQLi" or attack_type == "sqli":
            state[ip_address].add("sqli")
        if "scanner" in state[ip_address] and "sqli" in state[ip_address]:
            yield {
                "ip": ip_address,
                "stages": ["scanner", "sqli"],
                "alert_type": "CRITICAL INCIDENT",
            }
            state[ip_address].clear()


def _enrich_and_detect(entry: LogEntry) -> None:
    """Run enrichment and per-entry detection on one log record."""
    enrich_ip(entry)
    analyze_user_agent(entry)
    check_threat_intel(entry)
    detect_sqli(entry)
    detect_xss(entry)


def process_chunk(lines: List[str]) -> List[LogEntry]:
    """Parse and enrich a chunk of raw log lines (worker function).

    Args:
        lines: Raw log lines from the input file.

    Returns:
        List of normalized and enriched LogEntry objects.
    """
    entries: List[LogEntry] = []
    for raw_line in lines:
        if not raw_line:
            continue
        apache_parsed = parse_apache_line(raw_line)
        if apache_parsed is not None:
            entry = normalize_entry(apache_parsed, "apache", raw_line)
            _enrich_and_detect(entry)
            entries.append(entry)
            continue
        syslog_parsed = parse_syslog_line(raw_line)
        if syslog_parsed is not None:
            entry = normalize_entry(syslog_parsed, "syslog", raw_line)
            _enrich_and_detect(entry)
            entries.append(entry)
    return entries


def parallel_analyze(
    file_path: str,
    num_workers: int,
    chunk_size: int = 5000,
) -> List[LogEntry]:
    """Analyze a log file using a multiprocessing worker pool.

    Args:
        file_path: Path to the log file.
        num_workers: Number of parallel worker processes.
        chunk_size: Number of lines per worker chunk.

    Returns:
        Merged list of processed log entries.
    """
    try:
        with open(file_path, encoding="utf-8") as handle:
            lines = [line.rstrip("\n\r") for line in handle]
    except FileNotFoundError:
        print(f"[ERROR] File not found: {file_path}")
        return []

    chunks = [
        lines[index:index + chunk_size]
        for index in range(0, len(lines), chunk_size)
    ]
    entries: List[LogEntry] = []
    with multiprocessing.Pool(processes=num_workers) as pool:
        for chunk_entries in pool.map(process_chunk, chunks):
            entries.extend(chunk_entries)
    return entries


def load_entries_sequential(file_path: str) -> List[LogEntry]:
    """Parse and enrich a log file on a single thread.

    Args:
        file_path: Path to the log file.

    Returns:
        List of processed log entries.
    """
    return process_chunk(list(read_stream(file_path)))


def _alert_to_dict(alert: Union[Dict[str, Any], LogEntry]) -> Dict[str, Any]:
    """Convert an alert or LogEntry into a JSON-serializable dictionary."""
    if isinstance(alert, dict):
        return alert
    if isinstance(alert, LogEntry):
        return {
            key: value
            for key, value in vars(alert).items()
            if not key.startswith("_")
        }
    return {"value": str(alert)}


def export_report(
    alerts: List[Union[Dict[str, Any], LogEntry]],
    filename: str,
    format: str = "json",
) -> None:
    """Write alert data to a machine-readable report file.

    Args:
        alerts: Alert dictionaries and/or LogEntry objects.
        filename: Output file path.
        format: Report format (currently only ``json``).
    """
    if format != "json":
        raise ValueError(f"Unsupported report format: {format}")
    payload = [_alert_to_dict(alert) for alert in alerts]
    with open(filename, "w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2)
        handle.write("\n")


def _collect_alerts(entries: List[LogEntry]) -> List[Dict[str, Any]]:
    """Run aggregate detectors and return all alert dictionaries."""
    alerts: List[Dict[str, Any]] = []
    alerts.extend(detect_bruteforce(entries))
    alerts.extend(detect_burst(entries))
    alerts.extend(correlate_events(entries))
    return alerts


def _print_analysis(
    entries: List[LogEntry],
    sample_entry: Optional[LogEntry],
    alerts: List[Dict[str, Any]],
) -> None:
    """Print all analysis sections to stdout."""
    apache_count = sum(1 for entry in entries if entry.service == "http")
    syslog_count = sum(1 for entry in entries if entry.service == "ssh")

    print("--- Parsing ---")
    print(f"[*] Apache lines:  {apache_count}")
    print(f"[*] Syslog lines:  {syslog_count}")
    print(f"[*] Total parsed:  {len(entries)}")

    if sample_entry is not None:
        print("[*] Sample entry:")
        print(f"    {_format_sample(sample_entry)}")

    suspicious_count = sum(1 for _ in filter_logs(entries))
    print("--- Filtering ---")
    print(f"[*] Suspicious (404, 500): {suspicious_count}")

    known_ips = sum(
        1 for entry in entries
        if getattr(entry, "country", "UNKNOWN") != "UNKNOWN"
    )
    bot_count = sum(1 for entry in entries if getattr(entry, "is_bot", False))
    high_count = sum(
        1 for entry in entries
        if getattr(entry, "alert_level", "") == "HIGH"
    )

    print("--- Enrichment ---")
    print(
        f"[*] GeoIP: {len(entries)} entries enriched "
        f"({known_ips} known IPs)",
    )
    print(f"[*] Bots detected: {bot_count}")

    print("--- Threat Intelligence ---")
    print(
        f"[*] HIGH alerts: {high_count} entries from blacklisted IPs",
    )

    sqli_count = sum(
        1 for entry in entries
        if getattr(entry, "attack_type", None) == "SQLi"
    )
    xss_count = sum(
        1 for entry in entries
        if getattr(entry, "attack_type", None) == "XSS"
    )
    print("--- Attack Detection ---")
    print(f"[*] SQLi attempts: {sqli_count}")
    print(f"[*] XSS attempts:  {xss_count}")

    brute_alerts = [
        alert for alert in alerts if alert.get("alert_type") == "BRUTE_FORCE"
    ]
    print("--- Brute Force ---")
    print(f"[*] BRUTE_FORCE alerts: {len(brute_alerts)}")
    for alert in brute_alerts:
        print(f"    {alert['ip']}: {alert['count']} failures")

    burst_alerts = [
        alert for alert in alerts if alert.get("alert_type") == "BURST"
    ]
    print("--- Burst Detection ---")
    print(f"[*] BURST alerts: {len(burst_alerts)}")
    for alert in burst_alerts:
        print(
            f"    {alert['ip']}: {alert['count']} requests in "
            f"{alert['window']}s window",
        )

    critical_alerts = [
        alert for alert in alerts
        if alert.get("alert_type") == "CRITICAL INCIDENT"
    ]
    print("--- Correlation ---")
    if critical_alerts:
        print("[*] CRITICAL INCIDENTS:")
        for alert in critical_alerts:
            stages = " -> ".join(alert["stages"])
            print(f"    {alert['ip']}: {stages}")
    else:
        print("[*] CRITICAL INCIDENTS: 0")


def main() -> None:
    """CLI entry point: stream, parse, normalize, and report statistics."""
    parser = argparse.ArgumentParser(
        description="LogHunter log analysis engine",
    )
    parser.add_argument("file", help="Path to the log file to analyze")
    parser.add_argument(
        "--report",
        metavar="FILE",
        help="Export alerts to a JSON report file",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=0,
        help="Number of parallel workers (0 = single-threaded)",
    )
    args = parser.parse_args()

    print("[*] LogHunter - Log Analysis Engine")
    if args.workers > 0:
        print(
            f"[*] Reading: {args.file} (parallel: {args.workers} workers)",
        )
        entries = parallel_analyze(args.file, args.workers)
    else:
        print(f"[*] Reading: {args.file}")
        entries = load_entries_sequential(args.file)

    if not entries:
        print("[!] No data to process. Exiting.")
        return

    sample_entry = next(
        (entry for entry in entries if entry.ip == "10.0.0.1"),
        entries[0] if entries else None,
    )
    alerts = _collect_alerts(entries)
    _print_analysis(entries, sample_entry, alerts)

    if args.report:
        export_report(alerts, args.report)
        print(f"\n[*] Report exported: {args.report} ({len(alerts)} alerts)")
    else:
        print(f"\n[*] Total alerts: {len(alerts)}")
        print("[*] Use --report <file> to export.")


if __name__ == "__main__":
    main()
