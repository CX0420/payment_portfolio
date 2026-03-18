#!/bin/bash

# Run scripts for different environments

echo "Select environment to run:"
echo "1) Development"
echo "2) SIT"
echo "3) Production"
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo "Running Development environment..."
        flutter run --flavor dev -t lib/main_dev.dart
        ;;
    2)
        echo "Running SIT environment..."
        flutter run --flavor sit -t lib/main_sit.dart
        ;;
    3)
        echo "Running Production environment..."
        flutter run
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac