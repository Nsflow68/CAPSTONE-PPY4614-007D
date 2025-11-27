#!/usr/bin/env python3
"""Pequeño ETL para normalizar recursos profesionales de salud mental."""
from __future__ import annotations

import csv
import hashlib
import json
from dataclasses import dataclass, asdict
from pathlib import Path

ROOT = Path(__file__).parent
RAW_CSV = ROOT / "data" / "raw" / "resources_sample.csv"
OUTPUT_JSON = ROOT / "output" / "resources.json"


@dataclass
class Resource:
  name: str
  category: str
  description: str
  contact: str | None
  website: str | None
  availability: str

  @property
  def id(self) -> str:
    slug = f"{self.name}-{self.category}".lower()
    return hashlib.sha1(slug.encode(), usedforsecurity=False).hexdigest()[:12]

  def normalized_category(self) -> str:
    mapping = {
        "urgencia": "Urgencia",
        "juventud": "Juventud",
        "profesionales": "Profesionales",
        "mindfulness": "Mindfulness",
        "comunidad": "Comunidad"
    }
    key = self.category.strip().lower()
    return mapping.get(key, self.category.strip().title())

  def to_dict(self) -> dict:
    data = asdict(self)
    data["id"] = self.id
    data["category"] = self.normalized_category()
    return {k: v for k, v in data.items() if v not in ("", None)}


def load_resources() -> list[Resource]:
  if not RAW_CSV.exists():
    raise FileNotFoundError(f"No se encontró {RAW_CSV}")
  resources: list[Resource] = []
  with RAW_CSV.open("r", encoding="utf-8") as fh:
    reader = csv.DictReader(fh)
    for row in reader:
      resources.append(
          Resource(
              name=row["name"].strip(),
              category=row["category"].strip(),
              description=row["description"].strip(),
              contact=(row.get("contact") or "").strip() or None,
              website=(row.get("website") or "").strip() or None,
              availability=row["availability"].strip()
          )
      )
  return resources


def run() -> None:
  resources = load_resources()
  dedup = {r.id: r for r in resources}  # evita duplicados
  payload = [res.to_dict() for res in dedup.values()]
  OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
  OUTPUT_JSON.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
  print(f"ETL completado => {OUTPUT_JSON} ({len(payload)} recursos).")


if __name__ == "__main__":
  run()
