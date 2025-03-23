import requests

url = "http://127.0.0.1:5000/upload"
image_path = "test_outfit.jpg"

with open(image_path, "rb") as img:
    files = {"file": img}
    response = requests.post(url, files=files)

print(response.json())
