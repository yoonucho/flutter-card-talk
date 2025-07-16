"""
Main execution file for cryptocurrency price prediction system.

This script orchestrates the entire prediction pipeline from data collection
to model training and visualization.
"""

import argparse
import logging
from datetime import datetime
from pathlib import Path

from data_collector import CryptoDataCollector
from data_preprocessor import CryptoDataPreprocessor
from model_trainer import CryptoPricePredictor, ModelComparison
from visualizer import CryptoVisualizer

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('crypto_prediction.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)


class CryptoPredictionPipeline:
    """Complete pipeline for cryptocurrency price prediction."""
    
    def __init__(self, crypto_symbol: str = "BTC-USD", period: str = "1y"):
        """
        Initialize the prediction pipeline.
        
        Args:
            crypto_symbol (str): Cryptocurrency symbol
            period (str): Time period for historical data
        """
        self.crypto_symbol = crypto_symbol
        self.period = period
        self.collector = CryptoDataCollector()
        self.preprocessor = CryptoDataPreprocessor()
        self.predictor = CryptoPricePredictor()
        self.visualizer = CryptoVisualizer()
        self.raw_data = None
        self.processed_data = None
        self.results = None
    
    def collect_data(self):
        """Collect cryptocurrency data."""
        logger.info(f"Collecting data for {self.crypto_symbol} for period {self.period}")
        
        # Try Yahoo Finance first
        self.raw_data = self.collector.get_crypto_data_yahoo(self.crypto_symbol, self.period)
        
        if self.raw_data.empty:
            logger.warning("Yahoo Finance data collection failed, trying CoinGecko...")
            # Try CoinGecko as fallback (convert symbol)
            coin_id = self.crypto_symbol.lower().replace('-usd', '').replace('btc', 'bitcoin').replace('eth', 'ethereum')
            days = {'1mo': 30, '3mo': 90, '6mo': 180, '1y': 365, '2y': 730}.get(self.period, 365)
            self.raw_data = self.collector.get_crypto_data_coingecko(coin_id, days)
        
        if self.raw_data.empty:
            raise ValueError(f"Failed to collect data for {self.crypto_symbol}")
        
        logger.info(f"Successfully collected {len(self.raw_data)} data points")
    
    def preprocess_data(self):
        """Preprocess the collected data."""
        if self.raw_data is None or self.raw_data.empty:
            raise ValueError("No data to preprocess. Run collect_data() first.")
        
        logger.info("Preprocessing data...")
        self.processed_data = self.preprocessor.prepare_features(self.raw_data)
        logger.info(f"Preprocessing complete. Features: {list(self.processed_data.columns)}")
    
    def train_models(self):
        """Train and evaluate all models."""
        if self.processed_data is None or self.processed_data.empty:
            raise ValueError("No processed data available. Run preprocess_data() first.")
        
        logger.info("Training models...")
        
        # Split and scale data
        target_col = 'Close' if 'Close' in self.processed_data.columns else 'price'
        X_train, X_test, y_train, y_test = self.preprocessor.split_and_scale_data(
            self.processed_data, target_col
        )
        
        # Train and evaluate all models
        self.predictor.initialize_models()
        self.results = self.predictor.train_and_evaluate_all(X_train, X_test, y_train, y_test)
        
        # Print comparison
        ModelComparison.print_model_comparison(self.results)
        
        return X_train, X_test, y_train, y_test
    
    def visualize_results(self, X_test=None, y_test=None):
        """Create visualizations of data and results."""
        logger.info("Creating visualizations...")
        
        # Plot raw data
        self.visualizer.plot_price_history(self.raw_data, f"{self.crypto_symbol} Price History")
        
        # Plot technical indicators
        if self.processed_data is not None:
            self.visualizer.plot_technical_indicators(self.processed_data)
            self.visualizer.plot_correlation_matrix(self.processed_data)
        
        # Plot model comparison
        if self.results is not None:
            self.visualizer.plot_model_comparison(self.results)
        
        # Plot predictions if test data available
        if X_test is not None and y_test is not None and self.predictor.best_model is not None:
            y_pred = self.predictor.predict_best(X_test)
            self.visualizer.plot_predictions(y_test, y_pred, title=f"{self.crypto_symbol} Predictions")
        
        # Feature importance for best model
        if self.predictor.best_model_name and self.preprocessor.feature_columns:
            importance = self.predictor.get_feature_importance(self.predictor.best_model_name)
            if importance is not None:
                self.visualizer.plot_feature_importance(
                    self.preprocessor.feature_columns, 
                    importance,
                    title=f"Feature Importance - {self.predictor.best_model_name}"
                )
    
    def save_results(self, output_dir: str = "output"):
        """Save models and results."""
        output_path = Path(output_dir)
        output_path.mkdir(exist_ok=True)
        
        # Save best model
        if self.predictor.best_model is not None:
            model_path = output_path / f"best_model_{self.crypto_symbol}_{datetime.now().strftime('%Y%m%d')}.joblib"
            self.predictor.save_model(self.predictor.best_model_name, str(model_path))
        
        # Save processed data
        if self.processed_data is not None:
            data_path = output_path / f"processed_data_{self.crypto_symbol}_{datetime.now().strftime('%Y%m%d')}.csv"
            self.processed_data.to_csv(data_path)
            logger.info(f"Processed data saved to {data_path}")
        
        # Save results
        if self.results is not None:
            results_path = output_path / f"model_results_{self.crypto_symbol}_{datetime.now().strftime('%Y%m%d')}.csv"
            import pandas as pd
            pd.DataFrame(self.results).T.to_csv(results_path)
            logger.info(f"Model results saved to {results_path}")
    
    def run_complete_pipeline(self, save_output: bool = True, create_visualizations: bool = True):
        """Run the complete prediction pipeline."""
        logger.info("Starting complete cryptocurrency prediction pipeline...")
        
        try:
            # Step 1: Collect data
            self.collect_data()
            
            # Step 2: Preprocess data
            self.preprocess_data()
            
            # Step 3: Train models
            X_train, X_test, y_train, y_test = self.train_models()
            
            # Step 4: Create visualizations
            if create_visualizations:
                self.visualize_results(X_test, y_test)
            
            # Step 5: Save results
            if save_output:
                self.save_results()
            
            logger.info("Pipeline completed successfully!")
            
            return {
                'best_model': self.predictor.best_model_name,
                'best_score': self.predictor.best_score,
                'results': self.results
            }
            
        except Exception as e:
            logger.error(f"Pipeline failed: {e}")
            raise


def main():
    """Main function with command line interface."""
    parser = argparse.ArgumentParser(description="Cryptocurrency Price Prediction System")
    parser.add_argument("--symbol", "-s", default="BTC-USD", 
                       help="Cryptocurrency symbol (default: BTC-USD)")
    parser.add_argument("--period", "-p", default="1y",
                       choices=["1mo", "3mo", "6mo", "1y", "2y"],
                       help="Time period for historical data (default: 1y)")
    parser.add_argument("--no-viz", action="store_true",
                       help="Skip visualization creation")
    parser.add_argument("--no-save", action="store_true",
                       help="Skip saving results")
    parser.add_argument("--output-dir", "-o", default="output",
                       help="Output directory for results (default: output)")
    
    args = parser.parse_args()
    
    # Create and run pipeline
    pipeline = CryptoPredictionPipeline(args.symbol, args.period)
    
    try:
        results = pipeline.run_complete_pipeline(
            save_output=not args.no_save,
            create_visualizations=not args.no_viz
        )
        
        print("\n" + "="*50)
        print("PIPELINE RESULTS SUMMARY")
        print("="*50)
        print(f"Cryptocurrency: {args.symbol}")
        print(f"Period: {args.period}")
        print(f"Best Model: {results['best_model']}")
        print(f"Best R² Score: {results['best_score']:.4f}")
        print("="*50)
        
    except Exception as e:
        print(f"Error running pipeline: {e}")
        return 1
    
    return 0


if __name__ == "__main__":
    exit(main())
