"""
Visualization module for cryptocurrency price prediction results.

This module provides various visualization functions for data analysis
and model performance evaluation.
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
from typing import Dict, List, Optional, Tuple
import logging

logger = logging.getLogger(__name__)

# Set style for matplotlib
plt.style.use('seaborn-v0_8')
sns.set_palette("husl")


class CryptoVisualizer:
    """Visualization tools for cryptocurrency data and predictions."""
    
    def __init__(self, figsize: Tuple[int, int] = (12, 8)):
        """
        Initialize the visualizer.
        
        Args:
            figsize (Tuple[int, int]): Default figure size for matplotlib plots
        """
        self.figsize = figsize
    
    def plot_price_history(self, df: pd.DataFrame, title: str = "Cryptocurrency Price History") -> None:
        """
        Plot historical price data.
        
        Args:
            df (pd.DataFrame): DataFrame with price data
            title (str): Plot title
        """
        fig, axes = plt.subplots(2, 1, figsize=self.figsize, sharex=True)
        
        # Price plot
        if 'Close' in df.columns:
            axes[0].plot(df.index, df['Close'], label='Close Price', linewidth=2)
        elif 'price' in df.columns:
            axes[0].plot(df.index, df['price'], label='Price', linewidth=2)
        
        axes[0].set_title(title)
        axes[0].set_ylabel('Price (USD)')
        axes[0].legend()
        axes[0].grid(True, alpha=0.3)
        
        # Volume plot
        if 'Volume' in df.columns:
            axes[1].bar(df.index, df['Volume'], alpha=0.7, label='Volume')
            axes[1].set_ylabel('Volume')
            axes[1].legend()
            axes[1].grid(True, alpha=0.3)
        elif 'volume' in df.columns:
            axes[1].bar(df.index, df['volume'], alpha=0.7, label='Volume')
            axes[1].set_ylabel('Volume')
            axes[1].legend()
            axes[1].grid(True, alpha=0.3)
        
        plt.xlabel('Date')
        plt.tight_layout()
        plt.show()
    
    def plot_technical_indicators(self, df: pd.DataFrame) -> None:
        """
        Plot technical indicators.
        
        Args:
            df (pd.DataFrame): DataFrame with technical indicators
        """
        fig, axes = plt.subplots(3, 1, figsize=(15, 12), sharex=True)
        
        # Price and Moving Averages
        if 'Close' in df.columns:
            axes[0].plot(df.index, df['Close'], label='Close Price', linewidth=2)
        
        if 'SMA_7' in df.columns:
            axes[0].plot(df.index, df['SMA_7'], label='SMA 7', alpha=0.7)
        if 'SMA_25' in df.columns:
            axes[0].plot(df.index, df['SMA_25'], label='SMA 25', alpha=0.7)
        if 'EMA_12' in df.columns:
            axes[0].plot(df.index, df['EMA_12'], label='EMA 12', alpha=0.7)
        
        # Bollinger Bands
        if all(col in df.columns for col in ['BB_upper', 'BB_lower', 'BB_middle']):
            axes[0].fill_between(df.index, df['BB_lower'], df['BB_upper'], alpha=0.2, label='Bollinger Bands')
            axes[0].plot(df.index, df['BB_middle'], label='BB Middle', linestyle='--', alpha=0.7)
        
        axes[0].set_title('Price and Moving Averages')
        axes[0].set_ylabel('Price (USD)')
        axes[0].legend()
        axes[0].grid(True, alpha=0.3)
        
        # RSI
        if 'RSI' in df.columns:
            axes[1].plot(df.index, df['RSI'], label='RSI', color='orange')
            axes[1].axhline(y=70, color='r', linestyle='--', alpha=0.7, label='Overbought (70)')
            axes[1].axhline(y=30, color='g', linestyle='--', alpha=0.7, label='Oversold (30)')
            axes[1].set_title('Relative Strength Index (RSI)')
            axes[1].set_ylabel('RSI')
            axes[1].set_ylim(0, 100)
            axes[1].legend()
            axes[1].grid(True, alpha=0.3)
        
        # MACD
        if 'MACD' in df.columns:
            axes[2].plot(df.index, df['MACD'], label='MACD', color='blue')
            axes[2].axhline(y=0, color='black', linestyle='-', alpha=0.3)
            axes[2].set_title('MACD')
            axes[2].set_ylabel('MACD')
            axes[2].legend()
            axes[2].grid(True, alpha=0.3)
        
        plt.xlabel('Date')
        plt.tight_layout()
        plt.show()
    
    def plot_model_comparison(self, results: Dict[str, Dict[str, float]]) -> None:
        """
        Plot model comparison results.
        
        Args:
            results (Dict): Model evaluation results
        """
        metrics_df = pd.DataFrame(results).T
        
        fig, axes = plt.subplots(2, 2, figsize=(15, 10))
        
        # R² Score
        metrics_df['r2'].plot(kind='bar', ax=axes[0, 0], color='skyblue')
        axes[0, 0].set_title('R² Score Comparison')
        axes[0, 0].set_ylabel('R² Score')
        axes[0, 0].tick_params(axis='x', rotation=45)
        
        # RMSE
        metrics_df['rmse'].plot(kind='bar', ax=axes[0, 1], color='lightcoral')
        axes[0, 1].set_title('RMSE Comparison')
        axes[0, 1].set_ylabel('RMSE')
        axes[0, 1].tick_params(axis='x', rotation=45)
        
        # MAE
        metrics_df['mae'].plot(kind='bar', ax=axes[1, 0], color='lightgreen')
        axes[1, 0].set_title('MAE Comparison')
        axes[1, 0].set_ylabel('MAE')
        axes[1, 0].tick_params(axis='x', rotation=45)
        
        # MSE
        metrics_df['mse'].plot(kind='bar', ax=axes[1, 1], color='gold')
        axes[1, 1].set_title('MSE Comparison')
        axes[1, 1].set_ylabel('MSE')
        axes[1, 1].tick_params(axis='x', rotation=45)
        
        plt.tight_layout()
        plt.show()
    
    def plot_predictions(self, y_true: np.ndarray, y_pred: np.ndarray, 
                        dates: Optional[pd.DatetimeIndex] = None,
                        title: str = "Actual vs Predicted Prices") -> None:
        """
        Plot actual vs predicted values.
        
        Args:
            y_true (np.ndarray): Actual values
            y_pred (np.ndarray): Predicted values
            dates (Optional[pd.DatetimeIndex]): Date index for x-axis
            title (str): Plot title
        """
        fig, axes = plt.subplots(2, 1, figsize=self.figsize)
        
        x_axis = dates if dates is not None else range(len(y_true))
        
        # Time series plot
        axes[0].plot(x_axis, y_true, label='Actual', linewidth=2, alpha=0.8)
        axes[0].plot(x_axis, y_pred, label='Predicted', linewidth=2, alpha=0.8)
        axes[0].set_title(title)
        axes[0].set_ylabel('Price (USD)')
        axes[0].legend()
        axes[0].grid(True, alpha=0.3)
        
        # Scatter plot
        axes[1].scatter(y_true, y_pred, alpha=0.6)
        axes[1].plot([y_true.min(), y_true.max()], [y_true.min(), y_true.max()], 'r--', lw=2)
        axes[1].set_xlabel('Actual Values')
        axes[1].set_ylabel('Predicted Values')
        axes[1].set_title('Actual vs Predicted Scatter Plot')
        axes[1].grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.show()
    
    def plot_feature_importance(self, feature_names: List[str], importance_scores: np.ndarray,
                               top_n: int = 15, title: str = "Feature Importance") -> None:
        """
        Plot feature importance.
        
        Args:
            feature_names (List[str]): List of feature names
            importance_scores (np.ndarray): Importance scores
            top_n (int): Number of top features to show
            title (str): Plot title
        """
        # Create DataFrame and sort by importance
        importance_df = pd.DataFrame({
            'feature': feature_names,
            'importance': importance_scores
        }).sort_values('importance', ascending=True).tail(top_n)
        
        plt.figure(figsize=self.figsize)
        plt.barh(importance_df['feature'], importance_df['importance'])
        plt.xlabel('Importance Score')
        plt.title(title)
        plt.tight_layout()
        plt.show()
    
    def create_interactive_price_chart(self, df: pd.DataFrame, 
                                     title: str = "Interactive Cryptocurrency Price Chart") -> go.Figure:
        """
        Create interactive price chart using Plotly.
        
        Args:
            df (pd.DataFrame): DataFrame with price data
            title (str): Chart title
        
        Returns:
            go.Figure: Plotly figure object
        """
        fig = make_subplots(
            rows=2, cols=1,
            shared_xaxes=True,
            vertical_spacing=0.03,
            subplot_titles=('Price', 'Volume'),
            row_width=[0.2, 0.7]
        )
        
        # Candlestick chart if OHLC data available
        if all(col in df.columns for col in ['Open', 'High', 'Low', 'Close']):
            fig.add_trace(
                go.Candlestick(
                    x=df.index,
                    open=df['Open'],
                    high=df['High'],
                    low=df['Low'],
                    close=df['Close'],
                    name="Price"
                ),
                row=1, col=1
            )
        else:
            # Line chart for price
            price_col = 'Close' if 'Close' in df.columns else 'price'
            if price_col in df.columns:
                fig.add_trace(
                    go.Scatter(
                        x=df.index,
                        y=df[price_col],
                        mode='lines',
                        name='Price',
                        line=dict(width=2)
                    ),
                    row=1, col=1
                )
        
        # Volume bar chart
        volume_col = 'Volume' if 'Volume' in df.columns else 'volume'
        if volume_col in df.columns:
            fig.add_trace(
                go.Bar(
                    x=df.index,
                    y=df[volume_col],
                    name='Volume',
                    marker_color='rgba(158,202,225,0.6)'
                ),
                row=2, col=1
            )
        
        fig.update_layout(
            title=title,
            yaxis_title='Price (USD)',
            xaxis_rangeslider_visible=False,
            height=600
        )
        
        return fig
    
    def plot_correlation_matrix(self, df: pd.DataFrame, 
                               title: str = "Feature Correlation Matrix") -> None:
        """
        Plot correlation matrix of features.
        
        Args:
            df (pd.DataFrame): DataFrame with features
            title (str): Plot title
        """
        # Select only numeric columns
        numeric_df = df.select_dtypes(include=[np.number])
        
        # Calculate correlation matrix
        corr_matrix = numeric_df.corr()
        
        plt.figure(figsize=(12, 10))
        sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', center=0,
                   square=True, fmt='.2f', cbar_kws={"shrink": .8})
        plt.title(title)
        plt.tight_layout()
        plt.show()


if __name__ == "__main__":
    # Example usage
    from data_collector import CryptoDataCollector
    from data_preprocessor import CryptoDataPreprocessor
    
    # Collect and preprocess data
    collector = CryptoDataCollector()
    data = collector.get_crypto_data_yahoo("BTC-USD", "6mo")
    
    preprocessor = CryptoDataPreprocessor()
    processed_data = preprocessor.prepare_features(data)
    
    # Create visualizations
    visualizer = CryptoVisualizer()
    
    # Plot price history
    visualizer.plot_price_history(data, "Bitcoin Price History")
    
    # Plot technical indicators
    visualizer.plot_technical_indicators(processed_data)
    
    # Plot correlation matrix
    visualizer.plot_correlation_matrix(processed_data)
