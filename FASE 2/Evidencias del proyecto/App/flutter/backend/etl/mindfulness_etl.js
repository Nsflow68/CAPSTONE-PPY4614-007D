const fs = require('fs');
const path = require('path');

const BASE_DIR = __dirname;
const RAW_FILE = path.join(BASE_DIR, 'data', 'raw', 'mindfulness_sessions.csv');
const OUTPUT_FILE = path.join(BASE_DIR, 'output', 'mindfulness_sessions.json');
const NEST_TARGET = path.join(
  BASE_DIR,
  '..',
  'nest',
  'src',
  'mindfulness',
  'mindfulness.reference.json'
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

function buildSessions(rows) {
  return rows.map((row) => ({
    id: row.id,
    title: row.title,
    durationMinutes: Number(row.duration_minutes),
    level: row.level,
    tags: row.tags.split('|').map((tag) => tag.trim()),
    mediaUrl: row.media_url
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
  const sessions = buildSessions(rows);
  const payload = {
    generatedAt: new Date().toISOString(),
    items: sessions
  };
  writeOutput(payload);
  console.log(`Dataset de mindfulness generado en: ${OUTPUT_FILE}`);
  console.log(`Copiado al backend NestJS: ${NEST_TARGET}`);
}

main();
