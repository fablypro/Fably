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
    
    
    
    


