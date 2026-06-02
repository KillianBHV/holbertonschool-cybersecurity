#!/bin/bash
cat > sniffer.sh << 'EOF'
#!/bin/bash
which python3
python3 -c "import sys; print(sys.executable)"
EOF

source ./sniffer.sh
