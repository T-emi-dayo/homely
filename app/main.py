from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import numpy as np

# Load trained Lagos housing model
model = joblib.load("models/housing_model.pkl")

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
    "Ikoyi": 0,
    "Lekki": 1,
    "Victoria Island": 2,
    "Yaba": 3,
    "Surulere": 4,
    "Ikeja": 5,
    "Ajah": 6,
    "Maryland": 7,
    "Ogudu": 8,
    "Other": 9
}

TITLE_CATEGORIES = [
    "Detached Duplex", "Semi-Detached Duplex", "Terraced Duplex",
    "Bungalow", "Block of Flats", "Penthouse", "Other"
]

def one_hot_encode(value: str, categories: list[str]):
    encoding = [0] * len(categories)
    try:
        idx = categories.index(value)
    except ValueError:
        idx = categories.index("Other")  # default bucket
    encoding[idx] = 1
    return encoding

@app.post("/predict")
def predict(features: HouseFeatures):
    # Encode town
    town_encoded = TOWN_MAP.get(features.town, 9)

    # One-hot encode title
    title_encoded = one_hot_encode(features.title, TITLE_CATEGORIES)

    # Final feature vector
    data = np.array([
        features.bedrooms,
        features.bathrooms,
        features.toilets,
        features.parking_space,
        town_encoded,
        *title_encoded
    ]).reshape(1, -1)

    # Model prediction (log price)
    log_pred = model.predict(data)[0]

    # Convert back to original scale
    prediction = np.exp(log_pred)

    return {"predicted_price": round(float(prediction), 2)}
