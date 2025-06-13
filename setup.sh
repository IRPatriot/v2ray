#!/bin/bash

# نصب ابزارهای لازم
apt update && apt install curl wget unzip python3 python3-pip -y

# نصب subconverter
cd /opt
wget -O subconverter.zip https://github.com/tindy2013/subconverter/releases/latest/download/subconverter_linux64.zip
unzip subconverter.zip
cd subconverter
chmod +x subconverter

# اجرای subconverter در پس‌زمینه
nohup ./subconverter > /dev/null 2>&1 &

# نصب sing-box
cd /opt
wget -O sing-box.tar.gz https://github.com/SagerNet/sing-box/releases/latest/download/sing-box-linux-amd64.tar.gz
tar -xzf sing-box.tar.gz
mv sing-box-*/sing-box /usr/local/bin/sing-box
chmod +x /usr/local/bin/sing-box

# نصب اسکریپت تست و فیلتر
mkdir -p ~/v2ray-filter
cat > ~/v2ray-filter/filter.py << 'EOF'
import requests
import subprocess
import os
import http.server
import socketserver

def test_config(link):
    try:
        r = requests.get(link, timeout=10)
        if r.status_code == 200 and len(r.text) > 100:
            return True
    except:
        return False
    return False

def main():
    url = input("Enter your subscription link: ").strip()
    if not url:
        print("No URL provided")
        return

    print("Fetching configs...")
    try:
        response = requests.get(f"http://localhost:25500/sub?target=singbox&url={url}")
        if response.status_code != 200:
            print("Failed to fetch from subconverter")
            return
    except Exception as e:
        print("Error:", e)
        return

    lines = response.text.splitlines()
    valid = []
    print("Testing configs...")

    for line in lines:
        if test_config(line):
            valid.append(line)

    with open("subscription.txt", "w") as f:
        f.write('\n'.join(valid))

    print(f"{len(valid)} valid configs saved to subscription.txt")

    PORT = 8000
    handler = http.server.SimpleHTTPRequestHandler
    with socketserver.TCPServer(("", PORT), handler) as httpd:
        print(f"Serving subscription at http://YOUR_SERVER_IP:{PORT}/subscription.txt")
        httpd.serve_forever()

if __name__ == "__main__":
    main()
EOF

chmod +x ~/v2ray-filter/filter.py

echo ""
echo "✅  نصب کامل شد!"
echo "📂 مسیر اسکریپت: ~/v2ray-filter/filter.py"
echo "🟢 اجرا: cd ~/v2ray-filter && python3 filter.py"
echo "🌐 آدرس نهایی فایل subscription بعد از تست:"
echo "   http://YOUR_SERVER_IP:8000/subscription.txt"
