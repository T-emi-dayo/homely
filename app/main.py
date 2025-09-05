from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import numpy as np

# Load trained Lagos housing model
print("Loading model...")
model = joblib.load("models/housing_model.pkl")
print("✅ Model loaded successfully.")

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
    "Bungalow", "Block of Flats", "Penthouse", "Other"  # ✅ Fixed
]

def one_hot_encode(value: str, categories: list[str]):
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
        # Log input
        print("\n🔎 Incoming Request:")
        print(features)

        # Encode town
        town_encoded = TOWN_MAP.get(features.town, 9)
        print(f"📍 Encoded town '{features.town}' -> {town_encoded}")

        # One-hot encode title
        title_encoded = one_hot_encode(features.title, TITLE_CATEGORIES)
        print(f"🏷️ Title one-hot: {title_encoded}")

        # Final feature vector
        data = np.array([
            features.bedrooms,
            features.bathrooms,
            features.toilets,
            features.parking_space,
            town_encoded,
            *title_encoded
        ]).reshape(1, -1)

        print(f"🧮 Final feature vector shape: {data.shape}")
        print(f"🧮 Vector: {data}")

        # Model prediction
        log_pred = model.predict(data)[0]
        print(f"📊 Raw model prediction (log price): {log_pred}")

        # Convert back to original scale
        prediction = np.exp(log_pred)
        print(f"💰 Final predicted price: {prediction}")

        return {"predicted_price": round(float(prediction), 2)}ing 

    except Exception as e:
        print(f"❌ ERROR during prediction: {e}")
        return {"error": str(e)}
