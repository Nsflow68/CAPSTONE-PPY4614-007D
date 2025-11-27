const fs = require('fs');
const path = require('path');

const BASE_DIR = __dirname;
const RAW_FILE = path.join(BASE_DIR, 'data', 'raw', 'hydration_sample.csv');
const OUTPUT_FILE = path.join(BASE_DIR, 'output', 'hydration_reference.json');
const NEST_TARGET = path.join(
  BASE_DIR,
  '..',
  'nest',
  'src',
  'hydration',
  'hydration.reference.json'
);

function loadRows() {
  if (!fs.existsSync(RAW_FILE)) {
    throw new Error(`No se encontró el archivo ${RAW_FILE}`);
  }

  const [header, ...lines] = fs
    .readFileSync(RAW_FILE, 'utf-8')
    .trim()
    .split('\n');
  const columns = header.split(',');
  return lines.map((line) => {
    const values = line.split(',');
    return columns.reduce((acc, column, idx) => {
      acc[column.trim()] = values[idx].trim();
      return acc;
    }, {});
  });
}

function aggregate(rows) {
  const grouped = new Map();
  rows.forEach((row) => {
    const date = row.date;
    const entry = {
      intake: Number(row.intake_ml),
      goal: Number(row.goal_ml)
    };
    if (!grouped.has(date)) grouped.set(date, []);
    grouped.get(date).push(entry);
  });

  const items = Array.from(grouped.keys())
    .sort()
    .map((date) => {
      const entries = grouped.get(date);
      const avgIntake =
        entries.reduce((sum, entry) => sum + entry.intake, 0) / entries.length;
      const avgGoal =
        entries.reduce((sum, entry) => sum + entry.goal, 0) / entries.length;

      return {
        date,
        totalMl: Math.round(avgIntake),
        goalMl: Math.round(avgGoal),
        percentage: Number((avgIntake / avgGoal).toFixed(2))
      };
    });

  const averageMl =
    items.reduce((sum, item) => sum + item.totalMl, 0) / items.length;

  return {
    generatedAt: new Date().toISOString(),
    source: 'MINSAL (dataset sintético de hidratación diaria)',
    items,
    averageMl: Number(averageMl.toFixed(2))
  };
}

function writeOutput(payload) {
  fs.mkdirSync(path.dirname(OUTPUT_FILE), { recursive: true });
  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(payload, null, 2), 'utf-8');

  fs.mkdirSync(path.dirname(NEST_TARGET), { recursive: true });
  fs.writeFileSync(NEST_TARGET, JSON.stringify(payload, null, 2), 'utf-8');
}

function main() {
  const rows = loadRows();
  const payload = aggregate(rows);
  writeOutput(payload);
  console.log(`Dataset generado en: ${OUTPUT_FILE}`);
  console.log(`Copiado al backend NestJS: ${NEST_TARGET}`);
}

main();
