const fs = require('fs');
const path = require('path');

const ROOT_DIR = __dirname;
const IGNORE_DIRS = [
  'node_modules',
  '.git',
  '.terraform',
  'graphify-out',
  'dist',
  'build',
  '.gemini'
];

const IGNORE_FILES = [
  'rebrand_all.js',
  '.DS_Store'
];

const EXTENSIONS = [
  '.js',
  '.jsx',
  '.json',
  '.yml',
  '.yaml',
  '.tf',
  '.hcl',
  'dockerfile',
  '.html',
  '.css',
  '.md',
  '.sh',
  '.ps1'
];

function shouldProcessFile(filename) {
  if (IGNORE_FILES.includes(filename)) return false;
  const lowerName = filename.toLowerCase();
  
  // Specific match for Dockerfile
  if (lowerName === 'dockerfile') return true;
  
  return EXTENSIONS.some(ext => lowerName.endsWith(ext));
}

function processDirectory(dir) {
  const files = fs.readdirSync(dir);
  
  for (const file of files) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory()) {
      if (IGNORE_DIRS.includes(file)) continue;
      processDirectory(fullPath);
    } else if (stat.isFile() && shouldProcessFile(file)) {
      try {
        let content = fs.readFileSync(fullPath, 'utf8');
        let modified = false;
        
        // Case-sensitive replacements
        if (content.includes('WellNest')) {
          content = content.replace(/WellNest/g, 'CalmRoot');
          modified = true;
        }
        if (content.includes('wellnest')) {
          content = content.replace(/wellnest/g, 'calmroot');
          modified = true;
        }
        if (content.includes('WELLNEST')) {
          content = content.replace(/WELLNEST/g, 'CALMROOT');
          modified = true;
        }
        
        if (modified) {
          fs.writeFileSync(fullPath, content, 'utf8');
          console.log(`✅ Rebranded: ${path.relative(ROOT_DIR, fullPath)}`);
        }
      } catch (err) {
        console.error(`❌ Error reading/writing file ${file}:`, err.message);
      }
    }
  }
}

console.log('🌿 Starting CalmRoot Rebranding tool...');
processDirectory(ROOT_DIR);
console.log('🎉 Rebranding complete!');
