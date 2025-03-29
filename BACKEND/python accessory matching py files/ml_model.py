from flask import jsonify # type: ignore
import logging
import cv2 as c
import numpy as np
from dotenv import load_dotenv # type: ignore
import tensorflow as tf # type: ignore

import efficientnet.tfkeras as efn # type: ignore

# adding AI learning component.
from tensorflow.keras.applications import ResNet50 # type: ignore
from tensorflow.keras.applications.resnet50 import preprocess_input # type: ignore

from sklearn.cluster import KMeans # type: ignore
from sklearn.metrics.pairwise import cosine_similarity # type: ignore

# more features for color detection and matching.
from colormath.color_objects import sRGBColor, LabColor # type: ignore
from colormath.color_conversions import convert_color # type: ignore
from colormath.delta_e import delta_e_ciede2000 # type: ignore


# loading environment variables from .env file.
load_dotenv()


logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")




# load prediction model globally.
try:
    # validating the model.
    try:
        resNet50_model = ResNet50(weights='imagenet')
        print("Pretrained ResNet50 Model loaded successfully for prediction!")
        
    except ValueError as e:
        print(f"ResNet50 ValueError: {e}")
        logging.error(f"ResNet50 ValueError: {e}")
        jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"ResNet50 Error in loading model: {e}")
        logging.error(f"ResNet50 Error: {e}")
        resNet50_model = None
            
except ValueError as e:
    print(f"ResNet50 ValueError: {e}")
    logging.error(f"ResNet50 ValueError: {e}")
    jsonify({"error": str(e)}), 500
except Exception as e:
    print(f"Unknown ResNet50 Error: {e}")
    logging.error(f"ResNet50 Error: {e}")
    raise ValueError("Unknown ResNet50 Error occured.")

# function for pretraining CNN (i.e. ResNet50).
def load_prediction_model():
    if resNet50_model is None:
        raise ValueError("Error in loading ResNet50 model.")
    return resNet50_model

# pre-processing image through different formatting.
def preprocess_image_resNet(image):
    # validating image processing.
    try:
        # validating image resizing.
        if image is None or image.shape != (244, 244, 3):
            raise ValueError("Invalid ResNet50 Image Dimensions.")

        # image resizing, normalzing and expanding.
        img_resized = tf.image.resize(image, (224, 224))
        img_normalized = preprocess_input(img_resized)
        img_expanded = np.expand_dims(img_normalized, axis=0)
        
        return img_expanded
    
    except ValueError as e:
        print(f"ResNet50 ValueError: {e}")
        logging.error(f"ResNet50 ValueError: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"ResNet50 Error in Image Processing: {e}")
        logging.error(f"ResNet50 Error: {e}")
        raise ValueError("ResNet50 Error in Image Processing.")


# load feature extraction model globally.
try:
    # validating the model.
    try:
        efficientNetB0_model = efn.EfficientNetB0(weights='imagenet', include_top=False, pooling='avg')
        print("Pretrained EfficientNetB0 Model loaded successfully for feature extraction!")
        
    except ValueError as e:
        print(f"EfficientNetB0 ValueError: {e}")
        logging.error(f"EfficientNetB0 ValueError: {e}")
        jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"EfficientNetB0 Error in loading model: {e}")
        logging.error(f"EfficientNetB0 Error: {e}")
        efficientNetB0_model = None
        
except ValueError as e:
    print(f"EfficientNetB0 ValueError: {e}")
    logging.error(f"EfficientNetB0 ValueError: {e}")
    jsonify({"error": str(e)}), 500
except Exception as e:
    print(f"Unknown EfficientNetB0 Error: {e}")
    logging.error(f"EfficientNetB0 Error: {e}")
    raise ValueError("Unknown EfficientNetB0 Error occured.")

# function for pretraining CNN (i.e. EfficientNetB0).
def load_feature_extraction_model():
    if efficientNetB0_model is None:
        raise ValueError("Error in loading EfficientNetB0 model.")
    return efficientNetB0_model

# pre-processing image through different formatting.
def preprocess_image_efficientNetB0(image):
    # validating image processing.
    try:
        # validating image resizing.
        if image is None or image.shape != (244, 244, 3):
            raise ValueError("Invalid EfficientNetB0 Image Dimensions.")

        # image resizing, normalzing and expanding.
        img_resized = tf.image.resize(image, (224, 224))
        img_normalized = preprocess_input(img_resized)
        img_expanded = np.expand_dims(img_normalized, axis=0)
        
        return img_expanded
    
    except ValueError as e:
        print(f"EfficientNetB0 ValueError: {e}")
        logging.error(f"EfficientNetB0 ValueError: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"EfficientNetB0 Error in Image Processing: {e}")
        logging.error(f"EfficientNetB0 Error: {e}")
        raise ValueError("EfficientNetB0 Error in Image Processing.")

def extract_features_efficientNetB0(image, model):
    try:
        # processing the image before extracting the features.
        processed_input = preprocess_image_efficientNetB0(image)
        if processed_input is None:
            return None
        features = model.predict(processed_input)
        return features.flatten()
        
    except ValueError as e:
        print(f"EfficientNetB0 ValueError: {e}")
        logging.error(f"EfficientNetB0 ValueError: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"EfficientNetB0 Error in Image Processing: {e}")
        logging.error(f"EfficientNetB0 Error: {e}")
        raise ValueError("EfficientNetB0 Error in Image Processing.")




# function to predicting the accessory whether image matches.
def predict_accessory(image, model, confidence_threshold=0.5):
    # validating predictions.
    try:
        # predicting image.
        predicted_model = preprocess_image_resNet(image)
        predictions = model.predict(predicted_model)      
        predicted_class = np.argmax(predictions, axis=-1) # if model outputs a class probability.
        confidence = np.max(predictions) # create score of confidence.
        
        # binary classification with 1s or 0s for match or not match respectively.
        if confidence >= confidence_threshold:
            return predicted_class, 1, confidence # Match
        else:
            return predicted_class, 0, confidence # No Match
    
    except ValueError as e:
        print(f"ValueError: {e}")
        logging.error(f"ValueError: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"Error in Predicting Accessory Image: {e}")
        logging.error(f"Error: {e}")
        raise ValueError("Error in Predicting Accessory Image.")


# function to predicting the outfit whether image matches.
def predict_outfit(image, model):
    # validating predictions.
    try:       
        return predict_accessory(image, model)
    
    except ValueError as e:
        print(f"ValueError: {e}")
        logging.error(f"ValueError: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"Error in Predicting Outfit Image: {e}")
        logging.error(f"Error: {e}")
        raise ValueError("Error in Predicting Outfit Image.")
    

def extract_main_colors(image, k = 5):
    # validating color extractions.
    try:
        # read the image.
        img_col = c.imread(image)
        if img_col is None:
            return None
        # accept the image with colors.
        img_col = c.cvtColor(image, c.COLOR_BGR2RGB)
        # reshape image into 2D array of pixels.
        pixels = img_col.reshape(-1, 3)
        # KMeans clustering for the dominant colors.
        kmeans = KMeans(n_clusters=k, random_state=0, n_init="auto")
        kmeans.fit(pixels)
        # compiling all the data of the pixels.
        extract_dominant_colors = kmeans.cluster_centers_.astype(int).tolist()
        
        return extract_dominant_colors

    except ValueError as e:
        print(f"ValueError: {e}")
        logging.error(f"ValueError: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"Error in Matching Outfits with Accessories: {e}")
        logging.error(f"Error: {e}")
        raise ValueError("Error in Matching Outfits with Accessories.")


def matching_colors_between_outfits_and_accessories(accessory_colors, outfit_colors, threshold=5):
    # validating the matching.
    try:
        for accessory_color in accessory_colors:
            for outfit_color in outfit_colors:
                # calcuating the euclidean distance between colors.
                distance = np.linalg.norm(accessory_color - outfit_color)
                if distance < threshold:
                    return True
                        
        return False
    
    except ValueError as e:
        print(f"ValueError: {e}")
        logging.error(f"ValueError: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"Error in Matching Outfits with Accessories: {e}")
        logging.error(f"Error: {e}")
        raise ValueError("Error in Matching Outfits with Accessories.")


def calculate_delta_e(rgb1, rgb2):
    # validating the calucation with delta e.
    try:
        # checkign any colors.
        color_1_rgb = sRGBColor(rgb1[0]/255.0, rgb1[1]/255.0, rgb1[2]/255.0)
        color_2_rgb = sRGBColor(rgb2[0]/255.0, rgb2[1]/255.0, rgb2[2]/255.0)
        
        # converting colors.
        color_1_lab = convert_color(color_1_rgb, LabColor)
        color_2_lab = convert_color(color_2_rgb, LabColor)
        
        delta_e_calculate = delta_e_ciede2000(color_1_lab, color_2_lab)
        return delta_e_calculate
        
    except ValueError as e:
        print(f"Delta E ValueError: {e}")
        logging.error(f"Delta E ValueError: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"Error in Calculating Delta E: {e}")
        logging.error(f"Delta E Error: {e}")
        raise ValueError("Error in Calculating Delta E.")


