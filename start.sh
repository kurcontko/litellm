#!/bin/bash

# LiteLLM Proxy Server Startup Script
# This script creates a Python virtual environment, installs dependencies, and starts the proxy server

set -e  # Exit on any error

echo "🚀 Starting LiteLLM Proxy Server Setup..."

# Check if Python 3.12+ is available
PYTHON_CMD=""
for cmd in python3.12 python3.13 python3.14 python3; do
    if command -v "$cmd" &> /dev/null; then
        version=$($cmd --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        major=$(echo $version | cut -d. -f1)
        minor=$(echo $version | cut -d. -f2)
        
        if [ "$major" -eq 3 ] && [ "$minor" -ge 12 ]; then
            PYTHON_CMD="$cmd"
            echo "✅ Found Python $version at $(which $cmd)"
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "❌ Error: Python 3.12 or higher is required but not found."
    echo "Please install Python 3.12+ and try again."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "🔧 Creating Python virtual environment with $PYTHON_CMD..."
    $PYTHON_CMD -m venv .venv
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source .venv/bin/activate

# Upgrade pip
echo "🔧 Upgrading pip..."
python -m pip install --upgrade pip

# Install dependencies
echo "🔧 Installing LiteLLM with proxy dependencies..."
pip install -e ".[proxy]"

# Check if config.yaml exists
if [ ! -f "config.yaml" ]; then
    echo "⚠️  Warning: config.yaml not found. Creating a basic configuration..."
    cat > config.yaml << EOF
model_list:
  - model_name: gpt-3.5-turbo
    litellm_params:
      model: gpt-3.5-turbo
      api_key: "your-openai-api-key"

general_settings:
  master_key: "your-master-key"
  
litellm_settings:
  drop_params: true
  set_verbose: false
EOF
    echo "📝 Basic config.yaml created. Please update it with your API keys and model configurations."
fi

# Start the proxy server
echo "🚀 Starting LiteLLM Proxy Server..."
echo "📍 Config file: config.yaml"
echo "🌐 Server will be available at: http://localhost:4000"
echo ""
echo "Press Ctrl+C to stop the server"
echo "----------------------------------------"

python litellm/proxy/proxy_cli.py --config config.yaml