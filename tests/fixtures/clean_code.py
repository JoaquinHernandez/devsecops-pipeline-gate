cat << 'EOF' > tests/fixtures/clean_code.py
import requests

def fetch_data(url: str):
    # Compliant: Explicit TLS verification enabled
    response = requests.get(url, verify=True, timeout=5)
    return response.json()
EOF

cat << 'EOF' > tests/fixtures/vulnerable_code.py
import subprocess
import requests

def run_command(user_input: str):
    # Non-compliant: Command injection vulnerability (CWE-78)
    subprocess.call(f"echo {user_input}", shell=True)

def insecure_fetch(url: str):
    # Non-compliant: TLS verification bypassed (CWE-295)
    return requests.get(url, verify=False)
EOF
