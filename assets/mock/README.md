# Mock API responses

Every file mirrors the FastAPI contract (`/api/v1`). Used when the app runs
with `--dart-define=USE_MOCK=true` (the default) and by `tools/mock_server`.

| File | Endpoint |
|---|---|
| `health.json` | `GET /health` |
| `questionnaire.json` | `GET /questionnaire` (also the offline fallback) |
| `analyze_success.json` | `POST /analyze` → 200 |
| `analyze_quality_fail.json` | `POST /analyze` → 422 (`--dart-define=MOCK_SCENARIO=quality_fail`) |
| `recommendations.json` | `GET /recommendations` (mock filters by `category` / `max_price` itself) |
| `product_detail.json` | `GET /products/{id}` reference example (`prd_004`, has `warnings`) |
| `products/<id>.json` | `GET /products/{id}` for every product in `recommendations.json` |

`prd_004` (retinal) carries a conflict warning.

Optional additions the app understands (backward compatible):

- `scale.labels` in the questionnaire: a label for every answer value.
- Each `reasons` / `warnings` entry may be written as `"Judul: isi"`; the app
  shows the part before the first `": "` as a bold title.

Products and brands are fictional (taken from the Tahap 2 design).
