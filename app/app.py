from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    return "Hello from EKS! Deployed with Terraform, Docker, ECR and Helm.\n"


@app.route("/healthz")
def healthz():
    return "ok\n", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
