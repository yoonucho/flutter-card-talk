# 🚀 Cryptocurrency Price Prediction System

A comprehensive machine learning system for predicting cryptocurrency prices using technical indicators and multiple ML models.

## 📋 Features

- **Data Collection**: Fetches real-time cryptocurrency data from Yahoo Finance and CoinGecko APIs
- **Technical Analysis**: Generates 15+ technical indicators (RSI, MACD, Bollinger Bands, Moving Averages, etc.)
- **Multiple ML Models**: Trains and compares 7 different machine learning models
- **Interactive Visualizations**: Creates beautiful charts and analysis plots
- **Model Comparison**: Automatically selects the best performing model
- **Modular Design**: Clean, extensible code structure

## 🛠️ Installation

### Prerequisites

- Python 3.8 or higher
- pip package manager

### Quick Setup

1. Clone or download this project to your local machine

2. Install required packages:

```bash
pip install -r requirements.txt
```

## 🚀 Quick Start

### Basic Usage

```bash
python main.py
```

This will predict Bitcoin (BTC-USD) prices using 1 year of historical data.

### Custom Cryptocurrency

```bash
python main.py --symbol ETH-USD --period 6mo
```

### Skip Visualizations (for faster execution)

```bash
python main.py --no-viz
```

### Command Line Options

- `--symbol` or `-s`: Cryptocurrency symbol (default: BTC-USD)
- `--period` or `-p`: Time period (1mo, 3mo, 6mo, 1y, 2y)
- `--no-viz`: Skip creating visualizations
- `--no-save`: Skip saving results to files
- `--output-dir` or `-o`: Output directory for results

## 📊 Supported Cryptocurrencies

The system supports any cryptocurrency available on Yahoo Finance or CoinGecko:

**Popular symbols:**

- BTC-USD (Bitcoin)
- ETH-USD (Ethereum)
- ADA-USD (Cardano)
- DOT-USD (Polkadot)
- LINK-USD (Chainlink)
- XRP-USD (Ripple)

## 🤖 Machine Learning Models

The system trains and compares the following models:

1. **Linear Regression** - Simple baseline model
2. **Ridge Regression** - Regularized linear model
3. **Lasso Regression** - Feature selection via L1 regularization
4. **Random Forest** - Ensemble of decision trees
5. **Gradient Boosting** - Sequential boosting algorithm
6. **Support Vector Regression (SVR)** - Kernel-based regression
7. **Neural Network (MLP)** - Multi-layer perceptron

## 📈 Technical Indicators

The system automatically generates these technical indicators:

**Trend Indicators:**

- Simple Moving Averages (SMA 7, 25)
- Exponential Moving Averages (EMA 12, 26)
- MACD (Moving Average Convergence Divergence)

**Momentum Indicators:**

- RSI (Relative Strength Index)
- Stochastic Oscillator (K%, D%)

**Volatility Indicators:**

- Bollinger Bands (Upper, Lower, Middle)

**Volume Indicators:**

- Volume SMA
- On-Balance Volume (OBV)

**Price-based Features:**

- Lag features (1, 2, 3, 5, 10 days)
- Price returns and volatility

## 📁 Project Structure

```
crypto-prediction/
├── main.py                 # Main execution script
├── data_collector.py       # Data collection from APIs
├── data_preprocessor.py    # Data cleaning and feature engineering
├── model_trainer.py        # ML model training and evaluation
├── visualizer.py          # Data visualization functions
├── requirements.txt       # Python dependencies
├── README.md             # This file
├── .github/
│   └── copilot-instructions.md  # AI coding guidelines
└── output/               # Generated results (created automatically)
    ├── models/          # Saved trained models
    ├── data/           # Processed datasets
    └── results/        # Performance metrics
```

## 📊 Output Files

The system generates several output files:

1. **Model Files**: Best performing model saved as `.joblib` file
2. **Processed Data**: Feature-engineered dataset as `.csv`
3. **Results Summary**: Model performance metrics as `.csv`
4. **Log File**: Detailed execution log (`crypto_prediction.log`)

## 📈 Visualizations

The system creates several types of visualizations:

1. **Price History Charts**: Historical price and volume data
2. **Technical Indicator Plots**: RSI, MACD, Bollinger Bands, Moving Averages
3. **Model Comparison Charts**: Performance metrics comparison
4. **Prediction Plots**: Actual vs predicted values
5. **Feature Importance**: Most important features for prediction
6. **Correlation Heatmap**: Feature correlation analysis

## ⚙️ Configuration

### Custom Time Periods

- `1mo`: 1 month of data
- `3mo`: 3 months of data
- `6mo`: 6 months of data
- `1y`: 1 year of data (default)
- `2y`: 2 years of data

### Model Parameters

You can customize model parameters by editing the `initialize_models()` method in `model_trainer.py`.

## 🔍 Model Evaluation Metrics

The system evaluates models using:

- **R² Score**: Coefficient of determination (higher is better)
- **RMSE**: Root Mean Square Error (lower is better)
- **MAE**: Mean Absolute Error (lower is better)
- **MSE**: Mean Square Error (lower is better)

## 🚨 Important Notes

### Data Quality

- The system automatically handles missing values and outliers
- Minimum recommended data period: 3 months for reliable predictions
- More data generally leads to better model performance

### Market Volatility

- Cryptocurrency markets are highly volatile and unpredictable
- Past performance does not guarantee future results
- Use predictions as one factor among many in investment decisions

### API Limitations

- Yahoo Finance: Free tier with reasonable rate limits
- CoinGecko: Free tier with some rate limitations
- Consider API rate limits for frequent usage

## 🔧 Troubleshooting

### Common Issues

1. **Import Errors**: Make sure all packages are installed via `pip install -r requirements.txt`

2. **Data Collection Fails**:

   - Check internet connection
   - Verify cryptocurrency symbol is correct
   - Try a different time period

3. **Memory Issues**:

   - Reduce the time period
   - Use `--no-viz` flag to skip visualizations

4. **Slow Performance**:
   - Use shorter time periods
   - Skip neural network model by commenting it out in `model_trainer.py`

## 📚 Educational Purpose

This project is designed for educational and research purposes. It demonstrates:

- Financial data analysis techniques
- Machine learning model comparison
- Technical indicator implementation
- Time series prediction methods
- Data visualization best practices

## 🤝 Contributing

Contributions are welcome! Areas for improvement:

- Additional technical indicators
- More sophisticated ML models (LSTM, Transformer)
- Real-time prediction capabilities
- Portfolio optimization features
- Risk management tools

## ⚠️ Disclaimer

This software is for educational and research purposes only. It is not intended as financial advice. Cryptocurrency investments carry significant risk, and you should consult with financial professionals before making investment decisions.

## 📄 License

This project is open source and available under the MIT License.

---

**Happy Trading! 📈🚀**
