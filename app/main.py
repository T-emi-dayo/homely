from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import numpy as np
import logging
from typing import List

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load trained Lagos housing model
logger.info("Loading model...")
model = joblib.load("models/housing_model.pkl")
logger.info("✅ Model loaded successfully.")

# Input schema
class HouseFeatures(BaseModel):
    bedrooms: int
    bathrooms: int
    toilets: int
    parking_space: int
    town: str
    title: str

app = FastAPI(title="Lagos Housing Price Prediction API")

# Encoding dictionaries
TOWN_MAP = {
    "Ikoyi": 0, "Lekki": 1, "Victoria Island": 2, "Yaba": 3,
    "Surulere": 4, "Ikeja": 5, "Ajah": 6, "Maryland": 7,
    "Ogudu": 8, "Other": 9
}

TITLE_CATEGORIES = [
    "Detached Duplex", "Semi-Detached Duplex", "Terraced Duplex",
    "Bungalow", "Block of Flats", "Penthouse", "Other"
]

def one_hot_encode(value: str, categories: List[str]):
    encoding = [0] * len(categories)
    try:
        idx = categories.index(value)
    except ValueError:
        idx = categories.index("Other")
    encoding[idx] = 1
    return encoding

@app.post("/predict")
def predict(features: HouseFeatures):
    try:
        logger.info(f"🔎 Incoming Request: {features.dict()}")

        # Encode town
        town_encoded = TOWN_MAP.get(features.town, 9)
        logger.info(f"📍 Encoded town '{features.town}' -> {town_encoded}")

        # One-hot encode title
        title_encoded = one_hot_encode(features.title, TITLE_CATEGORIES)
        logger.info(f"🏷️ Title one-hot: {title_encoded}")

        # Build final feature vector
        data = np.array([
            features.bedrooms,
            features.bathrooms,
            features.toilets,
            features.parking_space,
            town_encoded,
            *title_encoded
        ]).reshape(1, -1)

        logger.info(f"🧮 Final feature vector shape: {data.shape}")

        # Make prediction
        log_pred = model.predict(data)[0]
        logger.info(f"📊 Log prediction: {log_pred}")

        prediction = np.exp(log_pred)
        logger.info(f"💰 Final predicted price: {prediction}")

        return {"predicted_price": round(float(prediction), 2)}

    except Exception as e:
        logger.error(f"❌ ERROR during prediction: {e}")
        return {"error": "An error occurred while processing your request."}