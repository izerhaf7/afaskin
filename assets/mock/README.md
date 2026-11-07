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

`POST /analyze` also accepts two optional multipart files, `image_side_1` and
`image_side_2`: the head turned about 30° to each side, in either order. The
real backend (`PJBL/app/backend`) scans the cheek that faces the camera in
those photos and ignores a side photo that fails its quality gate. It
reports what it used in an extra `views` field, which the app ignores. The
mock ignores both side files.

Optional additions the app understands (backward compatible):

- `scale.labels` in the questionnaire: a label for every answer value.
- Each `reasons` / `warnings` entry may be written as `"Judul: isi"`; the app
  shows the part before the first `": "` as a bold title.

Products and brands are fictional (taken from the Tahap 2 design).
