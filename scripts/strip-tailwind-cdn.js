const fs = require('fs');
const path = require('path');

const viewsDir = path.join(__dirname, '../admin/views');
const tailwindCdn = /\s*<script src="https:\/\/cdn\.tailwindcss\.com"><\/script>\s*/gi;
const tailwindConfig = /\s*<script>\s*\r?\n\s*tailwind\.config = \{[\s\S]*?\}\s*<\/script>\s*/gi;

function walk(dir) {
    const files = [];
    for (const name of fs.readdirSync(dir)) {
        const p = path.join(dir, name);
        if (fs.statSync(p).isDirectory()) files.push(...walk(p));
        else if (name.endsWith('.html')) files.push(p);
    }
    return files;
}

for (const file of walk(viewsDir)) {
    let html = fs.readFileSync(file, 'utf8');
    const before = html;
    html = html.replace(tailwindCdn, '\n');
    html = html.replace(tailwindConfig, '\n');
    if (html !== before) {
        fs.writeFileSync(file, html);
        console.log('updated', path.relative(process.cwd(), file));
    }
}

console.log('done');
