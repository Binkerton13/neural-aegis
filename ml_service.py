#!/usr/bin/env python3
"""
ML Service for Neural Aegis
Provides real machine learning capabilities using scikit-learn
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
from sklearn.ensemble import IsolationForest
from sklearn.linear_model import LinearRegression
import logging

app = Flask(__name__)
CORS(app)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "service": "neural-aegis-ml"})

@app.route('/isolation_forest', methods=['POST'])
def isolation_forest():
    """
    Perform outlier detection using Isolation Forest
    
    Expected input:
    {
        "data": [[value1], [value2], ...],  # Feature values for each entity
        "contamination": 0.1  # Expected proportion of outliers (optional)
    }
    
    Returns:
    {
        "outliers": [index1, index2, ...],  # Indices of outlier samples
        "scores": [score1, score2, ...],  # Anomaly scores (more negative = more anomalous)
        "predictions": [1, -1, 1, ...]  # 1 for inliers, -1 for outliers
    }
    """
    try:
        data = request.json
        X = np.array(data.get('data', []))
        contamination = data.get('contamination', 0.1)
        
        if len(X) == 0:
            return jsonify({"error": "No data provided"}), 400
        
        # Reshape if needed (sklearn expects 2D array)
        if len(X.shape) == 1:
            X = X.reshape(-1, 1)
        
        # Train Isolation Forest
        clf = IsolationForest(contamination=contamination, random_state=42)
        predictions = clf.fit_predict(X)
        
        # Get anomaly scores (more negative = more anomalous)
        scores = clf.score_samples(X)
        
        # Find outlier indices
        outliers = np.where(predictions == -1)[0].tolist()
        
        return jsonify({
            "outliers": outliers,
            "scores": scores.tolist(),
            "predictions": predictions.tolist(),
            "model_params": {
                "contamination": contamination,
                "n_estimators": clf.n_estimators
            }
        })
    
    except Exception as e:
        logger.error(f"Error in isolation_forest: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/linear_regression', methods=['POST'])
def linear_regression():
    """
    Perform time-series forecasting using Linear Regression
    
    Expected input:
    {
        "data": [value1, value2, ...],  # Historical values
        "forecast_steps": 5  # Number of future steps to predict
    }
    
    Returns:
    {
        "predictions": [pred1, pred2, ...],  # Forecasted values
        "trend": "increasing" | "decreasing" | "stable",
        "slope": float,
        "r_squared": float  # Model quality metric
    }
    """
    try:
        data = request.json
        y = np.array(data.get('data', []))
        forecast_steps = data.get('forecast_steps', 5)
        
        if len(y) == 0:
            return jsonify({"error": "No data provided"}), 400
        
        # Create time indices
        X = np.arange(len(y)).reshape(-1, 1)
        y = y.reshape(-1, 1)
        
        # Train Linear Regression
        model = LinearRegression()
        model.fit(X, y)
        
        # Calculate R-squared
        r_squared = model.score(X, y)
        
        # Make predictions for future time steps
        future_X = np.arange(len(y), len(y) + forecast_steps).reshape(-1, 1)
        predictions = model.predict(future_X)
        
        # Determine trend
        slope = model.coef_[0][0]
        if abs(slope) < 0.1:
            trend = "stable"
        elif slope > 0:
            trend = "increasing"
        else:
            trend = "decreasing"
        
        return jsonify({
            "predictions": predictions.flatten().tolist(),
            "trend": trend,
            "slope": float(slope),
            "intercept": float(model.intercept_[0]),
            "r_squared": float(r_squared)
        })
    
    except Exception as e:
        logger.error(f"Error in linear_regression: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/anomaly_detection', methods=['POST'])
def anomaly_detection():
    """
    Detect anomalies using statistical methods (3-sigma rule)
    
    Expected input:
    {
        "data": [value1, value2, ...],
        "threshold": 3.0  # Number of standard deviations (optional)
    }
    
    Returns:
    {
        "anomalies": [index1, index2, ...],
        "z_scores": [score1, score2, ...],
        "mean": float,
        "std": float
    }
    """
    try:
        data = request.json
        values = np.array(data.get('data', []))
        threshold = data.get('threshold', 3.0)
        
        if len(values) == 0:
            return jsonify({"error": "No data provided"}), 400
        
        # Calculate statistics
        mean = np.mean(values)
        std = np.std(values)
        
        if std == 0:
            return jsonify({
                "anomalies": [],
                "z_scores": [0.0] * len(values),
                "mean": float(mean),
                "std": 0.0
            })
        
        # Calculate z-scores
        z_scores = np.abs((values - mean) / std)
        
        # Find anomalies
        anomalies = np.where(z_scores > threshold)[0].tolist()
        
        return jsonify({
            "anomalies": anomalies,
            "z_scores": z_scores.tolist(),
            "mean": float(mean),
            "std": float(std),
            "threshold": float(threshold)
        })
    
    except Exception as e:
        logger.error(f"Error in anomaly_detection: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    logger.info("Starting Neural Aegis ML Service on port 5000")
    app.run(host='0.0.0.0', port=5000, debug=False)
