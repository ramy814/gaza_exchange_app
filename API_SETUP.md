# API Configuration Guide

## API URL
The app is configured to use only:

    http://localhost:8000/api

Make sure your API server is running on your local machine on port 8000.

## Troubleshooting

- If you get connection errors, ensure your API server is running and accessible at http://localhost:8000/api
- Try accessing http://localhost:8000/api in your browser to verify
- If you need to use a different port or host, update the URL in:
  - lib/core/utils/api_config.dart
  - lib/core/utils/constants.dart

## No Environment Switching
All environment and alternative URL logic has been removed. The app will always use http://localhost:8000/api. 