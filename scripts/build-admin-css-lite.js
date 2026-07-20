/**
 * Generates admin/css/tailwind-built.css from classes used in admin HTML.
 * No npm tailwind required — run: node scripts/build-admin-css-lite.js
 */
const fs = require('fs');
const path = require('path');

const viewsDir = path.join(__dirname, '../admin/views');
const outFile = path.join(__dirname, '../admin/css/tailwind-built.css');

const SPACING = {
    0: '0',
    0.5: '0.125rem',
    1: '0.25rem',
    1.5: '0.375rem',
    2: '0.5rem',
    2.5: '0.625rem',
    3: '0.75rem',
    4: '1rem',
    5: '1.25rem',
    6: '1.5rem',
    8: '2rem',
    9: '2.25rem',
    10: '2.5rem',
    12: '3rem',
    16: '4rem',
    20: '5rem',
    24: '6rem',
    32: '8rem',
    40: '10rem',
    48: '12rem',
    64: '16rem'
};

const GRAY = {
    300: '#d1d5db',
    400: '#9ca3af',
    500: '#6b7280',
    600: '#4b5563',
    700: '#374151',
    800: '#1f2937'
};

const THEME = {
    primary: '#C6FF00',
    secondary: '#00E5FF',
    tertiary: '#D9EFFF',
    neutral: '#0A0A0A',
    black: '#000000',
    white: '#ffffff',
    transparent: 'transparent',
    emerald: { 400: '#34d399', 500: '#10b981' },
    green: { 400: '#4ade80', 500: '#22c55e' },
    red: { 400: '#f87171', 500: '#ef4444' },
    blue: { 500: '#3b82f6' },
    purple: { 400: '#c084fc', 500: '#a855f7' },
    amber: { 400: '#fbbf24', 500: '#f59e0b' },
    orange: { 500: '#f97316' },
    cyan: { 400: '#22d3ee' }
};

function collectHtmlFiles(dir) {
    const out = [];
    for (const name of fs.readdirSync(dir)) {
        const p = path.join(dir, name);
        if (fs.statSync(p).isDirectory()) out.push(...collectHtmlFiles(p));
        else if (name.endsWith('.html')) out.push(p);
    }
    return out;
}

function collectClasses() {
    const set = new Set();
    const re = /class="([^"]+)"/g;
    for (const file of collectHtmlFiles(viewsDir)) {
        const html = fs.readFileSync(file, 'utf8');
        let m;
        while ((m = re.exec(html))) {
            m[1].split(/\s+/).forEach((c) => {
                if (!c || c.includes('${') || c.startsWith('fa-') || c.startsWith("'")) return;
                set.add(c.replace(/^!/, ''));
            });
        }
    }
    return set;
}

function colorValue(name) {
    const slash = name.match(/^([a-z]+)(?:-(\d+))?\/(\d+)$/);
    if (slash) {
        const base = slash[2]
            ? colorValue(`${slash[1]}-${slash[2]}`)
            : THEME[slash[1]] || null;
        if (base) return `color-mix(in srgb, ${base} ${slash[3]}%, transparent)`;
    }
    if (name === 'primary' || name === 'secondary' || name === 'tertiary' || name === 'neutral') {
        return THEME[name];
    }
    const m = name.match(/^([a-z]+)-(\d+)(?:\/(\d+))?$/);
    if (!m) return null;
    const [, family, shade, opacity] = m;
    let base = null;
    if (family === 'gray') base = GRAY[shade];
    else if (THEME[family] && typeof THEME[family] === 'object') base = THEME[family][shade];
    else if (family === 'black' || family === 'white') base = THEME[family];
    if (!base) return null;
    if (opacity) {
        const a = Number(opacity) / 100;
        return `color-mix(in srgb, ${base} ${opacity}%, transparent)`;
    }
    return base;
}

function cssForUtility(cls) {
    const important = cls.startsWith('!');
    const base = important ? cls.slice(1) : cls;
    const imp = important ? ' !important' : '';

    const arbitrary = base.match(/^\[([^\]]+)\]$/);
    if (arbitrary) return null;

    if (base === 'flex') return `display:flex${imp};`;
    if (base === 'inline-flex') return `display:inline-flex${imp};`;
    if (base === 'grid') return `display:grid${imp};`;
    if (base === 'block') return `display:block${imp};`;
    if (base === 'inline-block') return `display:inline-block${imp};`;
    if (base === 'hidden') return `display:none${imp};`;
    if (base === 'relative') return `position:relative${imp};`;
    if (base === 'absolute') return `position:absolute${imp};`;
    if (base === 'fixed') return `position:fixed${imp};`;
    if (base === 'sticky') return `position:sticky${imp};`;
    if (base === 'inset-0') return `inset:0${imp};`;
    if (base === 'z-10') return `z-index:10${imp};`;
    if (base === 'z-20') return `z-index:20${imp};`;
    if (base === 'z-50') return `z-index:50${imp};`;
    if (base === 'overflow-hidden') return `overflow:hidden${imp};`;
    if (base === 'overflow-x-auto') return `overflow-x:auto${imp};`;
    if (base === 'overflow-y-auto') return `overflow-y:auto${imp};`;
    if (base === 'min-h-screen') return `min-height:100vh${imp};`;
    if (base === 'h-full') return `height:100%${imp};`;
    if (base === 'w-full') return `width:100%${imp};`;
    if (base === 'flex-1') return `flex:1 1 0%${imp};`;
    if (base === 'flex-wrap') return `flex-wrap:wrap${imp};`;
    if (base === 'flex-col') return `flex-direction:column${imp};`;
    if (base === 'flex-row') return `flex-direction:row${imp};`;
    if (base === 'flex-shrink-0') return `flex-shrink:0${imp};`;
    if (base === 'items-center') return `align-items:center${imp};`;
    if (base === 'items-start') return `align-items:flex-start${imp};`;
    if (base === 'items-end') return `align-items:flex-end${imp};`;
    if (base === 'justify-center') return `justify-content:center${imp};`;
    if (base === 'justify-between') return `justify-content:space-between${imp};`;
    if (base === 'justify-end') return `justify-content:flex-end${imp};`;
    if (base === 'self-center') return `align-self:center${imp};`;
    if (base === 'text-left') return `text-align:left${imp};`;
    if (base === 'text-center') return `text-align:center${imp};`;
    if (base === 'text-right') return `text-align:right${imp};`;
    if (base === 'uppercase') return `text-transform:uppercase${imp};`;
    if (base === 'capitalize') return `text-transform:capitalize${imp};`;
    if (base === 'italic') return `font-style:italic${imp};`;
    if (base === 'underline') return `text-decoration:underline${imp};`;
    if (base === 'line-through') return `text-decoration:line-through${imp};`;
    if (base === 'whitespace-nowrap') return `white-space:nowrap${imp};`;
    if (base === 'whitespace-pre-wrap') return `white-space:pre-wrap${imp};`;
    if (base === 'truncate') return `overflow:hidden;text-overflow:ellipsis;white-space:nowrap${imp};`;
    if (base === 'font-mono') return `font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,monospace${imp};`;
    if (base === 'font-bold') return `font-weight:700${imp};`;
    if (base === 'font-semibold') return `font-weight:600${imp};`;
    if (base === 'font-extrabold') return `font-weight:800${imp};`;
    if (base === 'font-medium') return `font-weight:500${imp};`;
    if (base === 'font-normal') return `font-weight:400${imp};`;
    if (base === 'leading-relaxed') return `line-height:1.625${imp};`;
    if (base === 'tracking-tighter') return `letter-spacing:-0.05em${imp};`;
    if (base === 'tracking-wider') return `letter-spacing:0.05em${imp};`;
    if (base === 'tracking-widest') return `letter-spacing:0.1em${imp};`;
    if (base === 'cursor-pointer') return `cursor:pointer${imp};`;
    if (base === 'cursor-not-allowed') return `cursor:not-allowed${imp};`;
    if (base === 'select-none') return `user-select:none${imp};`;
    if (base === 'pointer-events-none') return `pointer-events:none${imp};`;
    if (base === 'outline-none') return `outline:none${imp};`;
    if (base.startsWith('divide-')) return null;
    if (base === 'opacity-0') return `opacity:0${imp};`;
    if (base === 'opacity-40') return `opacity:0.4${imp};`;
    if (base === 'opacity-50') return `opacity:0.5${imp};`;
    if (base === 'opacity-55') return `opacity:0.55${imp};`;
    if (base === 'opacity-70') return `opacity:0.7${imp};`;
    if (base === 'opacity-80') return `opacity:0.8${imp};`;
    if (base === 'opacity-90') return `opacity:0.9${imp};`;
    if (base === 'transition-all') return `transition:all 0.15s ease${imp};`;
    if (base === 'duration-300') return `transition-duration:300ms${imp};`;
    if (base === 'animate-pulse') return `animation:pulse 2s cubic-bezier(0.4,0,0.6,1) infinite${imp};`;
    if (base === 'sr-only') {
        return `position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border-width:0${imp};`;
    }
    if (base === 'border') return `border-width:1px${imp};`;
    if (base === 'border-2') return `border-width:2px${imp};`;
    if (base === 'border-t') return `border-top-width:1px${imp};`;
    if (base === 'border-b') return `border-bottom-width:1px${imp};`;
    if (base === 'border-r') return `border-right-width:1px${imp};`;
    if (base === 'border-dashed') return `border-style:dashed${imp};`;
    if (base === 'border-solid') return `border-style:solid${imp};`;
    if (base === 'border-none') return `border-style:none${imp};`;
    if (base === 'border-transparent') return `border-color:transparent${imp};`;
    if (base === 'bg-clip-text') return `background-clip:text;-webkit-background-clip:text;color:transparent${imp};`;
    if (base === 'bg-gradient-to-r') return `background-image:linear-gradient(to right,var(--tw-gradient-stops))${imp};`;
    if (base === 'bg-gradient-to-br') return `background-image:linear-gradient(to bottom right,var(--tw-gradient-stops))${imp};`;
    if (base === 'from-primary') return `--tw-gradient-from:#C6FF00 var(--tw-gradient-from-position);--tw-gradient-to:rgb(198 255 0/0) var(--tw-gradient-to-position);--tw-gradient-stops:var(--tw-gradient-from),var(--tw-gradient-to)${imp};`;
    if (base === 'to-secondary') return `--tw-gradient-to:#00E5FF var(--tw-gradient-to-position)${imp};`;
    if (base === 'to-black') return `--tw-gradient-to:#000 var(--tw-gradient-to-position)${imp};`;
    if (base === 'object-cover') return `object-fit:cover${imp};`;
    if (base === 'list-disc') return `list-style-type:disc${imp};`;
    if (base === 'list-inside') return `list-style-position:inside${imp};`;
    if (base === 'accent-primary') return `accent-color:#C6FF00${imp};`;
    if (base === 'accent-amber-400') return `accent-color:#fbbf24${imp};`;
    if (base === 'max-h-[300px]') return `max-height:300px${imp};`;
    if (base === 'blur-[120px]') return `filter:blur(120px)${imp};`;

    let m = base.match(/^(-?)translate-y-1\/2$/);
    if (m) return `transform:translateY(${m[1] ? '-' : ''}50%)${imp};`;
    m = base.match(/^(-?)translate-x-1\/2$/);
    if (m) return `transform:translateX(${m[1] ? '-' : ''}50%)${imp};`;
    m = base.match(/^(-?)(top|right|bottom|left)-(.+)$/);
    if (m) {
        let val = m[3];
        if (val === '1/2') val = '50%';
        else if (val.startsWith('[')) val = val.slice(1, -1);
        else val = SPACING[val] || val;
        return `${m[2]}:${m[1] ? '-' : ''}${val}${imp};`;
    }

    m = base.match(/^(-?)(gap|gap-x|gap-y)-([\d.]+)$/);
    if (m) {
        const v = SPACING[m[3]] || m[3];
        if (m[2] === 'gap') return `gap:${m[1] ? '-' : ''}${v}${imp};`;
        if (m[2] === 'gap-x') return `column-gap:${m[1] ? '-' : ''}${v}${imp};`;
        if (m[2] === 'gap-y') return `row-gap:${m[1] ? '-' : ''}${v}${imp};`;
    }

    if (base.startsWith('space-') || base.startsWith('divide-')) return null;

    m = base.match(/^grid-cols-(\d+)$/);
    if (m) return `grid-template-columns:repeat(${m[1]},minmax(0,1fr))${imp};`;
    m = base.match(/^col-span-(\d+)$/);
    if (m) return `grid-column:span ${m[1]} / span ${m[1]}${imp};`;

    m = base.match(/^(p|px|py|pt|pb|pl|pr|m|mx|my|mt|mb|ml|mr)-([\d.]+)$/);
    if (m) {
        const v = SPACING[m[2]] || m[2];
        const map = {
            p: `padding:${v}`,
            px: `padding-left:${v};padding-right:${v}`,
            py: `padding-top:${v};padding-bottom:${v}`,
            pt: `padding-top:${v}`,
            pb: `padding-bottom:${v}`,
            pl: `padding-left:${v}`,
            pr: `padding-right:${v}`,
            m: `margin:${v}`,
            mx: `margin-left:${v};margin-right:${v}`,
            my: `margin-top:${v};margin-bottom:${v}`,
            mt: `margin-top:${v}`,
            mb: `margin-bottom:${v}`,
            ml: `margin-left:${v}`,
            mr: `margin-right:${v}`
        };
        if (map[m[1]]) return `${map[m[1]]}${imp};`;
    }

    m = base.match(/^(-?)m-0$/);
    if (m) return `margin:0${imp};`;

    m = base.match(/^h-\[(.+)\]$/);
    if (m) return `height:${m[1]}${imp};`;
    m = base.match(/^w-\[(.+)\]$/);
    if (m) return `width:${m[1]}${imp};`;
    m = base.match(/^max-h-\[(.+)\]$/);
    if (m) return `max-height:${m[1]}${imp};`;

    m = base.match(/^w-([\d.]+|full|screen)$/);
    if (m) {
        if (m[1] === 'full') return `width:100%${imp};`;
        if (m[1] === 'screen') return `width:100vw${imp};`;
        return `width:${SPACING[m[1]] || m[1]}${imp};`;
    }
    m = base.match(/^h-([\d.]+|full|screen)$/);
    if (m) {
        if (m[1] === 'full') return `height:100%${imp};`;
        if (m[1] === 'screen') return `height:100vh${imp};`;
        return `height:${SPACING[m[1]] || m[1]}${imp};`;
    }
    m = base.match(/^max-w-(.+)$/);
    if (m) {
        const map = { md: '28rem', lg: '32rem', xl: '36rem', '2xl': '42rem', '4xl': '56rem', '7xl': '80rem' };
        return `max-width:${map[m[1]] || SPACING[m[1]] || m[1]}${imp};`;
    }
    m = base.match(/^min-w-(.+)$/);
    if (m) return `min-width:${m[1] === 'full' ? '100%' : SPACING[m[1]] || m[1]}${imp};`;

    m = base.match(/^text-\[(.+)\]$/);
    if (m) return `font-size:${m[1]};line-height:1.25${imp};`;

    m = base.match(/^tracking-\[(.+)\]$/);
    if (m) return `letter-spacing:${m[1]}${imp};`;

    m = base.match(/^text-(xs|sm|base|lg|xl|2xl|3xl|4xl)$/);
    if (m) {
        const map = {
            xs: '0.75rem',
            sm: '0.875rem',
            base: '1rem',
            lg: '1.125rem',
            xl: '1.25rem',
            '2xl': '1.5rem',
            '3xl': '1.875rem',
            '4xl': '2.25rem'
        };
        return `font-size:${map[m[1]]};line-height:1.25${imp};`;
    }

    m = base.match(/^text-\[(.+)\]$/);
    if (m) return `font-size:${m[1]}${imp};`;

    m = base.match(/^tracking-\[(.+)\]$/);
    if (m) return `letter-spacing:${m[1]}${imp};`;

    m = base.match(/^text-(.+)$/);
    if (m) {
        const c = colorValue(m[1]);
        if (c) return `color:${c}${imp};`;
        if (m[1] === 'main') return `color:var(--text-main)${imp};`;
        if (m[1] === 'muted') return `color:var(--text-muted)${imp};`;
        if (m[1] === 'black') return `color:#000${imp};`;
        if (m[1] === 'white') return `color:#fff${imp};`;
    }

    m = base.match(/^bg-(.+)$/);
    if (m) {
        if (m[1].startsWith('[')) {
            const val = m[1].slice(1, -1);
            return `background-color:${val}${imp};`;
        }
        const c = colorValue(m[1]);
        if (c) return `background-color:${c}${imp};`;
    }

    m = base.match(/^border-(.+)$/);
    if (m) {
        if (m[1].startsWith('[')) return `border-color:${m[1].slice(1, -1)}${imp};`;
        const c = colorValue(m[1]);
        if (c) return `border-color:${c}${imp};`;
    }

    m = base.match(/^divide-(.+)$/);
    if (m) {
        const c = colorValue(m[1]);
        if (c) return `border-color:${c}${imp};`;
    }

    m = base.match(/^rounded(-(.+))?$/);
    if (m) {
        const map = {
            sm: '0.125rem',
            md: '0.375rem',
            lg: '0.5rem',
            xl: '0.75rem',
            '2xl': '1rem',
            '3xl': '1.5rem',
            full: '9999px'
        };
        if (!m[2]) return `border-radius:0.25rem${imp};`;
        return `border-radius:${map[m[2]] || m[2]}${imp};`;
    }

    m = base.match(/^shadow(-(.+))?$/);
    if (m) {
        if (!m[2]) return `box-shadow:0 1px 3px 0 rgb(0 0 0 / 0.1)${imp};`;
        if (m[2] === 'lg') return `box-shadow:0 10px 15px -3px rgb(0 0 0 / 0.1)${imp};`;
        if (m[2] === '2xl') return `box-shadow:0 25px 50px -12px rgb(0 0 0 / 0.25)${imp};`;
        if (m[2].startsWith('[')) return `box-shadow:${m[2].slice(1, -1)}${imp};`;
    }

    if (base === 'hover:scale-[1.02]') return `transform:scale(1.02)${imp};`;
    if (base === 'group-hover:translate-x-1') return `transform:translateX(0.25rem)${imp};`;
    if (base === 'group-hover:text-gray-300') return `color:#d1d5db${imp};`;

    m = base.match(/^peer-checked:(.+)$/);
    if (m) {
        const inner = cssForUtility(m[1]);
        if (inner) return `@peerChecked{${inner}}`;
    }

    m = base.match(/^hover:(.+)$/);
    if (m) {
        const inner = cssForUtility(m[1]);
        if (inner) return `@hover{${inner}}`;
    }

    return null;
}

function escapeSelector(cls) {
    return cls.replace(/\\/g, '\\\\').replace(/:/g, '\\:').replace(/\[/g, '\\[').replace(/\]/g, '\\]').replace(/\//g, '\\/').replace(/\./g, '\\.').replace(/'/g, "\\'");
}

function buildSpaceRule(className) {
    const inner = className.replace(/^(sm|md|lg):/, '');
    const m = inner.match(/^space-(x|y)-([\d.]+)$/);
    if (!m) return null;
    const v = SPACING[m[2]] || m[2];
    const prop = m[1] === 'x' ? 'margin-left' : 'margin-top';
    return `.${escapeSelector(className)} > :not([hidden]) ~ :not([hidden]){${prop}:${v};}`;
}

function buildDivideRule(className) {
    const inner = className.replace(/^(sm|md|lg):/, '');
    if (inner === 'divide-y') {
        return `.${escapeSelector(className)} > :not([hidden]) ~ :not([hidden]){border-top-width:1px;}`;
    }
    const m = inner.match(/^divide-(.+)$/);
    if (!m || m[1] === 'y' || m[1] === 'x') return null;
    const c = colorValue(m[1]);
    if (!c) return null;
    return `.${escapeSelector(className)} > :not([hidden]) ~ :not([hidden]){border-color:${c};}`;
}

function build() {
    const classes = collectClasses();
    const rules = [];
    const hoverRules = [];
    const peerCheckedRules = [];
    const groupHoverRules = [];
    const peerRules = [];
    const mdRules = new Map();
    const lgRules = new Map();
    const smRules = new Map();
    const missing = [];

    for (const cls of classes) {
        if (/^[a-z-]+-page$/.test(cls) || cls.includes('template') || cls.startsWith('tag-')) continue;
        if (['card', 'form-input', 'io-btn', 'section-title', 'login-page'].includes(cls)) continue;

        let raw = cls;
        let prefix = '';
        if (cls.startsWith('group-hover:')) {
            raw = cls.slice(12);
            const css = cssForUtility(raw);
            if (css && !css.startsWith('@hover')) {
                groupHoverRules.push(`.group:hover .${escapeSelector(cls)}{${css}}`);
            }
            continue;
        }
        if (cls.startsWith('peer-checked:')) {
            raw = cls.slice(13);
            const css = cssForUtility(raw);
            if (css && !css.startsWith('@')) {
                peerRules.push(`.peer:checked~.${escapeSelector(cls)}{${css}}`);
            }
            continue;
        }
        if (cls.startsWith('md:')) {
            prefix = 'md';
            raw = cls.slice(3);
        } else if (cls.startsWith('lg:')) {
            prefix = 'lg';
            raw = cls.slice(3);
        } else if (cls.startsWith('sm:')) {
            prefix = 'sm';
            raw = cls.slice(3);
        }

        const spaceRule = buildSpaceRule(cls);
        if (spaceRule) {
            if (prefix === 'sm') smRules.set(cls, spaceRule);
            else if (prefix === 'md') mdRules.set(cls, spaceRule);
            else if (prefix === 'lg') lgRules.set(cls, spaceRule);
            else rules.push(spaceRule);
            continue;
        }

        const divideRule = buildDivideRule(cls);
        if (divideRule) {
            if (prefix === 'sm') smRules.set(cls, divideRule);
            else if (prefix === 'md') mdRules.set(cls, divideRule);
            else if (prefix === 'lg') lgRules.set(cls, divideRule);
            else rules.push(divideRule);
            continue;
        }

        const css = cssForUtility(raw);
        if (!css) {
            if (!raw.includes('peer') && !raw.startsWith('after:') && !raw.startsWith('group-')) {
                missing.push(cls);
            }
            continue;
        }

        if (css.startsWith('@hover{')) {
            hoverRules.push(`.${escapeSelector(cls.replace(/^hover:/, ''))}:hover{${css.slice(7, -1)}}`);
            continue;
        }
        if (css.startsWith('@peerChecked{')) {
            peerCheckedRules.push(
                `.peer:checked~.${escapeSelector(cls.replace(/^peer-checked:/, ''))}{${css.slice(13, -1)}}`
            );
            continue;
        }
        if (css.startsWith('@groupHover{')) {
            groupHoverRules.push(
                `.group:hover .${escapeSelector(cls.replace(/^group-hover:/, ''))}{${css.slice(12, -1)}}`
            );
            continue;
        }

        const selector = `.${escapeSelector(cls)}{${css}}`;
        if (prefix === 'md') mdRules.set(cls, selector);
        else if (prefix === 'lg') lgRules.set(cls, selector);
        else if (prefix === 'sm') smRules.set(cls, selector);
        else rules.push(selector);
    }

    const preflight = `*,::before,::after{box-sizing:border-box;border-width:0;border-style:solid;border-color:#e5e7eb}
html{line-height:1.5;-webkit-text-size-adjust:100%;tab-size:4}
body{margin:0;line-height:inherit}
img,video{max-width:100%;height:auto}
button,input,select,textarea{font:inherit;color:inherit;margin:0;padding:0}
@keyframes pulse{0%,100%{opacity:1}50%{opacity:.5}}
`;

    let out = `/* Auto-generated — node scripts/build-admin-css-lite.js */\n${preflight}\n${rules.join('\n')}\n`;
    if (smRules.size) {
        out += `@media(min-width:640px){${[...smRules.values()].join('')}}\n`;
    }
    if (mdRules.size) {
        out += `@media(min-width:768px){${[...mdRules.values()].join('')}}\n`;
    }
    if (lgRules.size) {
        out += `@media(min-width:1024px){${[...lgRules.values()].join('')}}\n`;
    }
    out += hoverRules.join('\n') + '\n';
    out += peerCheckedRules.join('\n') + '\n';
    out += peerRules.join('\n') + '\n';
    out += groupHoverRules.join('\n') + '\n';

    // Toggle switches only (w-9 h-5) — not login checkboxes
    out += `label .sr-only.peer~.w-9.h-5{position:relative;display:inline-block;width:2.25rem;height:1.25rem;background-color:#374151;border-radius:9999px;flex-shrink:0;transition:background-color .15s ease}
label .sr-only.peer~.w-9.h-5::after{content:'';position:absolute;top:2px;left:2px;width:1rem;height:1rem;background:#fff;border:1px solid #d1d5db;border-radius:9999px;transition:transform .15s ease;box-sizing:border-box}
label .sr-only.peer:checked~.w-9.h-5::after{transform:translateX(calc(2.25rem - 1rem - 4px))}
label .sr-only.peer:checked~.w-9.peer-checked\\:bg-primary{background-color:#C6FF00 !important;}
label .sr-only.peer:checked~.w-9.peer-checked\\:bg-amber-400{background-color:#fbbf24 !important;}
label .sr-only.peer:focus~.w-9.h-5{outline:2px solid rgba(198,255,0,.45);outline-offset:2px}
.w-9{width:2.25rem}
`;

    fs.writeFileSync(outFile, out);
    console.log('Wrote', outFile);
    console.log('Rules:', rules.length, 'md:', mdRules.size, 'lg:', lgRules.size, 'hover:', hoverRules.length);
    if (missing.length) {
        console.log('Unmapped (non-critical):', missing.length);
        fs.writeFileSync(path.join(__dirname, 'admin-css-missing.txt'), missing.sort().join('\n'));
    }
}

build();
