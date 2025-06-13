#!/bin/bash

# نصب ابزارهای لازم
apt update && apt install -y wget unzip curl python3

# نصب subconverter
cd /opt
wget -O subconverter.zip https://github.com/tindy2013/subconverter/releases/latest/download/subconverter_linux64.zip
unzip subconverter.zip -d subconverter
cd subconverter
echo -e "[general]\nlisten = 0.0.0.0\nport = 25500" > pref.ini
chmod +x subconverter

# اجرای subconverter در بک‌گراند
nohup ./subconverter > /dev/null 2>&1 &

# نصب sing-box
cd /opt
wget -O sing-box.tar.gz https://github.com/SagerNet/sing-box/releases/latest/download/sing-box-linux-amd64.tar.gz
tar -xzf sing-box.tar.gz
mv sing-box-*/sing-box /usr/local/bin/
chmod +x /usr/local/bin/sing-box

# ساخت پوشه فیلتر و اسکریپت پایتون
mkdir -p ~/v2ray-filter
cd ~/v2ray-filter

cat > filter.py << 'EOF'
import requests, subprocess, base64

SUB_LINK = input("🔗 Enter your subscription link: ").strip()

b64 = requests.get(SUB_LINK).text.strip()
configs = base64.b64decode(b64).decode().splitlines()

good_configs = []

for idx, config in enumerate(configs):
    print(f"[{idx+1}/{len(configs)}] Testing...")
    try:
        result = subprocess.run(['sing-box', 'run', '--check', '--url', config],
                                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=10)
        if result.returncode == 0:
            good_configs.append(config)
    except:
        pass

with open("subscription.txt", "w") as f:
    f.write(base64.b64encode('\n'.join(good_configs).encode()).decode())

print(f"\n✅ {len(good_configs)} valid configs saved to subscription.txt")
print("🌐 Your subscription link:")
print("http://YOUR_SERVER_IP:8000/subscription.txt")
EOF

# راه‌اندازی وب سرور
cd ~/v2ray-filter
nohup python3 -m http.server 8000 > /dev/null 2>&1 &

echo -e "\n✅ نصب کامل شد!"
echo "📂 مسیر اسکریپت: ~/v2ray-filter/filter.py"
echo "🟢 اجرا: cd ~/v2ray-filter && python3 filter.py"
echo "🌐 آدرس نهایی فایل subscription بعد از تست:"
echo "   http://YOUR_SERVER_IP:8000/subscription.txt"