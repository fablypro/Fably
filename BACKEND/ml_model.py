import os
import cv2 as c
import numpy as np
from dotenv import load_dotenv # type: ignore
import tensorflow as tf # type: ignore
from tensorflow.keras.models import load_model as keras_load_model # type: ignore

# adding AI learning component.
from tensorflow.keras.applications import ResNet50 # type: ignore

from tensorflow.keras.preprocessing import image # type: ignore
from tensorflow.keras.applications.resnet50 import preprocess_input # type: ignore

from sklearn.cluster import KMeans # type: ignore


# loading environment variables from .env file.
load_dotenv()


# function for pretraining CNN (i.e. ResNet50).
def load_model_via_pretrained_CNN():
    try:
        model = ResNet50(weights='imagenet')
        print("Pretrained ResNet50 Model loaded successfully!")
        return model
   
    except Exception as e:
        print(f"Error in loading model: {e}")
        raise
    

# pre-processing image through different formatting.
def preprocess_image(image):
    # validating image processing.
    try:
        # validating image resizing.
        if image is None or image.shape != (244, 244):
            raise ValueError("Invalid Image Dimensions.")

        # image resizing, normalzing and expanding.
        img_resized = tf.image.resize(image, (224, 224))
        img_normalized = preprocess_input(img_resized)
        img_expanded = np.expand_dims(img_normalized, axis=0)
        
        return img_expanded
    
    except Exception as e:
        print(f"Error in Image Processing: {e}")
        raise ValueError("Error in Image Processing.")


# function to predicting the accessory whether image matches.
def predict_accessory(image, model):
    # validating predictions.
    try:
        # predicting image.
        predicted_model = preprocess_image(image)
        predictions = model.predict(predicted_model)




    
    


