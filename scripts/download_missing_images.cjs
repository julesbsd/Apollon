// Telecharge les images SVG manquantes depuis l'API Workout.
// Idempotent: ne telecharge que les exercices qui n'ont PAS deja un fichier
// <code>.svg sur disque ET ne sont pas dans le manifest. Le matching se fait
// par CODE (stable), car l'API regenere ses IDs (le json local est perime).
//
// Usage:
//   node scripts/download_missing_images.cjs --dry      (reconciliation hors-ligne, aucune requete API)
//   node scripts/download_missing_images.cjs --limit 1  (telecharge 1 image manquante - sert de test)
//   node scripts/download_missing_images.cjs            (telecharge TOUTES les manquantes)
//
// La cle API est lue depuis lib/secrets.dart (workoutApiKey), jamais codee en dur.

const fs = require('fs');
const path = require('path');
const https = require('https');

const ROOT = path.resolve(__dirname, '..');
const CATALOG = path.join(ROOT, 'docs', 'workout_api_exercises_fr.json'); // fallback hors-ligne (ids perimes)
const IMG_DIR = path.join(ROOT, 'assets', 'exercise_images');
const MANIFEST = path.join(IMG_DIR, 'manifest.json');
const SECRETS = path.join(ROOT, 'lib', 'secrets.dart');
const RATE_LIMIT_MS = 500;

const args = process.argv.slice(2);
const DRY = args.includes('--dry');
const limitIdx = args.indexOf('--limit');
const LIMIT = limitIdx >= 0 ? parseInt(args[limitIdx + 1], 10) : Infinity;

function readApiKey() {
  const src = fs.readFileSync(SECRETS, 'utf8');
  const m = src.match(/workoutApiKey\s*=\s*['"]([^'"]+)['"]/);
  if (!m) throw new Error('workoutApiKey introuvable dans lib/secrets.dart');
  return m[1];
}

function loadManifest() {
  if (!fs.existsSync(MANIFEST)) return { preseeded_exercises: [] };
  const m = JSON.parse(fs.readFileSync(MANIFEST, 'utf8'));
  if (!Array.isArray(m.preseeded_exercises)) m.preseeded_exercises = [];
  return m;
}

function apiGet(pathn, apiKey, accept) {
  return new Promise((resolve) => {
    const req = https.request(
      { method: 'GET', hostname: 'api.workoutapi.com', path: pathn, headers: { 'x-api-key': apiKey, Accept: accept } },
      (res) => {
        const chunks = [];
        res.on('data', (c) => chunks.push(c));
        res.on('end', () => resolve({ status: res.statusCode, body: Buffer.concat(chunks) }));
      }
    );
    req.on('error', (e) => resolve({ status: 0, body: Buffer.from(String(e.message)) }));
    req.setTimeout(15000, () => { req.destroy(); resolve({ status: 0, body: Buffer.from('timeout') }); });
    req.end();
  });
}

const getImage = (id, apiKey) => apiGet(`/exercises/${id}/image`, apiKey, 'image/svg+xml');

async function fetchLiveCatalog(apiKey) {
  const res = await apiGet('/exercises', apiKey, 'application/json');
  if (res.status !== 200) throw new Error(`GET /exercises a echoue (HTTP ${res.status}): ${res.body.toString().slice(0, 160)}`);
  return JSON.parse(res.body.toString());
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

(async () => {
  const manifest = loadManifest();
  const manifestCodes = new Set(manifest.preseeded_exercises.map((e) => e.code));
  const filesOnDisk = fs.existsSync(IMG_DIR)
    ? new Set(fs.readdirSync(IMG_DIR).filter((f) => f.endsWith('.svg')))
    : new Set();

  // Un code est "deja telecharge" si son fichier <code>.svg existe OU s'il est dans le manifest.
  const isDownloaded = (code) => filesOnDisk.has(`${code.toLowerCase()}.svg`) || manifestCodes.has(code);

  console.log('=== RECONCILIATION ===');
  console.log(`Fichiers .svg sur disque: ${filesOnDisk.size}`);
  console.log(`Entrees dans manifest.json: ${manifest.preseeded_exercises.length}`);
  const manifestNoFile = manifest.preseeded_exercises.filter((e) => !filesOnDisk.has(e.filename));
  const fileNoManifest = [...filesOnDisk].filter((f) => !manifest.preseeded_exercises.some((e) => e.filename === f));
  if (manifestNoFile.length) console.log(`!! manifest sans fichier: ${manifestNoFile.map((e) => e.filename).join(', ')}`);
  if (fileNoManifest.length) console.log(`!! fichier sans manifest: ${fileNoManifest.join(', ')}`);

  if (DRY) {
    const local = JSON.parse(fs.readFileSync(CATALOG, 'utf8'));
    const missing = local.filter((ex) => !isDownloaded(ex.code));
    console.log(`Catalogue local (ids PERIMES, codes ok): ${local.length} | manquants: ${missing.length}\n`);
    missing.forEach((e, i) => console.log(`  ${String(i + 1).padStart(2)}. ${e.code}  (${e.name})`));
    return;
  }

  const apiKey = readApiKey();
  console.log(`\nRecuperation du catalogue LIVE (cle ${apiKey.slice(0, 4)}***)...`);
  const live = await fetchLiveCatalog(apiKey);
  console.log(`Catalogue live: ${live.length} exercices (ids a jour).`);

  const todoAll = live.filter((ex) => !isDownloaded(ex.code));
  const todo = todoAll.slice(0, LIMIT);
  console.log(`A telecharger: ${todo.length}${LIMIT !== Infinity ? ` (limite ${LIMIT})` : ''} sur ${todoAll.length} manquant(s). Rate-limit ${RATE_LIMIT_MS}ms.\n`);

  if (todo.length === 0) {
    console.log('Rien a telecharger: tout le catalogue live a deja une image locale.');
    return;
  }

  let ok = 0, noImage = 0, err = 0;
  for (let i = 0; i < todo.length; i++) {
    const ex = todo[i];
    const filename = `${ex.code.toLowerCase()}.svg`;
    process.stdout.write(`[${i + 1}/${todo.length}] ${ex.code} ... `);
    const res = await getImage(ex.id, apiKey);

    if (res.status === 401 || res.status === 403) {
      console.log(`\n\nARRET: probleme d'authentification (HTTP ${res.status}: ${res.body.toString().slice(0, 120)}). Verifie la cle.`);
      process.exitCode = 1;
      break;
    }
    if (res.status === 429) {
      console.log(`\n\nARRET: quota API depasse (HTTP 429). Relance plus tard, le script reprend ou il s'est arrete.`);
      process.exitCode = 1;
      break;
    }
    if (res.status === 200 && res.body.length > 0) {
      fs.writeFileSync(path.join(IMG_DIR, filename), res.body);
      manifest.preseeded_exercises.push({ id: ex.id, code: ex.code, filename });
      fs.writeFileSync(MANIFEST, JSON.stringify(manifest, null, 2)); // ecrit a chaque succes => reprise sure
      ok++;
      console.log(`OK (${(res.body.length / 1024).toFixed(1)} KB)`);
    } else if (res.status === 404) {
      noImage++;
      console.log('pas d\'image (404) -> saute');
    } else {
      err++;
      console.log(`ERREUR HTTP ${res.status}: ${res.body.toString().slice(0, 100)}`);
    }
    if (i < todo.length - 1) await sleep(RATE_LIMIT_MS);
  }

  console.log(`\n=== TERMINE === telechargees: ${ok} | sans image (404): ${noImage} | erreurs: ${err} | manifest: ${manifest.preseeded_exercises.length} entrees`);
})();
