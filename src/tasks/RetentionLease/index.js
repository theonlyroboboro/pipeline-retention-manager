const { execFileSync } = require('child_process');
const path = require('path');

try {
  const daysValid = process.env['INPUT_DAYSVALID'];

  if (!daysValid) {
    throw new Error('daysValid input is required');
  }

  const scriptPath = path.join(__dirname, 'run.ps1');

  execFileSync(
    'pwsh',
    ['-NoLogo', '-NoProfile', '-File', scriptPath, '-DaysValid', daysValid],
    { stdio: 'inherit' }
  );
} catch (err) {
  console.error(err.message);
  process.exit(1);
}
