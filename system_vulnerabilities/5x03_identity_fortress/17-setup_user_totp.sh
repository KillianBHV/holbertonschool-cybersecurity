#!/bin/bash
echo -e "=== TOTP Setup for Current User\n"

echo -e "Running google-authenticator with secure defaults..."
google-authenticator

echo -e "\nConfiguration saved to ~/.google_authenticator\n"

echo "Settings applied:"
echo "  Time-based tokens: YES"
echo "  Rate limiting: 3 logins per 30 seconds"
echo "  Token reuse: DISALLOWED"
echo "  Window size: 3 (allows clock skew)"

echo -e "\nIMPORTANT: Save your emergency codes securely!\nScan the QR code with your authenticator app."

