# LanguageVision Backend

FastAPI backend for image analysis using Google Gemini API.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Set your Gemini API key:
```bash
export GEMINI_API_KEY=AIzaSyBC0Zo_elX2Lj4V1NPLCF6djn0UWDZtpWw
```

3. Run the server:
```bash
python main.py
```

## API Endpoints

- `GET /` - Health check
- `POST /analyze-image` - Upload image for analysis
- `GET /health` - Detailed health status

## Testing

Test with curl:
```bash
curl -X POST "http://localhost:8000/analyze-image" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@your-image.jpg"
```
