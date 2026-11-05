# Mock API responses

Every file mirrors the FastAPI contract (`/api/v1`) exactly. Used when the app
runs with `--dart-define=USE_MOCK=true` (the default).

| File | Endpoint |
|---|---|
| `health.json` | `GET /health` |
| `questionnaire.json` | `GET /questionnaire` (also the offline fallback) |
| `analyze_success.json` | `POST /analyze` → 200 |
| `analyze_quality_fail.json` | `POST /analyze` → 422 (`--dart-define=MOCK_SCENARIO=quality_fail`) |
| `recommendations.json` | `GET /recommendations` (mock filters by `category` / `max_price` itself) |
| `product_detail.json` | `GET /products/{id}` reference example (`prd_003`, has `warnings`) |
| `products/<id>.json` | `GET /products/{id}` for every product in `recommendations.json` |

`prd_003` (retinol + AHA) and `prd_007` (vitamin C vs benzoyl peroxide) carry
conflict `warnings`.
