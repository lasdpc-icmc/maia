from flask import Flask, send_from_directory

app = Flask(__name__)

@app.route('/baynet')
def serve_html():
    return send_from_directory('.', 'structure_plot.html')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)

