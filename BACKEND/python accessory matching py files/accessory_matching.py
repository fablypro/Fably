from flask import Flask, request, render_template, jsonify # type: ignore
import os
import cv2 as c
import numpy as np
from sklearn import preprocessing # type: ignore
from dotenv import load_dotenv # type: ignore
import tensorflow as tf # type: ignore

import tensorflow_hub as hub # type: ignore

from werkzeug.utils import secure_filename # type: ignore

# logging for potential issues.
import logging

# importing form machine learning model.
from ml_model import (
    matching_colors_between_outfits_and_accessories, 
    extract_main_colors, 
    predict_accessory, 
    predict_outfit, 
    load_model_via_pretrained_CNN#, load_model
)


# loading environment variables from .env file.
load_dotenv()


# uploading files from following file paths.
UPLOAD_ACCESSORY_FOLDER = "static/images/accessories/"
BELT_FOLDER = os.path.join(UPLOAD_ACCESSORY_FOLDER, "belts")
CHAINS_FOLDER = os.path.join(UPLOAD_ACCESSORY_FOLDER, "chains")
GLASSES_FOLDER = os.path.join(UPLOAD_ACCESSORY_FOLDER, "glasses")
GLOVES_FOLDER = os.path.join(UPLOAD_ACCESSORY_FOLDER, "gloves")
HANDBAG_FOLDER = os.path.join(UPLOAD_ACCESSORY_FOLDER, "handbags")
HAT_FOLDER = os.path.join(UPLOAD_ACCESSORY_FOLDER, "hats")
RING_FOLDER = os.path.join(UPLOAD_ACCESSORY_FOLDER, "rings")
SHOE_FOLDER = os.path.join(UPLOAD_ACCESSORY_FOLDER, "shoes")
SOCK_FOLDER = os.path.join(UPLOAD_ACCESSORY_FOLDER, "socks")
WATCH_FOLDER = os.path.join(UPLOAD_ACCESSORY_FOLDER, "watches")

UPLOAD_FOLDER = "static/images/"
OUTFIT_FOLDER = os.path.join(UPLOAD_FOLDER, "outfits")

# allowed file extensions. 
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
# maximum length of 16MB.
MAX_CONTENT_LENGTH = 16 * 1024 * 1024


# creating feature app for accessory matching.
feature = Flask(__name__)

# uploading the folders.
feature.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER
feature.config["UPLOAD_ACCESSORY_FOLDER"] = UPLOAD_ACCESSORY_FOLDER

# file size limit for extra security for the program.
feature.config["MAX_CONTENT_LENGTH"] = MAX_CONTENT_LENGTH


# to ensure the accessory and outfit folders exist.
os.makedirs(BELT_FOLDER, exist_ok=True)
os.makedirs(CHAINS_FOLDER, exist_ok=True)
os.makedirs(GLASSES_FOLDER, exist_ok=True)
os.makedirs(GLOVES_FOLDER, exist_ok=True)
os.makedirs(HANDBAG_FOLDER, exist_ok=True)
os.makedirs(HAT_FOLDER, exist_ok=True)
os.makedirs(RING_FOLDER, exist_ok=True)
os.makedirs(SHOE_FOLDER, exist_ok=True)
os.makedirs(SOCK_FOLDER, exist_ok=True)
os.makedirs(WATCH_FOLDER, exist_ok=True)

os.makedirs(OUTFIT_FOLDER, exist_ok=True)


logging.basicConfig(level=logging.INFO)


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
        if ('belts' not in request.files
            or 'chains' not in request.files
            or 'glasses' not in request.files
            or 'gloves' not in request.files
            or 'handbags' not in request.files
            or 'hats' not in request.files
            or 'rings' not in request.files
            or 'shoes' not in request.files
            or 'socks' not in request.files
            or 'watches' not in request.files
            
            or 'outfit' not in request.files):
            return jsonify({"error": "No File Part."}), 400
        
        
        # requesting the files.
        belts_file = request.files['belts']
        chains_file = request.files['chains']
        glasses_file = request.files['glasses']
        gloves_file = request.files['gloves']
        handbags_file = request.files['handbags']
        hats_file = request.files['hats']
        rings_file = request.files['rings']
        shoes_file = request.files['shoes']
        socks_file = request.files['socks']
        watches_file = request.files['watches']
        
        outfit_file = request.files['outfit']
        
        
        # if file names are null.
        if (belts_file.filename == ''
            or chains_file.filename == ''
            or glasses_file.filename == ''
            or gloves_file.filename == ''
            or handbags_file.filename == ''
            or hats_file.filename == ''
            or rings_file.filename == ''
            or shoes_file.filename == ''
            or socks_file.filename == ''
            or watches_file.filename == ''
            
            or outfit_file.filename == ''):
            return jsonify({"error": "No Selected File."}), 400
        
        # if files are not allowed.
        if (not (allowed_file(belts_file.filename) 
                 and allowed_file(chains_file.filename)
                 and allowed_file(glasses_file.filename)
                 and allowed_file(gloves_file.filename)
                 and allowed_file(handbags_file.filename)
                 and allowed_file(hats_file.filename)
                 and allowed_file(rings_file.filename)
                 and allowed_file(shoes_file.filename)
                 and allowed_file(socks_file.filename)
                 and allowed_file(watches_file.filename)
                 
                 and allowed_file(outfit_file.filename)
                 )):
            return jsonify({"error": "Invalid File Format."}), 400


        # saving and securing filenames.
        belts_filename = secure_filename(belts_file.filename)
        chains_filename = secure_filename(chains_file.filename)
        glasses_filename = secure_filename(glasses_file.filename)
        gloves_filename = secure_filename(gloves_file.filename)
        handbags_filename = secure_filename(handbags_file.filename)
        hats_filename = secure_filename(hats_file.filename)
        rings_filename = secure_filename(rings_file.filename)
        shoes_filename = secure_filename(shoes_file.filename)
        socks_filename = secure_filename(socks_file.filename)
        watches_filename = secure_filename(watches_file.filename)
        
        outfit_filename = secure_filename(outfit_file.filename)


        belts_filepath = os.path.join(BELT_FOLDER, belts_filename)
        chains_filepath = os.path.join(CHAINS_FOLDER, chains_filename)
        glasses_filepath = os.path.join(ACCESSORY_FOLDER, glasses_filename)
        gloves_filepath = os.path.join(ACCESSORY_FOLDER, gloves_filename)
        handbags_filepath = os.path.join(ACCESSORY_FOLDER, handbags_filename)
        hats_filepath = os.path.join(ACCESSORY_FOLDER, hats_filename)
        rings_filepath = os.path.join(ACCESSORY_FOLDER, rings_filename)
        shoes_filepath = os.path.join(ACCESSORY_FOLDER, shoes_filename)
        socks_filepath = os.path.join(ACCESSORY_FOLDER, socks_filename)
        watches_filepath = os.path.join(ACCESSORY_FOLDER, watches_filename)
        
        outfit_filepath = os.path.join(OUTFIT_FOLDER, outfit_filename)
        
        
        accessory_file.save(accessory_filepath)
               
        outfit_file.save(outfit_filepath)


        try:
            # reading the images with color.
            accessory_img_inputed = c.imread(os.path.join(accessory_filepath), c.IMREAD_COLOR)
            accessory_img_inputed = c.imread(os.path.join(accessory_filepath), c.IMREAD_COLOR)
            accessory_img_inputed = c.imread(os.path.join(accessory_filepath), c.IMREAD_COLOR)
            accessory_img_inputed = c.imread(os.path.join(accessory_filepath), c.IMREAD_COLOR)
            accessory_img_inputed = c.imread(os.path.join(accessory_filepath), c.IMREAD_COLOR)
            accessory_img_inputed = c.imread(os.path.join(accessory_filepath), c.IMREAD_COLOR)
            accessory_img_inputed = c.imread(os.path.join(accessory_filepath), c.IMREAD_COLOR)
            accessory_img_inputed = c.imread(os.path.join(accessory_filepath), c.IMREAD_COLOR)
            accessory_img_inputed = c.imread(os.path.join(accessory_filepath), c.IMREAD_COLOR)
            accessory_img_inputed = c.imread(os.path.join(accessory_filepath), c.IMREAD_COLOR)
            
            outfit_img_inputed = c.imread(os.path.join(outfit_filepath), c.IMREAD_COLOR)
            # read both images.
            if (accessory_img_inputed is None 
                or outfit_img_inputed is None):
                raise ValueError("Failed to Read Image.")

 
            # using the normal model.
     #       accessory_model = load_model()
     #       outfit_model = load_model()


            # finding any match for the accessory.
     #       accessory_confidence, accessory_prediction = predict_accessory(accessory_img_inputed, accessory_model)
     #       accessory_match_found = accessory_prediction == 1
            # finding any match for the outfit.
     #       outfit_confidence, outfit_prediction = predict_outfit(outfit_img_inputed, outfit_model)
     #       outfit_match_found = outfit_prediction == 1
     

            # using the pretrained model.
            pretrained_belt_model = load_model_via_pretrained_CNN()
            pretrained_chains_model = load_model_via_pretrained_CNN()
            pretrained_accessory_model = load_model_via_pretrained_CNN()
            pretrained_accessory_model = load_model_via_pretrained_CNN()
            pretrained_accessory_model = load_model_via_pretrained_CNN()
            pretrained_accessory_model = load_model_via_pretrained_CNN()
            pretrained_accessory_model = load_model_via_pretrained_CNN()
            pretrained_accessory_model = load_model_via_pretrained_CNN()
            pretrained_accessory_model = load_model_via_pretrained_CNN()
            pretrained_accessory_model = load_model_via_pretrained_CNN()
            
            pretrained_outfit_model = load_model_via_pretrained_CNN()
                        
            
            # finding any match for each accessory.
            pretrained_accessory_confidence, pretrained_accessory_prediction = predict_accessory(accessory_img_inputed, pretrained_accessory_model)
            pretrained_accessory_match_found = pretrained_accessory_prediction == 1
            
            pretrained_accessory_confidence, pretrained_accessory_prediction = predict_accessory(accessory_img_inputed, pretrained_accessory_model)
            pretrained_accessory_match_found = pretrained_accessory_prediction == 1
            
            pretrained_accessory_confidence, pretrained_accessory_prediction = predict_accessory(accessory_img_inputed, pretrained_accessory_model)
            pretrained_accessory_match_found = pretrained_accessory_prediction == 1
            
            pretrained_accessory_confidence, pretrained_accessory_prediction = predict_accessory(accessory_img_inputed, pretrained_accessory_model)
            pretrained_accessory_match_found = pretrained_accessory_prediction == 1
            
            pretrained_accessory_confidence, pretrained_accessory_prediction = predict_accessory(accessory_img_inputed, pretrained_accessory_model)
            pretrained_accessory_match_found = pretrained_accessory_prediction == 1
            
            pretrained_accessory_confidence, pretrained_accessory_prediction = predict_accessory(accessory_img_inputed, pretrained_accessory_model)
            pretrained_accessory_match_found = pretrained_accessory_prediction == 1
            
            pretrained_accessory_confidence, pretrained_accessory_prediction = predict_accessory(accessory_img_inputed, pretrained_accessory_model)
            pretrained_accessory_match_found = pretrained_accessory_prediction == 1
            
            pretrained_accessory_confidence, pretrained_accessory_prediction = predict_accessory(accessory_img_inputed, pretrained_accessory_model)
            pretrained_accessory_match_found = pretrained_accessory_prediction == 1
            
            pretrained_accessory_confidence, pretrained_accessory_prediction = predict_accessory(accessory_img_inputed, pretrained_accessory_model)
            pretrained_accessory_match_found = pretrained_accessory_prediction == 1
            
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

     #           "match found message": "Match Found!" 
     #           if (accessory_match_found 
     #               and outfit_match_found 
     #               and color_match_found) 
     #           else "No Match Found!"

     #           "accessory match found": accessory_match_found,
     #           "accessory confidence": accessory_confidence, 
     #           "accessory prediction": accessory_prediction,
                
     #           "outfit match found": outfit_match_found,
     #           "outfit confidence": outfit_confidence, 
     #           "outfit prediction": outfit_prediction,
                
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


