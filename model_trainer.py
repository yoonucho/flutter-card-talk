"""
Machine learning models for cryptocurrency price prediction.

This module implements various ML models for predicting cryptocurrency prices.
"""

import numpy as np
import pandas as pd
from typing import Dict, Any, Tuple, Optional
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.linear_model import LinearRegression, Ridge, Lasso
from sklearn.svm import SVR
from sklearn.neural_network import MLPRegressor
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import joblib
import logging

logger = logging.getLogger(__name__)


class CryptoPricePredictor:
    """Machine learning models for cryptocurrency price prediction."""
    
    def __init__(self):
        self.models = {}
        self.best_model = None
        self.best_model_name = None
        self.best_score = float('-inf')
        
    def initialize_models(self) -> Dict[str, Any]:
        """
        Initialize different ML models for comparison.
        
        Returns:
            Dict: Dictionary of initialized models
        """
        models = {
            'Linear_Regression': LinearRegression(),
            'Ridge_Regression': Ridge(alpha=1.0),
            'Lasso_Regression': Lasso(alpha=1.0),
            'Random_Forest': RandomForestRegressor(
                n_estimators=100,
                max_depth=10,
                random_state=42,
                n_jobs=-1
            ),
            'Gradient_Boosting': GradientBoostingRegressor(
                n_estimators=100,
                learning_rate=0.1,
                max_depth=6,
                random_state=42
            ),
            'SVR': SVR(
                kernel='rbf',
                C=1.0,
                gamma='scale'
            ),
            'Neural_Network': MLPRegressor(
                hidden_layer_sizes=(100, 50),
                activation='relu',
                solver='adam',
                max_iter=500,
                random_state=42
            )
        }
        
        self.models = models
        return models
    
    def train_model(self, model_name: str, X_train: np.ndarray, y_train: np.ndarray) -> Any:
        """
        Train a specific model.
        
        Args:
            model_name (str): Name of the model to train
            X_train (np.ndarray): Training features
            y_train (np.ndarray): Training targets
        
        Returns:
            Trained model
        """
        if model_name not in self.models:
            raise ValueError(f"Model {model_name} not found. Available models: {list(self.models.keys())}")
        
        model = self.models[model_name]
        logger.info(f"Training {model_name}...")
        
        try:
            model.fit(X_train, y_train)
            logger.info(f"{model_name} training completed successfully")
            return model
        except Exception as e:
            logger.error(f"Error training {model_name}: {e}")
            return None
    
    def evaluate_model(self, model: Any, X_test: np.ndarray, y_test: np.ndarray) -> Dict[str, float]:
        """
        Evaluate a trained model.
        
        Args:
            model: Trained model
            X_test (np.ndarray): Test features
            y_test (np.ndarray): Test targets
        
        Returns:
            Dict: Evaluation metrics
        """
        try:
            y_pred = model.predict(X_test)
            
            metrics = {
                'mse': mean_squared_error(y_test, y_pred),
                'rmse': np.sqrt(mean_squared_error(y_test, y_pred)),
                'mae': mean_absolute_error(y_test, y_pred),
                'r2': r2_score(y_test, y_pred)
            }
            
            return metrics
        except Exception as e:
            logger.error(f"Error evaluating model: {e}")
            return {}
    
    def train_and_evaluate_all(self, X_train: np.ndarray, X_test: np.ndarray, 
                              y_train: np.ndarray, y_test: np.ndarray) -> Dict[str, Dict[str, float]]:
        """
        Train and evaluate all models.
        
        Args:
            X_train (np.ndarray): Training features
            X_test (np.ndarray): Test features
            y_train (np.ndarray): Training targets
            y_test (np.ndarray): Test targets
        
        Returns:
            Dict: Results for all models
        """
        if not self.models:
            self.initialize_models()
        
        results = {}
        
        for model_name in self.models.keys():
            logger.info(f"Training and evaluating {model_name}...")
            
            # Train model
            trained_model = self.train_model(model_name, X_train, y_train)
            
            if trained_model is not None:
                # Evaluate model
                metrics = self.evaluate_model(trained_model, X_test, y_test)
                results[model_name] = metrics
                
                # Update models dictionary with trained model
                self.models[model_name] = trained_model
                
                # Track best model
                if metrics.get('r2', float('-inf')) > self.best_score:
                    self.best_score = metrics['r2']
                    self.best_model = trained_model
                    self.best_model_name = model_name
                
                logger.info(f"{model_name} - R2: {metrics.get('r2', 0):.4f}, RMSE: {metrics.get('rmse', 0):.4f}")
        
        logger.info(f"Best model: {self.best_model_name} with R2 score: {self.best_score:.4f}")
        return results
    
    def predict(self, model_name: str, X: np.ndarray) -> np.ndarray:
        """
        Make predictions with a specific model.
        
        Args:
            model_name (str): Name of the model to use
            X (np.ndarray): Input features
        
        Returns:
            np.ndarray: Predictions
        """
        if model_name not in self.models:
            raise ValueError(f"Model {model_name} not found")
        
        model = self.models[model_name]
        return model.predict(X)
    
    def predict_best(self, X: np.ndarray) -> np.ndarray:
        """
        Make predictions with the best performing model.
        
        Args:
            X (np.ndarray): Input features
        
        Returns:
            np.ndarray: Predictions
        """
        if self.best_model is None:
            raise ValueError("No model has been trained yet")
        
        return self.best_model.predict(X)
    
    def save_model(self, model_name: str, filepath: str) -> None:
        """
        Save a trained model to disk.
        
        Args:
            model_name (str): Name of the model to save
            filepath (str): File path to save the model
        """
        if model_name not in self.models:
            raise ValueError(f"Model {model_name} not found")
        
        try:
            joblib.dump(self.models[model_name], filepath)
            logger.info(f"Model {model_name} saved to {filepath}")
        except Exception as e:
            logger.error(f"Error saving model {model_name}: {e}")
    
    def load_model(self, model_name: str, filepath: str) -> None:
        """
        Load a trained model from disk.
        
        Args:
            model_name (str): Name to assign to the loaded model
            filepath (str): File path to load the model from
        """
        try:
            model = joblib.load(filepath)
            self.models[model_name] = model
            logger.info(f"Model loaded as {model_name} from {filepath}")
        except Exception as e:
            logger.error(f"Error loading model from {filepath}: {e}")
    
    def get_feature_importance(self, model_name: str) -> Optional[np.ndarray]:
        """
        Get feature importance for tree-based models.
        
        Args:
            model_name (str): Name of the model
        
        Returns:
            Optional[np.ndarray]: Feature importance scores
        """
        if model_name not in self.models:
            return None
        
        model = self.models[model_name]
        
        if hasattr(model, 'feature_importances_'):
            return model.feature_importances_
        else:
            logger.warning(f"Model {model_name} does not have feature importance")
            return None


class ModelComparison:
    """Compare and analyze different model performances."""
    
    @staticmethod
    def compare_models(results: Dict[str, Dict[str, float]]) -> pd.DataFrame:
        """
        Create a comparison DataFrame of model results.
        
        Args:
            results (Dict): Results from multiple models
        
        Returns:
            pd.DataFrame: Comparison table
        """
        comparison_df = pd.DataFrame(results).T
        comparison_df = comparison_df.sort_values('r2', ascending=False)
        return comparison_df
    
    @staticmethod
    def print_model_comparison(results: Dict[str, Dict[str, float]]) -> None:
        """
        Print a formatted comparison of model results.
        
        Args:
            results (Dict): Results from multiple models
        """
        print("\n" + "="*60)
        print("MODEL PERFORMANCE COMPARISON")
        print("="*60)
        
        comparison_df = ModelComparison.compare_models(results)
        
        for model_name, metrics in comparison_df.iterrows():
            print(f"\n{model_name}:")
            print(f"  R² Score: {metrics['r2']:.4f}")
            print(f"  RMSE:     {metrics['rmse']:.4f}")
            print(f"  MAE:      {metrics['mae']:.4f}")
            print(f"  MSE:      {metrics['mse']:.4f}")
        
        print("\n" + "="*60)
        print(f"BEST MODEL: {comparison_df.index[0]} (R² = {comparison_df.iloc[0]['r2']:.4f})")
        print("="*60)


if __name__ == "__main__":
    # Example usage
    from data_collector import CryptoDataCollector
    from data_preprocessor import CryptoDataPreprocessor
    
    # Collect and preprocess data
    collector = CryptoDataCollector()
    data = collector.get_crypto_data_yahoo("BTC-USD", "1y")
    
    preprocessor = CryptoDataPreprocessor()
    processed_data = preprocessor.prepare_features(data)
    X_train, X_test, y_train, y_test = preprocessor.split_and_scale_data(processed_data, 'Close')
    
    # Train and evaluate models
    predictor = CryptoPricePredictor()
    predictor.initialize_models()
    results = predictor.train_and_evaluate_all(X_train, X_test, y_train, y_test)
    
    # Compare models
    ModelComparison.print_model_comparison(results)
