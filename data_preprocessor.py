"""
Data preprocessing module for cryptocurrency price prediction.

This module provides functionality to clean, transform, and prepare
cryptocurrency data for machine learning models.
"""

import pandas as pd
import numpy as np
from typing import Tuple, List, Optional
import ta
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.model_selection import train_test_split
import logging

logger = logging.getLogger(__name__)


class CryptoDataPreprocessor:
    """Preprocesses cryptocurrency data for machine learning."""
    
    def __init__(self, scaler_type: str = "standard"):
        """
        Initialize the preprocessor.
        
        Args:
            scaler_type (str): Type of scaler to use ('standard' or 'minmax')
        """
        self.scaler_type = scaler_type
        self.scaler = StandardScaler() if scaler_type == "standard" else MinMaxScaler()
        self.feature_columns = []
    
    def clean_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Clean the raw cryptocurrency data.
        
        Args:
            df (pd.DataFrame): Raw cryptocurrency data
        
        Returns:
            pd.DataFrame: Cleaned data
        """
        # Remove duplicates
        df = df.drop_duplicates()
        
        # Handle missing values
        df = df.dropna()
        
        # Remove outliers using IQR method
        for column in df.select_dtypes(include=[np.number]).columns:
            Q1 = df[column].quantile(0.25)
            Q3 = df[column].quantile(0.75)
            IQR = Q3 - Q1
            lower_bound = Q1 - 1.5 * IQR
            upper_bound = Q3 + 1.5 * IQR
            df = df[(df[column] >= lower_bound) & (df[column] <= upper_bound)]
        
        logger.info(f"Data cleaned. Shape: {df.shape}")
        return df
    
    def add_technical_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Add technical indicators to the dataset.
        
        Args:
            df (pd.DataFrame): Cryptocurrency data with OHLCV columns
        
        Returns:
            pd.DataFrame: Data with technical indicators
        """
        # Ensure we have the required columns
        required_columns = ['Open', 'High', 'Low', 'Close', 'Volume']
        if not all(col in df.columns for col in required_columns):
            # Try to map common column names
            column_mapping = {
                'price': 'Close',
                'volume': 'Volume'
            }
            df = df.rename(columns=column_mapping)
            
            # If we still don't have OHLC data, create synthetic data
            if 'Close' in df.columns and 'Open' not in df.columns:
                df['Open'] = df['Close'].shift(1)
                df['High'] = df[['Open', 'Close']].max(axis=1) * 1.01
                df['Low'] = df[['Open', 'Close']].min(axis=1) * 0.99
                df = df.dropna()
        
        try:
            # Moving averages
            df['SMA_7'] = ta.trend.sma_indicator(df['Close'], window=7)
            df['SMA_25'] = ta.trend.sma_indicator(df['Close'], window=25)
            df['EMA_12'] = ta.trend.ema_indicator(df['Close'], window=12)
            df['EMA_26'] = ta.trend.ema_indicator(df['Close'], window=26)
            
            # MACD
            df['MACD'] = ta.trend.macd_diff(df['Close'])
            
            # RSI
            df['RSI'] = ta.momentum.rsi(df['Close'], window=14)
            
            # Bollinger Bands
            df['BB_upper'] = ta.volatility.bollinger_hband(df['Close'])
            df['BB_lower'] = ta.volatility.bollinger_lband(df['Close'])
            df['BB_middle'] = ta.volatility.bollinger_mavg(df['Close'])
            
            # Stochastic Oscillator
            df['Stoch_K'] = ta.momentum.stoch(df['High'], df['Low'], df['Close'])
            df['Stoch_D'] = ta.momentum.stoch_signal(df['High'], df['Low'], df['Close'])
            
            # Volume indicators
            if 'Volume' in df.columns:
                df['Volume_SMA'] = ta.volume.volume_sma(df['Close'], df['Volume'])
                df['OBV'] = ta.volume.on_balance_volume(df['Close'], df['Volume'])
            
            logger.info("Technical indicators added successfully")
            
        except Exception as e:
            logger.warning(f"Error adding some technical indicators: {e}")
        
        return df
    
    def create_lag_features(self, df: pd.DataFrame, target_col: str = 'Close', lags: List[int] = [1, 2, 3, 5, 10]) -> pd.DataFrame:
        """
        Create lag features for time series prediction.
        
        Args:
            df (pd.DataFrame): Input data
            target_col (str): Target column name
            lags (List[int]): List of lag periods
        
        Returns:
            pd.DataFrame: Data with lag features
        """
        for lag in lags:
            df[f'{target_col}_lag_{lag}'] = df[target_col].shift(lag)
        
        return df
    
    def create_target_variable(self, df: pd.DataFrame, target_col: str = 'Close', prediction_days: int = 1) -> pd.DataFrame:
        """
        Create target variable for prediction.
        
        Args:
            df (pd.DataFrame): Input data
            target_col (str): Column to predict
            prediction_days (int): Number of days ahead to predict
        
        Returns:
            pd.DataFrame: Data with target variable
        """
        df[f'{target_col}_future_{prediction_days}d'] = df[target_col].shift(-prediction_days)
        return df
    
    def prepare_features(self, df: pd.DataFrame, target_col: str = 'Close') -> pd.DataFrame:
        """
        Prepare all features for machine learning.
        
        Args:
            df (pd.DataFrame): Raw data
            target_col (str): Target column name
        
        Returns:
            pd.DataFrame: Processed data ready for ML
        """
        # Clean data
        df = self.clean_data(df)
        
        # Add technical indicators
        df = self.add_technical_indicators(df)
        
        # Create lag features
        df = self.create_lag_features(df, target_col)
        
        # Create target variable
        df = self.create_target_variable(df, target_col)
        
        # Drop rows with NaN values
        df = df.dropna()
        
        logger.info(f"Feature preparation complete. Final shape: {df.shape}")
        return df
    
    def split_and_scale_data(self, df: pd.DataFrame, target_col: str, test_size: float = 0.2, random_state: int = 42) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
        """
        Split and scale the data for machine learning.
        
        Args:
            df (pd.DataFrame): Processed data
            target_col (str): Target column name
            test_size (float): Proportion of data for testing
            random_state (int): Random state for reproducibility
        
        Returns:
            Tuple: X_train, X_test, y_train, y_test (scaled)
        """
        # Identify target and feature columns
        target_future_col = f'{target_col}_future_1d'
        feature_cols = [col for col in df.columns if col != target_future_col and col != target_col]
        
        X = df[feature_cols]
        y = df[target_future_col]
        
        # Split the data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=random_state, shuffle=False
        )
        
        # Scale the features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        self.feature_columns = feature_cols
        
        logger.info(f"Data split and scaled. Training set: {X_train_scaled.shape}, Test set: {X_test_scaled.shape}")
        
        return X_train_scaled, X_test_scaled, y_train.values, y_test.values


if __name__ == "__main__":
    # Example usage
    from data_collector import CryptoDataCollector
    
    # Collect data
    collector = CryptoDataCollector()
    data = collector.get_crypto_data_yahoo("BTC-USD", "6mo")
    
    # Preprocess data
    preprocessor = CryptoDataPreprocessor()
    processed_data = preprocessor.prepare_features(data)
    
    print("Processed data shape:", processed_data.shape)
    print("Processed data columns:", processed_data.columns.tolist())
    
    # Split and scale data
    X_train, X_test, y_train, y_test = preprocessor.split_and_scale_data(processed_data, 'Close')
    print(f"Training features shape: {X_train.shape}")
    print(f"Test features shape: {X_test.shape}")
