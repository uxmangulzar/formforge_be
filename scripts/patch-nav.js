const fs = require('fs');
const path = require('path');
const adminDir = path.join(__dirname, '..', 'admin');
function walk(dir) {
    for (const n of fs.readdirSync(dir)) {
        const f = path.join(dir, n);
        if (fs.statSync(f).isDirectory()) { walk(f); continue; }
        if (!/\.(html|js)$/.test(n) || n === 'admin-paths.js') continue;
        let c = fs.readFileSync(f, 'utf8'), o = c;
        c = c.replace(/window\.location\.href\s*=\s*'\/admin\//g, "window.location.href = adminUrl('/");
        c = c.replace(/location\.href='\/admin\//g, "location.href=adminUrl('/");
        c = c.replace(/onclick="location\.href='\/admin\//g, 'onclick="location.href=adminUrl(\'/');
        if (c !== o) { fs.writeFileSync(f, c); console.log(n); }
    }
}
walk(adminDir);
const s = path.join(adminDir, 'js', 'user_subscriptions.js');
let j = fs.readFileSync(s, 'utf8');
j = j.replace("'<a href=\"/admin/user-subscriptions/' +", "'<a href=\"' + adminUrl('/user-subscriptions/') +");
fs.writeFileSync(s, j);
