import streamlit as st
import requests

st.title("🏠 Lagos Housing Price Predictor")

st.write("Estimate Lagos house prices based on features, town, and property type.")

# User inputs
bedrooms = st.number_input("Bedrooms", 1, 10, 3)
bathrooms = st.number_input("Bathrooms", 1, 10, 2)
toilets = st.number_input("Toilets", 1, 10, 2)
parking_space = st.number_input("Parking Spaces", 0, 10, 1)

town = st.selectbox(
    "Select Town",
    ["Ikoyi", "Lekki", "Victoria Island", "Yaba", "Surulere",
     "Ikeja", "Ajah", "Maryland", "Ogudu", "Other"]
)

title = st.selectbox(
    "Select Property Title",
    ["Detached Duplex", "Semi-Detached Duplex", "Terraced Duplex",
     "Bungalow", "Block of Flats", "Penthouse", "Other"]
)

if st.button("Predict Price"):
    payload = {
        "bedrooms": bedrooms,
        "bathrooms": bathrooms,
        "toilets": toilets,
        "parking_space": parking_space,
        "town": town,
        "title": title
    }
    
    response = requests.post("http://127.0.0.1:8000/predict", json=payload)
    
    if response.status_code == 200:
        st.success(f"Estimated Price: ₦{response.json()['predicted_price']:,.2f}")
    else:
        st.error("Error in prediction")
