from flask import Flask, request, render_template, jsonify # type: ignore
import os
import cv2 as c
import numpy as np
from sklearn import preprocessing # type: ignore
from dotenv import load_dotenv # type: ignore
import tensorflow as tf # type: ignore

from werkzeug.utils import secure_filename # type: ignore

# importing form machine learning model.
from ml_model import (
    matching_colors_between_outfits_and_accessories, 
    extract_main_colors, 
    predict_accessory, 
    predict_outfit, 
    load_model_via_pretrained_CNN, 
    #load_model
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







