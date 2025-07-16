"""
Cryptocurrency Price Prediction System

This module provides functionality to collect cryptocurrency data,
preprocess it, train machine learning models, and make predictions.
"""

import pandas as pd
import numpy as np
import yfinance as yf
import requests
from typing import Dict, List, Optional, Tuple
import logging
from datetime import datetime, timedelta

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class CryptoDataCollector:
    """Collects cryptocurrency data from various sources."""
    
    def __init__(self):
        self.base_url = "https://api.coingecko.com/api/v3"
    
    def get_crypto_data_yahoo(self, symbol: str, period: str = "1y") -> pd.DataFrame:
        """
        Fetch cryptocurrency data from Yahoo Finance.
        
        Args:
            symbol (str): Cryptocurrency symbol (e.g., 'BTC-USD', 'ETH-USD')
            period (str): Time period ('1d', '5d', '1mo', '3mo', '6mo', '1y', '2y', '5y', '10y', 'ytd', 'max')
        
        Returns:
            pd.DataFrame: Historical price data
        """
        try:
            ticker = yf.Ticker(symbol)
            data = ticker.history(period=period)
            logger.info(f"Successfully fetched {len(data)} records for {symbol}")
            return data
        except Exception as e:
            logger.error(f"Error fetching data for {symbol}: {e}")
            return pd.DataFrame()
    
    def get_crypto_data_coingecko(self, coin_id: str, days: int = 365) -> pd.DataFrame:
        """
        Fetch cryptocurrency data from CoinGecko API.
        
        Args:
            coin_id (str): CoinGecko coin ID (e.g., 'bitcoin', 'ethereum')
            days (int): Number of days of historical data
        
        Returns:
            pd.DataFrame: Historical price data
        """
        try:
            url = f"{self.base_url}/coins/{coin_id}/market_chart"
            params = {
                'vs_currency': 'usd',
                'days': days,
                'interval': 'daily'
            }
            
            response = requests.get(url, params=params)
            response.raise_for_status()
            
            data = response.json()
            
            # Convert to DataFrame
            prices = data['prices']
            volumes = data['total_volumes']
            market_caps = data['market_caps']
            
            df = pd.DataFrame({
                'timestamp': [price[0] for price in prices],
                'price': [price[1] for price in prices],
                'volume': [volume[1] for volume in volumes],
                'market_cap': [cap[1] for cap in market_caps]
            })
            
            df['timestamp'] = pd.to_datetime(df['timestamp'], unit='ms')
            df.set_index('timestamp', inplace=True)
            
            logger.info(f"Successfully fetched {len(df)} records for {coin_id}")
            return df
            
        except Exception as e:
            logger.error(f"Error fetching data for {coin_id}: {e}")
            return pd.DataFrame()


if __name__ == "__main__":
    # Example usage
    collector = CryptoDataCollector()
    
    # Fetch Bitcoin data from Yahoo Finance
    btc_data = collector.get_crypto_data_yahoo("BTC-USD", "6mo")
    print("Bitcoin data from Yahoo Finance:")
    print(btc_data.head())
    
    # Fetch Bitcoin data from CoinGecko
    btc_data_cg = collector.get_crypto_data_coingecko("bitcoin", 180)
    print("\nBitcoin data from CoinGecko:")
    print(btc_data_cg.head())
