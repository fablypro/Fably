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
        # the dictionary of requested accessory and outfit folders.
        all_accessory_and_outfit_files = {
            'belts': request.files['belts'] if "" in request.files else None,
            'chains': request.files['chains'] if "" in request.files else None,
            'glasses': request.files['glasses'] if "" in request.files else None,
            'gloves': request.files['gloves'] if "" in request.files else None,
            'handbags': request.files['handbags'] if "" in request.files else None,
            'hats': request.files['hats'] if "" in request.files else None,
            'rings': request.files['rings'] if "" in request.files else None,
            'shoes': request.files['shoes'] if "" in request.files else None,
            'socks': request.files['socks'] if "" in request.files else None,
            'watches': request.files['watches'] if "" in request.files else None,
            
            'outfit': request.files['outfit'] if "" in request.files else None
        }
        
        
        
        
        
        # if file names are null, and if files are not allowed.
        for file_type, file in all_accessory_and_outfit_files.items():
            if file.filename == "":
                return jsonify({"error": f"No Selected File for {file_type}."}), 400
            if not allowed_file(file.filename):
                return jsonify({"error": f"Invalid File Format for {file_type}."}), 400


        file_paths = {}
        for file_type, file in files.items():
            filename = secure_filename(file.filename)
            folder = os.path.join(folder, filename)


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
        glasses_filepath = os.path.join(GLASSES_FOLDER, glasses_filename)
        gloves_filepath = os.path.join(GLOVES_FOLDER, gloves_filename)
        handbags_filepath = os.path.join(HANDBAG_FOLDER, handbags_filename)
        hats_filepath = os.path.join(HAT_FOLDER, hats_filename)
        rings_filepath = os.path.join(RING_FOLDER, rings_filename)
        shoes_filepath = os.path.join(SHOE_FOLDER, shoes_filename)
        socks_filepath = os.path.join(SOCK_FOLDER, socks_filename)
        watches_filepath = os.path.join(WATCH_FOLDER, watches_filename)
        
        outfit_filepath = os.path.join(OUTFIT_FOLDER, outfit_filename)
        
        
        belts_file.save(belts_filepath)
        chains_file.save(chains_filepath)
        glasses_file.save(glasses_filepath)
        gloves_file.save(gloves_filepath)
        handbags_file.save(handbags_filepath)
        hats_file.save(hats_filepath)
        rings_file.save(rings_filepath)
        shoes_file.save(shoes_filepath)
        socks_file.save(socks_filepath)
        watches_file.save(watches_filepath)
               
        outfit_file.save(outfit_filepath)


        try:
            # reading the images with color.
            belts_img_inputed = c.imread(os.path.join(belts_filepath), c.IMREAD_COLOR)
            chains_img_inputed = c.imread(os.path.join(chains_filepath), c.IMREAD_COLOR)
            glasses_img_inputed = c.imread(os.path.join(glasses_filepath), c.IMREAD_COLOR)
            gloves_img_inputed = c.imread(os.path.join(gloves_filepath), c.IMREAD_COLOR)
            handbags_img_inputed = c.imread(os.path.join(handbags_filepath), c.IMREAD_COLOR)
            hats_img_inputed = c.imread(os.path.join(hats_filepath), c.IMREAD_COLOR)
            rings_img_inputed = c.imread(os.path.join(rings_filepath), c.IMREAD_COLOR)
            shoes_img_inputed = c.imread(os.path.join(shoes_filepath), c.IMREAD_COLOR)
            socks_img_inputed = c.imread(os.path.join(socks_filepath), c.IMREAD_COLOR)
            watches_img_inputed = c.imread(os.path.join(watches_filepath), c.IMREAD_COLOR)
            
            outfit_img_inputed = c.imread(os.path.join(outfit_filepath), c.IMREAD_COLOR)
            
            # read both images.
            if (belts_img_inputed is None
                or chains_img_inputed is None
                or glasses_img_inputed is None
                or gloves_img_inputed is None
                or handbags_img_inputed is None
                or hats_img_inputed is None
                or rings_img_inputed is None
                or shoes_img_inputed is None
                or socks_img_inputed is None
                or watches_img_inputed is None
                
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
            pretrained_glasses_model = load_model_via_pretrained_CNN()
            pretrained_gloves_model = load_model_via_pretrained_CNN()
            pretrained_handbags_model = load_model_via_pretrained_CNN()
            pretrained_hats_model = load_model_via_pretrained_CNN()
            pretrained_rings_model = load_model_via_pretrained_CNN()
            pretrained_shoes_model = load_model_via_pretrained_CNN()
            pretrained_socks_model = load_model_via_pretrained_CNN()
            pretrained_watches_model = load_model_via_pretrained_CNN()
            
            pretrained_outfit_model = load_model_via_pretrained_CNN()
                        
            
            # finding any match for each accessory.
            # belts.
            pretrained_belts_confidence, pretrained_belts_prediction = predict_accessory(belts_img_inputed, pretrained_belt_model)
            pretrained_belts_match_found = pretrained_belts_prediction == 1
            # chains.
            pretrained_chains_confidence, pretrained_chains_prediction = predict_accessory(chains_img_inputed, pretrained_chains_model)
            pretrained_chains_match_found = pretrained_chains_prediction == 1
            # glasses.
            pretrained_glasses_confidence, pretrained_glasses_prediction = predict_accessory(glasses_img_inputed, pretrained_glasses_model)
            pretrained_glasses_match_found = pretrained_glasses_prediction == 1
            # gloves.
            pretrained_gloves_confidence, pretrained_gloves_prediction = predict_accessory(gloves_img_inputed, pretrained_gloves_model)
            pretrained_gloves_match_found = pretrained_gloves_prediction == 1
            # handbags.
            pretrained_handbags_confidence, pretrained_handbags_prediction = predict_accessory(handbags_img_inputed, pretrained_handbags_model)
            pretrained_handbags_match_found = pretrained_handbags_prediction == 1
            # hats.
            pretrained_hats_confidence, pretrained_hats_prediction = predict_accessory(hats_img_inputed, pretrained_hats_model)
            pretrained_hats_match_found = pretrained_hats_prediction == 1
            # rings.
            pretrained_rings_confidence, pretrained_rings_prediction = predict_accessory(rings_img_inputed, pretrained_rings_model)
            pretrained_rings_match_found = pretrained_rings_prediction == 1
            # shoes.
            pretrained_shoes_confidence, pretrained_shoes_prediction = predict_accessory(shoes_img_inputed, pretrained_shoes_model)
            pretrained_shoes_match_found = pretrained_shoes_prediction == 1
            # socks.
            pretrained_socks_confidence, pretrained_socks_prediction = predict_accessory(socks_img_inputed, pretrained_socks_model)
            pretrained_socks_match_found = pretrained_socks_prediction == 1
            # watches.
            pretrained_watches_confidence, pretrained_watches_prediction = predict_accessory(watches_img_inputed, pretrained_watches_model)
            pretrained_watches_match_found = pretrained_watches_prediction == 1
            
            # finding any match for the outfit.
            pretrained_outfit_confidence, pretrained_outfit_prediction = predict_outfit(outfit_img_inputed, pretrained_outfit_model)
            pretrained_outfit_match_found = pretrained_outfit_prediction == 1


            # extracting colors from the images.
            extract_colors_from_belts = extract_main_colors(belts_img_inputed)
            extract_colors_from_chains = extract_main_colors(chains_img_inputed)
            extract_colors_from_glasses = extract_main_colors(glasses_img_inputed)
            extract_colors_from_gloves = extract_main_colors(gloves_img_inputed)
            extract_colors_from_handbags = extract_main_colors(handbags_img_inputed)
            extract_colors_from_hats = extract_main_colors(hats_img_inputed)
            extract_colors_from_rings = extract_main_colors(rings_img_inputed)
            extract_colors_from_shoes = extract_main_colors(shoes_img_inputed)
            extract_colors_from_socks = extract_main_colors(socks_img_inputed)
            extract_colors_from_watches = extract_main_colors(watches_img_inputed)
            
            extract_colors_from_outfit = extract_main_colors(outfit_img_inputed)
            
            # matching thew colors between accessory and outfit.
            belts_color_match_found = matching_colors_between_outfits_and_accessories(extract_colors_from_belts, extract_colors_from_outfit)
            chains_color_match_found = matching_colors_between_outfits_and_accessories(extract_colors_from_chains, extract_colors_from_outfit)
            glasses_color_match_found = matching_colors_between_outfits_and_accessories(extract_colors_from_glasses, extract_colors_from_outfit)
            gloves_color_match_found = matching_colors_between_outfits_and_accessories(extract_colors_from_gloves, extract_colors_from_outfit)
            handbags_color_match_found = matching_colors_between_outfits_and_accessories(extract_colors_from_handbags, extract_colors_from_outfit)
            hats_color_match_found = matching_colors_between_outfits_and_accessories(extract_colors_from_hats, extract_colors_from_outfit)
            rings_color_match_found = matching_colors_between_outfits_and_accessories(extract_colors_from_rings, extract_colors_from_outfit)
            shoes_color_match_found = matching_colors_between_outfits_and_accessories(extract_colors_from_shoes, extract_colors_from_outfit)
            socks_color_match_found = matching_colors_between_outfits_and_accessories(extract_colors_from_socks, extract_colors_from_outfit)
            watches_color_match_found = matching_colors_between_outfits_and_accessories(extract_colors_from_watches, extract_colors_from_outfit)


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
                
                "pretrained accessory match found": bool(pretrained_belts_match_found,
                                                         pretrained_chains_match_found,
                                                         pretrained_glasses_match_found,
                                                         pretrained_gloves_match_found,
                                                         pretrained_handbags_match_found,
                                                         pretrained_hats_match_found,
                                                         pretrained_rings_match_found,
                                                         pretrained_shoes_match_found,
                                                         pretrained_socks_match_found,
                                                         pretrained_watches_match_found),
                
                "pretrained accessory confidence": float(pretrained_belts_confidence,
                                                         pretrained_chains_confidence,
                                                         pretrained_glasses_confidence,
                                                         pretrained_gloves_confidence,
                                                         pretrained_handbags_confidence,
                                                         pretrained_hats_confidence,
                                                         pretrained_rings_confidence,
                                                         pretrained_shoes_confidence,
                                                         pretrained_socks_confidence,
                                                         pretrained_watches_confidence),
                
                "pretrained accessory prediction": int(pretrained_belts_prediction,
                                                         pretrained_chains_prediction,
                                                         pretrained_glasses_prediction,
                                                         pretrained_gloves_prediction,
                                                         pretrained_handbags_prediction,
                                                         pretrained_hats_prediction,
                                                         pretrained_rings_prediction,
                                                         pretrained_shoes_prediction,
                                                         pretrained_socks_prediction,
                                                         pretrained_watches_prediction),  
                
                "pretrained outfit match found": bool(pretrained_outfit_match_found),
                "pretrained outfit confidence": float(pretrained_outfit_confidence),
                "pretrained outfit prediction": int(pretrained_outfit_prediction),        
                
                "pretrained match found message": "Pretrained Match Found!" 
                if (pretrained_belts_match_found or pretrained_chains_match_found
                    or pretrained_glasses_match_found or pretrained_gloves_match_found
                    or pretrained_handbags_match_found or pretrained_hats_match_found
                    or pretrained_rings_match_found or pretrained_shoes_match_found
                    or pretrained_socks_match_found or pretrained_watches_match_found
                    
                    or pretrained_outfit_match_found) 
                else "No Pretrained Match Found!",
                
                "color match found message": "Color Match Found!" 
                if (belts_color_match_found or chains_color_match_found
                    or glasses_color_match_found or gloves_color_match_found
                    or handbags_color_match_found or hats_color_match_found
                    or rings_color_match_found or shoes_color_match_found
                    or socks_color_match_found or watches_color_match_found) 
                else "No Color Match Found!"
            })

        except Exception as e:
            print(f"Error in Image Processing: {e}")
            return jsonify({"error": "Error in Image Processing."}), 500

    except Exception as e:
        print(f"Error in File Uploading: {e}")
        return jsonify({"error": "Error File Uploading."}), 500


if __name__ == "__main__":
    feature.run(debug = True) # disable debug to 'False' in security of sensitive data or inforamtion.


