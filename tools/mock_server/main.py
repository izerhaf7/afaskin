"""Mock Afa Skin backend that follows the app's API contract (/api/v1).

Serves the same JSON files the app uses in mock mode (assets/mock/), over
real HTTP, so the app can be tested on a phone with USE_MOCK=false before
the ML backend is ready. It does NOT run any model.

    pip install -r requirements.txt
    uvicorn main:app --host 0.0.0.0 --port 8000

Send `?scenario=quality_fail` as a query parameter on /analyze, or set
MOCK_SCENARIO=quality_fail, to get the 422 quality-gate response.
"""

import json
import os
from pathlib import Path

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.responses import JSONResponse

MOCK_DIR = Path(__file__).resolve().parents[2] / "assets" / "mock"

app = FastAPI(title="Afa Skin mock API", version="mock")


def _load(name: str):
    return json.loads((MOCK_DIR / name).read_text(encoding="utf-8"))


@app.get("/api/v1/health")
def health():
    return _load("health.json")


@app.get("/api/v1/questionnaire")
def questionnaire():
    return _load("questionnaire.json")


@app.post("/api/v1/analyze")
async def analyze(
    image: UploadFile = File(...),
    payload: str = Form(...),
    scenario: str | None = None,
):
    data = await image.read()
    if not data.startswith(b"\xff\xd8"):
        raise HTTPException(status_code=400, detail="image must be a JPEG")
    try:
        body = json.loads(payload)
        body["profile"], body["questionnaire"]
    except (ValueError, KeyError) as e:
        raise HTTPException(status_code=400, detail=f"bad payload: {e}")

    if (scenario or os.environ.get("MOCK_SCENARIO")) == "quality_fail":
        return JSONResponse(status_code=422, content=_load("analyze_quality_fail.json"))
    return _load("analyze_success.json")


@app.get("/api/v1/recommendations")
def recommendations(
    analysis_id: str,
    category: str | None = None,
    max_price: int | None = None,
):
    items = _load("recommendations.json")["items"]
    if category:
        items = [p for p in items if p["category"] == category]
    if max_price is not None:
        items = [p for p in items if p["price"] <= max_price]
    return {"items": items}


@app.get("/api/v1/products/{product_id}")
def product(product_id: str):
    path = MOCK_DIR / "products" / f"{Path(product_id).name}.json"
    if not path.is_file():
        raise HTTPException(status_code=404, detail="product not found")
    return json.loads(path.read_text(encoding="utf-8"))
