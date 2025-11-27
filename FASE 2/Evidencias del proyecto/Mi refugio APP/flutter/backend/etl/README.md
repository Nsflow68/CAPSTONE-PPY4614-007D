# ETL – Servicios de datos Mi Refugio

Objetivo: mantener datasets curados (hidratación, mindfulness, recursos profesionales, etc.) que el backend NestJS pueda servir sin depender de scraping en tiempo real. Cada pipeline sigue tres pasos:

1. **Ingesta** (`data/raw/`): archivos CSV/XLSX/JSON provenientes de fuentes oficiales (MINSAL, OPS, directorios regionales).
2. **Transformación** (`resources_etl.py`, futuros scripts): limpieza, normalización de campos clave (categoría, disponibilidad, contacto), enriquecimiento con etiquetas y validación.
3. **Publicación** (`output/`): JSON listo para ser consumido por NestJS o directamente por Flutter durante pruebas offline.

> A largo plazo estos scripts se ejecutarán en GitHub Actions de manera diaria, subiendo los JSON resultantes a S3/Supabase. Por ahora se ejecutan localmente.

## Cómo ejecutar el ETL de recursos

```bash
cd "FASE 2/Evidencias del proyecto/App/flutter/backend/etl"
python -m venv .venv
.venv\Scripts\activate     # Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt  # (opcional, usa solo stdlib por ahora)
python resources_etl.py
```

- Entrada: `data/raw/resources_sample.csv`
- Salida: `output/resources.json`
- El script elimina duplicados, normaliza categorías y genera un hash `id`.
- Una vez validado, copia el JSON a `backend/nest/src/resources/resources.data.json` o súbelo a un bucket/CDN si se automatiza.

## Pipeline de hidratación (MINSAL)

Genera un dataset semanal promedio en mililitros que funciona como fallback para el backend NestJS cuando Prisma no está disponible.

```bash
cd "FASE 2/Evidencias del proyecto/App/flutter/backend/etl"
node hydration_etl.js
```

- Entrada: `data/raw/hydration_sample.csv` (fecha, grupo, género, ingesta y meta en ml).
- Salida: `output/hydration_reference.json`.
- El script copia automáticamente el resultado a `../nest/src/hydration/hydration.reference.json`, usado por `HydrationService`.

## Próximas pipelines

| Dataset | Script | Estado |
|---------|--------|--------|
| Hidratación (MINSAL) | `hydration_etl.js` | ✅ Genera dataset semanal + copia al backend |
| Diario (anonimizado) | `diary_etl.js` | ✅ Genera `diary.reference.json` (fallback Nest) |
| Estadísticas mindfulness OPS | `mindfulness_etl.js` | ✅ Genera `mindfulness.reference.json` (fallback Nest) |

Mantén este folder versionado (sin datos sensibles). Los archivos confidenciales deben subirse encriptados o almacenarse en Secrets Manager.
