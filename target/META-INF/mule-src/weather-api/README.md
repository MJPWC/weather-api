# 🌤️ Weather API — MuleSoft Sample Project

A **medium-level MuleSoft 4.4 project** demonstrating API-led connectivity by integrating
with the free [Open-Meteo](https://open-meteo.com/) weather API (no key required).

---

## Architecture

```
Client
  │
  ▼
[Experience Layer]  POST /api/weather
  │  → validates input
  │  → sets variables
  │
  ▼
[Process Layer]     weather-process-flow
  │  → calls system API
  │  → applies DW business transformation
  │  → builds heat advisory, condition labels
  │
  ▼
[System Layer]      openmeteo-system-flow
     → HTTPS GET api.open-meteo.com/v1/forecast
     → parses raw JSON
```

---

## Flows

| Flow | Type | Responsibility |
|------|------|----------------|
| `weather-experience-flow` | Experience | HTTP listener, routing, error handling |
| `validate-request-flow`   | Sub-flow   | Input validation, raises APP:VALIDATION_ERROR |
| `weather-process-flow`    | Process    | Business logic + DW transformation |
| `openmeteo-system-flow`   | System     | HTTPS call to Open-Meteo |
| `health-check-flow`       | Utility    | GET /api/health for monitoring |

---

## Key Concepts Demonstrated

- ✅ **API-Led Connectivity** (Experience → Process → System)
- ✅ **Environment-based config** (`config-local.yaml`, `config-dev.yaml`)
- ✅ **DataWeave 2.0** — helper functions, map, conditional logic
- ✅ **Error handling** — typed errors (`APP:VALIDATION_ERROR`, `HTTP:CONNECTIVITY`)
- ✅ **MUnit 2.3.x tests** — mocking, flow-ref mocking, assertions
- ✅ **Structured logging** with meaningful messages

---

## Running Locally

### Prerequisites
- Anypoint Studio 7.x
- Mule Runtime 4.4.x (EE)
- Java 8 or 11

### Steps
1. Import the project into Anypoint Studio (`File → Import → Anypoint Studio Project`)
2. Run as Mule Application (default env: `local`)
3. API is available at `http://localhost:8081`

### Override Environment
Add this to VM arguments in Run Configuration:
```
-Dmule.env=dev
```

---

## API Reference

### POST /api/weather

**Request:**
```json
{
  "city"      : "Jaipur",
  "latitude"  : 26.9124,
  "longitude" : 75.7873,
  "units"     : "celsius"
}
```

**Fields:**

| Field | Required | Description |
|-------|----------|-------------|
| latitude  | ✅ | Between -90 and 90 |
| longitude | ✅ | Between -180 and 180 |
| city      | ❌ | Display name only |
| units     | ❌ | `celsius` (default) or `fahrenheit` |

**Successful Response (200):**
```json
{
  "status"    : "success",
  "requestId" : "550e8400-e29b-41d4-a716-446655440000",
  "city"      : "Jaipur",
  "units"     : "celsius",
  "weather"   : {
    "current": {
      "temperature"   : "38 °C",
      "feelsLike"     : "42 °C",
      "humidity"      : "35 %",
      "windSpeed"     : "18 km/h",
      "windDirection" : "220°",
      "condition"     : "Mainly clear",
      "isDay"         : "Day",
      "heatAdvisory"  : "Extreme heat — stay hydrated!",
      "observedAt"    : "2024-06-15T12:00"
    },
    "hourlyForecast": [ ... ],
    "summary": "Fetched from Open-Meteo | Coordinates: (26.9124, 75.7873)"
  }
}
```

**Error Responses:**

| Code | Scenario |
|------|----------|
| 400  | Missing or invalid lat/lon |
| 503  | Open-Meteo unreachable |
| 500  | Unexpected internal error |

---

### GET /api/health
```json
{
  "status"    : "UP",
  "service"   : "weather-api",
  "version"   : "1.0.0",
  "timestamp" : "2024-06-15T12:00:00+0530"
}
```

---

## Sample curl Commands

```bash
# Jaipur weather
curl -X POST http://localhost:8081/api/weather \
  -H "Content-Type: application/json" \
  -d '{"city":"Jaipur","latitude":26.9124,"longitude":75.7873}'

# London in Fahrenheit
curl -X POST http://localhost:8081/api/weather \
  -H "Content-Type: application/json" \
  -d '{"city":"London","latitude":51.5074,"longitude":-0.1278,"units":"fahrenheit"}'

# Health check
curl http://localhost:8081/api/health

# Validation error test
curl -X POST http://localhost:8081/api/weather \
  -H "Content-Type: application/json" \
  -d '{"city":"Nowhere"}'
```

---

## Running MUnit Tests

```bash
mvn test
```

Tests included:
- `test-valid-weather-request` — mocks system flow, asserts transformed output
- `test-missing-coordinates` — expects APP:VALIDATION_ERROR
- `test-invalid-latitude` — expects APP:VALIDATION_ERROR

---

## 3rd Party API — Open-Meteo

| Property | Value |
|----------|-------|
| Base URL | `https://api.open-meteo.com` |
| Endpoint | `GET /v1/forecast` |
| Auth     | None — completely free |
| Docs     | https://open-meteo.com/en/docs |
