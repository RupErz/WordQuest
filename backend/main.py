from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
import google.generativeai as genai
import base64
import io
from PIL import Image
import uvicorn
import os
from typing import Dict, Any

app = FastAPI(title="LanguageVision Backend", version="1.0.0")

# Enable CORS for your Vision Pro app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure Gemini API
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyBC0Zo_elX2Lj4V1NPLCF6djn0UWDZtpWw")
genai.configure(api_key=GEMINI_API_KEY)

# Initialize Gemini model
model = genai.GenerativeModel('gemini-2.0-flash')

@app.get("/")
async def root():
    return {"message": "LanguageVision Backend is running!", "status": "healthy"}

@app.post("/analyze-image")
async def analyze_image(
    file: UploadFile = File(...),
    native_language: str = Form(...),
    target_language: str = Form(...)
):
    try:
        print(f"🔍 Received image: {file.filename}, size: {file.size}")
        print(f"🌍 Native Language: {native_language}")
        print(f"🎯 Target Language: {target_language}")
        
        # Read image data
        image_data = await file.read()
        print(f"📊 Image data size: {len(image_data)} bytes")
        
        # Convert to PIL Image
        image = Image.open(io.BytesIO(image_data))
        print(f"🖼️ Image dimensions: {image.size}")
        
        # Create personalized prompt for fill-in-the-blank
        prompt = f"""
Create 1 fill-in-the-blank question for language learning.

USER PREFERENCES:
- Native Language: {native_language}
- Target Language: {target_language}

TASK:
Look at this image and create a simple sentence in {native_language} that describes something visible in the image, with ONE blank for a key object/action.

The blank should be filled with a word in {target_language}.

REQUIREMENTS:
- Sentence should be in {native_language}
- One blank (_____) for a visible object/action
- Answer should be a single word in {target_language}
- Make it appropriate for language learning
- Keep it simple and clear

FORMAT YOUR RESPONSE EXACTLY LIKE THIS:
Question: [sentence with _____ in {native_language}]
Answer: [single word in {target_language}]
Translation: [full sentence in {native_language} with the NATIVE LANGUAGE equivalent of the target word]
Type: [noun/verb/adjective]

Be brief and focused on one clear object/action from the image.
"""
        
        # Analyze with Gemini
        print("🚀 Starting personalized language learning analysis...")
        response = model.generate_content([prompt, image])
        
        print("✅ Personalized analysis complete!")
        print("=" * 80)
        print("🎓 LANGUAGE LEARNING QUESTION:")
        print("=" * 80)
        print(response.text)
        print("=" * 80)
        print(f"📊 Response length: {len(response.text)} characters")
        print("=" * 80)
        
        # Parse the structured response
        lines = response.text.strip().split('\n')
        parsed_data = {}
        
        for line in lines:
            if line.startswith('Question:'):
                parsed_data['question'] = line.replace('Question:', '').strip()
            elif line.startswith('Answer:'):
                parsed_data['answer'] = line.replace('Answer:', '').strip()
            elif line.startswith('Translation:'):
                parsed_data['translation'] = line.replace('Translation:', '').strip()
            elif line.startswith('Type:'):
                parsed_data['type'] = line.replace('Type:', '').strip()
        
        # Return structured response for language learning
        return {
            "question": parsed_data.get('question', ''),
            "answer": parsed_data.get('answer', ''),
            "translation": parsed_data.get('translation', ''),
            "type": parsed_data.get('type', 'noun'),
            "native_language": native_language,
            "target_language": target_language
        }
        
    except Exception as e:
        print(f"❌ Error analyzing image: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Image analysis failed: {str(e)}")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "gemini_configured": bool(GEMINI_API_KEY)}

if __name__ == "__main__":
    print("🚀 Starting LanguageVision Backend...")
    print(f"🔑 Gemini API Key: {GEMINI_API_KEY[:8]}...")
    uvicorn.run(app, host="0.0.0.0", port=8000)
