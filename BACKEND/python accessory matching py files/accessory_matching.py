from flask import Flask, request, render_template, jsonify # type: ignore
import os
import cv2 as c
from dotenv import load_dotenv # type: ignore
import tensorflow as tf # type: ignore

#import tensorflow_hub as hub # type: ignore

from werkzeug.utils import secure_filename # type: ignore

# logging for potential issues.
import logging

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
        for file_type in all_accessory_and_outfit_files:
            if file_type not in all_accessory_and_outfit_files:
                return jsonify({"error": f"No File Part for {file_type}."}), 400
        
        required_files = {file_type: request.files[file_type] for file_type in all_accessory_and_outfit_files}
        
        # if file names are null, and if files are not allowed.
        for file_type, file in required_files.items():
            if file.filename == "":
                return jsonify({"error": f"No Selected File for {file_type}."}), 400
            if not allowed_file(file.filename):
                return jsonify({"error": f"Invalid File Format for {file_type}."}), 400
            if len(file.read()) > MAX_CONTENT_LENGTH:
                return jsonify({"error": f"Invalid File Format for {file_type}."}), 400


        try:
            # saving and securing filenames.
            file_paths = {}
            for file_type, file in required_files.items():
                filename = secure_filename(file.filename)
                given_folder = os.path.join(UPLOAD_ACCESSORY_FOLDER, file_type) if file_type != 'outfit' else OUTFIT_FOLDER
                filepath = os.path.join(given_folder, filename)
                file.save(filepath)
                file_paths[file_type] = filepath
        
        
            # reading the images with color.      
            images = {}
            for file_type, filepath in images.items():
                images[file_type] = c.imread(filepath, c.IMREAD_COLOR)
                if images[file_type] is None:
                    raise ValueError(f"Failed to Read Image for {file_type}.")
     

            # using the pretrained model.
            pretrained_model = load_model_via_pretrained_CNN()
            
            # finding matches for each accessory and for each outfit.
            predictions = {}
            for file_type, img in images.items():
                if file_type != 'outfit':
                    predictions[file_type] = predict_accessory(img, pretrained_model)
                else:
                    predictions[file_type] = predict_outfit(img, pretrained_model)
            
            # finding matches of colors between outfits and accessories.
            color_matches = {}
            outfit_colors = extract_main_colors(images['outfit'])
            for file_type, img in images.items():
                if file_type != 'outfit':
                    accessory_colors = extract_main_colors(img)
                    color_matches[file_type] = matching_colors_between_outfits_and_accessories(accessory_colors, outfit_colors)
            

            # sending predictions.
            results = {
                         
                "pretrained accessory prediction": {},
                "pretrained accessory confidence": {},
                "pretrained accessory match found": {},
                
                "pretrained outfit prediction": predictions['outfit'][1],
                "pretrained outfit confidence": float(predictions['outfit'][0]),
                "pretrained outfit match found": int(predictions['outfit'][1] == 1),
                
                "pretrained match found message": "No Pretrained Match Found!",
                
                "color match found message": "Color Match Found!"
            
            }
            
            
            for file_type, prediction in predictions.items():
                if file_type != 'outfit':
                    results["pretrained accessory prediction"][file_type] = prediction[1]
                    results["pretrained accessory confidence"][file_type] = float(prediction[0])
                    results["pretrained accessory match found"][file_type] = prediction[1] == 1
            
            for file_type, color_match in color_matches.items():
                if color_match == False:
                    results["color match found message"] = "No Color Match Found!"
            
            any_acc_match = False
            for file_type, acc_match in color_matches.items():
                if acc_match:
                    any_acc_match = True
                    break
            if results["pretrained outfit match found"] == 1:
                any_acc_match = True

            if any_acc_match:
                results["pretrained match found message"] = "Pretrained Match Found!"
            
            
            return jsonify(results)

        except ValueError as e:
            print(f"ValueError: {e}")
            logging.error(f"ValueError: {e}")
            return jsonify({"error": str(e)}), 500
        except Exception as e:
            print(f"Error in Image Processing: {e}")
            logging.error(f"Error: {e}")
            return jsonify({"error": "Error in Image Processing."}), 500

    except ValueError as e:
        print(f"ValueError: {e}")
        logging.error(f"ValueError: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"Error in File Uploading: {e}")
        logging.error(f"Error: {e}")
        return jsonify({"error": "Error File Uploading."}), 500


if __name__ == "__main__":
    feature.run(debug = False) # disable debug to 'False' in security of sensitive data or inforamtion.


