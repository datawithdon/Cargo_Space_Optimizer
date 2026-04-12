# Freight Optimizer

A web-based logistics tool that automates cargo analysis and optimizes freight routing from uploaded packing lists.

Upload an Excel packing list → get instant container recommendations, a 3D load plan, aircraft compliance checks, and downloadable reports.

---

## Features

### Data Ingestion
- Upload any `.xlsx` / `.xls` packing list — no fixed column format required
- Visual column-mapping UI: drag your columns to the correct system fields
- Supports **metric** (cm/kg) and **imperial** (in/lbs) units with automatic conversion
- One shipment per upload

### Pallet Configuration
- Automatically calculates pallet builds from carton dimensions
- US standard pallet (122 × 102 cm) with configurable max stacking height per shipment
- Respects per-item **stackable**, **non-stackable**, and **tiltable** flags

### Sea Freight Engine
- Recommends the optimal container type: **20ft GP**, **40ft GP**, **40ft HC**, **45ft HC**
- Calculates how many containers are required
- **LCL recommendation** when total volume is below 15 CBM
- **3D bin-packing algorithm** with:
  - Stackable pallets stacked vertically
  - Non-stackable pallets floor-only (nothing placed on top)
  - Tiltable pallets rotated on any axis (all 6 orientations) to maximise space
- Weight distribution analysis (front/rear balance) with imbalance warnings
- Interactive **3D load plan viewer** (orbit, zoom, hover for pallet details)

### Air Freight Engine
- IATA-standard aircraft database — **13 aircraft types** (CAO freighters + PAX belly)
- Per-piece dimensional compliance check across all aircraft
- **Volumetric (chargeable) weight** calculation: `L × W × H (cm) ÷ 6000`
- Recommends the smallest viable CAO freighter and PAX belly option
- Flags oversized cargo requiring **charter or special handling**

### Export
- **PDF report** — branded multi-section A4 document covering all analysis sections
- **Excel workbook** — 5 colour-coded sheets: Summary, Cargo Items, Pallet Config, Sea Freight, Air Freight

---

## Screenshots

| Step | View |
|---|---|
| Upload | Drag-and-drop Excel file |
| Map Columns | Match your headers to system fields |
| Pallet Config | Set max stack height per shipment |
| Sea Results | Container recommendation + interactive 3D load plan |
| Air Results | Aircraft compliance matrix + chargeable weight |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React 18 + TypeScript + Vite |
| UI Library | Ant Design 5 |
| 3D Viewer | Three.js via React Three Fiber + Drei |
| Backend | Python 3.11+ + FastAPI |
| Excel Parsing | pandas + openpyxl |
| PDF Export | ReportLab |
| Excel Export | XlsxWriter |
| Dev Runner | concurrently (single `npm start`) |

---

## Getting Started

### Prerequisites

- **Node.js** 18+ — [nodejs.org](https://nodejs.org)
- **Python** 3.11+ — [python.org](https://python.org)

### 1. Clone the repository

```bash
git clone https://github.com/datawithdon/Cargo_Space_Optimizer.git
   cd Cargo_Space_Optimizer
```

### 2. Install backend dependencies

```bash
cd backend
pip install -r requirements.txt
cd ..
```

### 3. Install frontend + runner dependencies

```bash
npm install
cd frontend && npm install && cd ..
```

### 4. Start the application

```bash
npm start
```

This starts both servers concurrently:

| Server | URL |
|---|---|
| Frontend (UI) | http://localhost:5173 |
| Backend (API) | http://localhost:8000 |
| API Docs (Swagger) | http://localhost:8000/docs |

Press `Ctrl+C` to stop both.

---

## Project Structure

```
freight-optimizer/
├── backend/
│   ├── app/
│   │   ├── main.py                  # FastAPI app entry point
│   │   ├── models/
│   │   │   └── cargo.py             # Pydantic data models
│   │   ├── routers/
│   │   │   ├── upload.py            # POST /api/upload, /api/analyze
│   │   │   ├── sea.py               # POST /api/sea/analyze
│   │   │   ├── air.py               # POST /api/air/analyze
│   │   │   └── export.py            # POST /api/export/pdf, /api/export/excel
│   │   └── services/
│   │       ├── excel_parser.py      # Excel ingestion
│   │       ├── unit_converter.py    # cm/kg ↔ in/lbs
│   │       ├── pallet_calculator.py # Pallet build algorithm
│   │       ├── sea_freight.py       # 3D bin-packing + container selection
│   │       ├── air_freight.py       # IATA compliance + aircraft recommendation
│   │       ├── pdf_export.py        # ReportLab PDF generator
│   │       └── excel_export.py      # XlsxWriter workbook generator
│   └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── api/                     # Axios API clients
│   │   ├── components/              # Reusable UI components
│   │   ├── pages/                   # Page-level views
│   │   └── types/                   # TypeScript interfaces
│   ├── package.json
│   └── vite.config.ts
├── sample_packing_list.xlsx         # Sample file for testing
├── package.json                     # Root runner (concurrently)
└── README.md
```

---

## API Reference

All endpoints are documented interactively at `http://localhost:8000/docs` when the server is running.

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/upload` | Upload Excel file, returns columns + preview |
| `POST` | `/api/analyze` | Apply column mapping, returns cargo items + pallet config |
| `POST` | `/api/sea/analyze` | Run sea freight analysis |
| `POST` | `/api/air/analyze` | Run air freight analysis |
| `POST` | `/api/export/pdf` | Generate PDF report |
| `POST` | `/api/export/excel` | Generate Excel workbook |
| `GET` | `/health` | Health check |

---

## Packing List Format

Any Excel file is accepted as long as it contains columns for dimensions, weight, and quantity. Use the column-mapper UI to match your headers.

A `sample_packing_list.xlsx` file is included in the repository with all supported columns:

| Column | Required | Notes |
|---|---|---|
| Length | Yes | Carton length |
| Width | Yes | Carton width |
| Height | Yes | Carton height |
| Gross Weight | Yes | Weight per carton/piece |
| Quantity | Yes | Number of cartons per line |
| Description | No | Item name or SKU |
| Stackable | No | e.g. `Y` / `N` |
| Tiltable | No | Non-stackable items that can be rotated sideways; e.g. `Y` / `N` |

Units can be metric (cm/kg) or imperial (in/lbs) — selectable in the UI.

---

## Container Specifications

| Container | Internal L | Internal W | Internal H | Max Payload |
|---|---|---|---|---|
| 20ft GP | 589 cm | 235 cm | 239 cm | 28,000 kg |
| 40ft GP | 1,203 cm | 235 cm | 239 cm | 28,750 kg |
| 40ft HC | 1,203 cm | 235 cm | 269 cm | 28,600 kg |
| 45ft HC | 1,356 cm | 235 cm | 269 cm | 27,600 kg |

LCL (Less than Container Load) is recommended when total cargo volume is below **15 CBM**.

---

## Aircraft Reference (IATA Standard)

| Aircraft | Category | Max Piece (L×W×H cm) | Max Payload |
|---|---|---|---|
| A321F | CAO | 195×145×100 | 27,000 kg |
| B737-800BCF | CAO | 218×153×116 | 22,600 kg |
| B767-300F | CAO | 220×244×162 | 52,400 kg |
| A330-200F | CAO | 302×244×163 | 70,000 kg |
| B777F | CAO | 307×244×244 | 103,000 kg |
| B747-400F | CAO | 307×244×244 | 113,000 kg |
| B747-8F | CAO | 312×244×292 | 137,700 kg |
| A320 belly | PAX | 118×90×86 | 7,000 kg |
| B737-800 belly | PAX | 118×90×86 | 11,000 kg |
| B787-9 belly | PAX | 153×117×96 | 13,300 kg |
| A330-300 belly | PAX | 153×117×96 | 15,000 kg |
| B777-300ER belly | PAX | 307×117×96 | 15,000 kg |
| A380-800 belly | PAX | 244×153×160 | 17,000 kg |

Volumetric (chargeable) weight is calculated as `L × W × H (cm) ÷ 6000` per IATA standard.

---

## Tiltable Cargo

The **Tiltable** flag is designed for non-stackable cargo that can safely be rotated on its side during container loading (e.g., crated motorcycles, filing cabinets, furniture sets). Tiltable pallets are tried in all **6 axis orientations** by the bin-packing algorithm, allowing the engine to find configurations that would otherwise be impossible. In the 3D viewer, tilted pallets are shown in **purple**.

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
