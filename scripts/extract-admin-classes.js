const fs = require('fs');
const path = require('path');

const viewsDir = path.join(__dirname, '../admin/views');
const files = [];

function walk(dir) {
    for (const name of fs.readdirSync(dir)) {
        const p = path.join(dir, name);
        if (fs.statSync(p).isDirectory()) walk(p);
        else if (name.endsWith('.html')) files.push(p);
    }
}

walk(viewsDir);
const classes = new Set();
const re = /class="([^"]+)"/g;

for (const file of files) {
    const html = fs.readFileSync(file, 'utf8');
    let m;
    while ((m = re.exec(html))) {
        m[1].split(/\s+/).forEach((c) => {
            if (c && !c.includes('${')) classes.add(c);
        });
    }
}

console.log('unique classes:', classes.size);
[...classes].sort().forEach((c) => console.log(c));
