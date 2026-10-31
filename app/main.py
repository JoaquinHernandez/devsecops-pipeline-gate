cat << 'EOF' > app/main.py
import logging
from flask import Flask, jsonify

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("SecureApp")

app = Flask(__name__)

@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({"status": "healthy", "service": "devsecops-pipeline-target"}), 200

@app.route("/api/v1/status", methods=["GET"])
def status_info():
    return jsonify({"environment": "production", "tls_enforced": True}), 200

if __name__ == "__main__":
    logger.info("Starting production service listener on port 8080...")
    # Safe production default: debug is disabled
    app.run(host="0.0.0.0", port=8080, debug=False)
EOF
