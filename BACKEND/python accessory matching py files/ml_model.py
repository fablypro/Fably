from flask import jsonify # type: ignore
import logging
import cv2 as c
import numpy as np
from dotenv import load_dotenv # type: ignore
import tensorflow as tf # type: ignore

# adding AI learning component.
from tensorflow.keras.applications import ResNet50 # type: ignore

from tensorflow.keras.applications.resnet50 import preprocess_input # type: ignore

from sklearn.cluster import KMeans # type: ignore


# loading environment variables from .env file.
load_dotenv()


# laod model globally.
try:
    # validating the model.
    try:
        model = ResNet50(weights='imagenet')
        print("Pretrained ResNet50 Model loaded successfully!")
        
    except ValueError as e:
            print(f"ValueError: {e}")
            logging.error(f"ValueError: {e}")
            jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"Error in loading model: {e}")
        logging.error(f"Error: {e}")
        model = None
        
except ValueError as e:
            print(f"ValueError: {e}")
            logging.error(f"ValueError: {e}")
            jsonify({"error": str(e)}), 500
except Exception as e:
        print(f"Unknown Error: {e}")
        logging.error(f"Error: {e}")
        raise ValueError("Unknown Error occured.")


# function for pretraining CNN (i.e. ResNet50).
def load_model_via_pretrained_CNN():
    if model is None:
        raise ValueError("Error in loading model.")
    return model


# pre-processing image through different formatting.
def preprocess_image(image):
    # validating image processing.
    try:
        # validating image resizing.
        if image is None or image.shape != (244, 244, 3):
            raise ValueError("Invalid Image Dimensions.")

        # image resizing, normalzing and expanding.
        img_resized = tf.image.resize(image, (224, 224))
        img_normalized = preprocess_input(img_resized)
        img_expanded = np.expand_dims(img_normalized, axis=0)
        
        return img_expanded
    
    except ValueError as e:
            print(f"ValueError: {e}")
            logging.error(f"ValueError: {e}")
            return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"Error in Image Processing: {e}")
        logging.error(f"Error: {e}")
        raise ValueError("Error in Image Processing.")


# function to predicting the accessory whether image matches.
def predict_accessory(image, model, confidence_threshold=0.5):
    # validating predictions.
    try:
        # predicting image.
        predicted_model = preprocess_image(image)
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
    

def extract_main_colors(image, k = 3):
    # validating color extractions.
    try:
        # accept the image with colors.
        img_col = c.cvtColor(image, c.COLOR_BGR2RGB)
        # reshape image into 2D array of pixels.
        pixels = img_col.reshape(-1, 3)
        # KMeans clustering for the dominant colors.
        kMeans = KMeans(n_clusters=k, random_state=0, n_init="auto")
        kMeans.fit(pixels)
        # compiling all the data of the pixels.
        extract_dominant_colors = kMeans.cluster_centers_
        
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
    # validating them matching.
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





