import os
import bson
from db import accessory_collection
from feature_extraction import extract_features

ACCESSORY_DIR = "accessories/"

for filename in os.listdir(ACCESSORY_DIR):
    if filename.endswith((".jpg", ".png")):
        img_path = os.path.join(ACCESSORY_DIR, filename)
        features = extract_features(img_path)

        category = input(f"Enter category for {filename}: ")

        accessory_data = {
            "name": filename.split(".")[0],
            "image": filename,
            "category": category.lower(),
            "features": bson.Binary(features.tobytes())
        }
        accessory_collection.insert_one(accessory_data)

print("Accessories stored successfully!")
