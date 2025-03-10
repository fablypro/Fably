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








