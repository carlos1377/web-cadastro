from flask import (
    Flask, render_template, request, jsonify
)
import subprocess
from pathlib import Path

app = Flask(__name__)

ROOT_FOLDER = Path(__file__).parent.parent

ROOT_IMAGES_FOLDER = ROOT_FOLDER

print(ROOT_IMAGES_FOLDER)


@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "GET":
        return render_template('index.html')

    ref_folder = request.form["folder"]
    type_ref = request.form["type_ref"]

    create_ref(ref_folder, type_ref)

    return jsonify({
        'ref_folder': ref_folder,
        'type_ref': type_ref
    })


def create_ref(folder_name: str, type: str):
    script = ROOT_FOLDER / 'ref.ps1'
    ref_folder = ROOT_IMAGES_FOLDER / folder_name
    subprocess.run(['pwsh', '-File', script, '--fold',
                   ref_folder, '--opt', type])
    # pwsh -File teste.ps1 --Fold "img" --opt 1
