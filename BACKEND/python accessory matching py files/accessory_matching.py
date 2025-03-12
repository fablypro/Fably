from flask import Flask, request, render_template, jsonify # type: ignore
import os
import cv2 as c
import numpy as np
from sklearn import preprocessing # type: ignore
from dotenv import load_dotenv # type: ignore
import tensorflow as tf # type: ignore

import tensorflow_hub as hub # type: ignore

from werkzeug.utils import secure_filename # type: ignore

# importing form machine learning model.
from ml_model import (
    matching_colors_between_outfits_and_accessories, 
    extract_main_colors, 
    predict_accessory, 
    predict_outfit, 
    load_model_via_pretrained_CNN
)

# loading environment variables from .env file.
load_dotenv()

# uploading files from following file paths.
UPLOAD_FOLDER = "static/images/"
ACCESSORY_FOLDER = os.path.join(UPLOAD_FOLDER, "accessories")
OUTFIT_FOLDER = os.path.join(UPLOAD_FOLDER, "outfits")

# allowed file extensions. 
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
# maximum length of 16MB.
MAX_CONTENT_LENGTH = 16 * 1024 * 1024


# creating feature app for accessory matching.
feature = Flask(__name__)

# uploading the folders.
feature.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER
# file size limit for extra security for the program.
feature.config["MAX_CONTENT_LENGTH"] = MAX_CONTENT_LENGTH


# to ensure the accessory and outfit folders exist.
os.makedirs(ACCESSORY_FOLDER, exist_ok=True)
os.makedirs(OUTFIT_FOLDER, exist_ok=True)


# to ensure proper configuration for MAX_CONTENT_LENGTH.
@feature.errorhandler(413)
def request_too_large(error):
    return jsonify({"error": "File is Too Large! Max Content Length Exceeds 16MB."}), 413


# function for checking allowed file extensions.
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


# route for home page.
@feature.route('/')
def home():
    return render_template("Index.html")


# uploading the file via posting the data.
@feature.route('/upload', methods=["POST"])
def upload_file():

    try:
        # if the files have No parts for accessory or outfit.
        if 'accessory' not in request.files or 'outfit' not in request.files:
            return jsonify({"error": "No File Part."}), 400
        
        
        # requesting the files.
        accessory_file = request.files['accessory']
        outfit_file = request.files['outfit']
        
        
        # if file names are null.
        if accessory_file.filename == '' or outfit_file.filename == '':
            return jsonify({"error": "No Selected File."}), 400
        
        # if files are not allowed.
        if not (allowed_file(accessory_file.filename) and allowed_file(outfit_file.filename)):
            return jsonify({"error": "Invalid File Format."}), 400


        # saving and securing filenames.
        accessory_filename = secure_filename(accessory_file.filename)
        outfit_filename = secure_filename(outfit_file.filename)

        accessory_filepath = os.path.join(ACCESSORY_FOLDER, accessory_filename)
        outfit_filepath = os.path.join(OUTFIT_FOLDER, outfit_filename)
        
        accessory_file.save(accessory_filepath)        
        outfit_file.save(outfit_filepath)


        try:
            # reading the images with color.
            accessory_img_inputed = c.imread(os.path.join(accessory_filepath), c.IMREAD_COLOR)
            outfit_img_inputed = c.imread(os.path.join(outfit_filepath), c.IMREAD_COLOR)
            # read both images.
            if accessory_img_inputed is None or outfit_img_inputed is None:
                raise ValueError("Failed to Read Image.")


            # using the pretrained model.
            pretrained_accessory_model = load_model_via_pretrained_CNN()
            pretrained_outfit_model = load_model_via_pretrained_CNN()
            
            
            # finding any match for the accessory.
            pretrained_accessory_confidence, pretrained_accessory_prediction = predict_accessory(accessory_img_inputed, pretrained_accessory_model)
            pretrained_accessory_match_found = pretrained_accessory_prediction == 1
            # finding any match for the outfit.
            pretrained_outfit_confidence, pretrained_outfit_prediction = predict_outfit(outfit_img_inputed, pretrained_outfit_model)
            pretrained_outfit_match_found = pretrained_outfit_prediction == 1


            # extracting colors from the images.
            extract_colors_from_accessory = extract_main_colors(accessory_img_inputed)
            extract_colors_from_outfit = extract_main_colors(outfit_img_inputed)
            
            # matching thew colors between accessory and outfit.
            color_match_found = matching_colors_between_outfits_and_accessories(extract_colors_from_accessory, extract_colors_from_outfit)


            # sending predictions.
            return jsonify({
                "pretrained accessory match found": bool(pretrained_accessory_match_found), "pretrained accessory confidence": float(pretrained_accessory_confidence), "pretrained accessory prediction": int(pretrained_accessory_prediction),  
                
                "pretrained outfit match found": bool(pretrained_outfit_match_found), "pretrained outfit confidence": float(pretrained_outfit_confidence), "pretrained outfit prediction": int(pretrained_outfit_prediction),        
                
                "pretrained match found message": "Pretrained Match Found!" 
                if (pretrained_accessory_match_found 
                    and pretrained_outfit_match_found 
                    and color_match_found) 
                else "No Pretrained Match Found!"
            })

        except Exception as e:
            print(f"Error in Image Processing: {e}")
            return jsonify({"error": "Error in Image Processing."}), 500

    except Exception as e:
        print(f"Error in File Uploading: {e}")
        return jsonify({"error": "Error File Uploading."}), 500


if __name__ == "__main__":
    feature.run(debug = True) # disable debug to 'False' in security of sensitive data or inforamtion.


