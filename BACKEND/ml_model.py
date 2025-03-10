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






