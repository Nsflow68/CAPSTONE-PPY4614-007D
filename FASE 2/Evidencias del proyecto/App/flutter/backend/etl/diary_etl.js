const fs = require('fs');
const path = require('path');

const BASE_DIR = __dirname;
const RAW_FILE = path.join(BASE_DIR, 'data', 'raw', 'diary_sample.csv');
const OUTPUT_FILE = path.join(BASE_DIR, 'output', 'diary_reference.json');
const NEST_TARGET = path.join(
  BASE_DIR,
  '..',
  'nest',
  'src',
  'diary',
  'diary.reference.json'
);

function loadRows() {
  if (!fs.existsSync(RAW_FILE)) {
    throw new Error(`No se encontró el archivo ${RAW_FILE}`);
  }
  const [header, ...lines] = fs.readFileSync(RAW_FILE, 'utf-8').trim().split('\n');
  const columns = header.split(',');
  return lines.map((line) => {
    const values = line.split(',');
    return columns.reduce((acc, column, idx) => {
      acc[column.trim()] = values[idx]?.trim() ?? '';
      return acc;
    }, {});
  });
}

function buildEntries(rows) {
  return rows.map((row, index) => ({
    id: `entry-${index + 1}`,
    title: row.title,
    content: row.content,
    mood: row.mood,
    score: Number(row.score),
    moodText: row.moodText,
    date: row.date,
    createdAt: new Date(`${row.date}T08:00:00Z`).toISOString(),
    emotions: row.emotions.split('|').map((item) => item.trim()),
    tags: row.tags.split('|').map((item) => item.trim())
  }));
}

function writeOutput(payload) {
  fs.mkdirSync(path.dirname(OUTPUT_FILE), { recursive: true });
  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(payload, null, 2), 'utf-8');

  fs.mkdirSync(path.dirname(NEST_TARGET), { recursive: true });
  fs.writeFileSync(NEST_TARGET, JSON.stringify(payload, null, 2), 'utf-8');
}

function main() {
  const rows = loadRows();
  const entries = buildEntries(rows);
  const payload = {
    generatedAt: new Date().toISOString(),
    items: entries
  };
  writeOutput(payload);
  console.log(`Dataset de diario generado en: ${OUTPUT_FILE}`);
  console.log(`Copiado al backend NestJS: ${NEST_TARGET}`);
}

main();
