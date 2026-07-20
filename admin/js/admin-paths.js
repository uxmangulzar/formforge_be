/**
 * Base path when admin is under a subpath (e.g. /be/admin on repvio.fit).
 * Local: /admin/... → APP_BASE_PATH = ''
 * Production: /be/admin/... → APP_BASE_PATH = '/be'
 */
(function (global) {
    const STORAGE_KEY = 'repvioAppBase';

    function detectAppBase() {
        if (typeof global.__APP_BASE_PATH__ === 'string') {
            return global.__APP_BASE_PATH__;
        }
        const path = global.location.pathname;
        const idx = path.indexOf('/admin');
        if (idx >= 0) {
            const base = path.slice(0, idx);
            try {
                if (base) global.sessionStorage.setItem(STORAGE_KEY, base);
                else global.sessionStorage.removeItem(STORAGE_KEY);
            } catch (_) {}
            return base;
        }
        return '';
    }

    function applyBase() {
        const APP_BASE = detectAppBase();
        global.APP_BASE_PATH = APP_BASE;
        global.ADMIN_BASE = APP_BASE + '/admin';
        return APP_BASE;
    }

    applyBase();

    global.adminUrl = function adminUrl(path) {
        applyBase();
        if (!path || path === '/') return global.ADMIN_BASE + '/dashboard';
        let p = path.startsWith('/') ? path : '/' + path;
        if (p.startsWith('/admin')) return global.APP_BASE_PATH + p;
        if (p.startsWith(global.ADMIN_BASE)) return p;
        return global.ADMIN_BASE + p;
    };

    global.apiUrl = function apiUrl(path) {
        applyBase();
        let p = path.startsWith('/') ? path : '/' + path;
        if (!p.startsWith('/api')) p = '/api' + p;
        return global.APP_BASE_PATH + p;
    };

    function patchApiUrl(url) {
        applyBase();
        if (!global.APP_BASE_PATH || !url || typeof url !== 'string') return url;
        if (url.startsWith(global.APP_BASE_PATH + '/api')) return url;
        if (url.startsWith('/api')) return global.APP_BASE_PATH + url;
        try {
            const u = new URL(url, global.location.origin);
            if (
                u.origin === global.location.origin &&
                u.pathname.startsWith('/api') &&
                !u.pathname.startsWith(global.APP_BASE_PATH + '/api')
            ) {
                return global.APP_BASE_PATH + u.pathname + u.search;
            }
        } catch (_) {}
        return url;
    }

    /** Prefix all /api fetch + jQuery.ajax (DataTables) when under /be. */
    function installApiTransportPatch() {
        if (!global.__fetchApiPatched) {
            global.__fetchApiPatched = true;
            const nativeFetch = global.fetch.bind(global);
            global.fetch = function (input, init) {
                if (typeof input === 'string') {
                    return nativeFetch(patchApiUrl(input), init);
                }
                if (typeof Request !== 'undefined' && input instanceof Request) {
                    const patched = patchApiUrl(input.url);
                    if (patched !== input.url) {
                        return nativeFetch(new Request(patched, input), init);
                    }
                }
                return nativeFetch(input, init);
            };
        }

        const installJquery = () => {
            if (!global.jQuery || global.__jqueryApiPatched) return !!global.__jqueryApiPatched;
            global.__jqueryApiPatched = true;
            global.jQuery.ajaxPrefilter(function (options) {
                if (options.url) options.url = patchApiUrl(options.url);
            });
            return true;
        };
        if (!installJquery()) {
            const iv = setInterval(() => {
                if (installJquery()) clearInterval(iv);
            }, 30);
            setTimeout(() => clearInterval(iv), 15000);
        }
    }

    installApiTransportPatch();

    global.adminGo = function adminGo(path) {
        global.location.href = global.adminUrl(path);
    };

    /** Fix /admin and /api hrefs in the DOM. */
    global.rewriteAdminRootLinks = function rewriteAdminRootLinks(root) {
        applyBase();
        if (!global.APP_BASE_PATH) return;
        const scope = root && root.querySelectorAll ? root : document;
        scope.querySelectorAll('a[href^="/admin"], a[href^="/api"]').forEach((el) => {
            const href = el.getAttribute('href');
            if (!href || href.startsWith(global.APP_BASE_PATH)) return;
            el.setAttribute('href', global.APP_BASE_PATH + href);
        });
    };

    /** Redirect if browser is on /admin/... but app lives under /be/admin/... */
    global.fixAdminPathIfNeeded = function fixAdminPathIfNeeded() {
        applyBase();
        if (!global.APP_BASE_PATH) return;
        const path = global.location.pathname;
        const expected = global.APP_BASE_PATH + '/admin';
        if (path.startsWith(expected)) return;
        const m = path.match(/\/admin(\/.*)?$/);
        if (!m) return;
        global.location.replace(global.APP_BASE_PATH + '/admin' + (m[1] || '/dashboard') + global.location.search);
    };

    /** Intercept clicks so /admin links keep the /be prefix. */
    global.installAdminLinkGuard = function installAdminLinkGuard() {
        if (global.__adminLinkGuard) return;
        global.__adminLinkGuard = true;
        document.addEventListener(
            'click',
            function (e) {
                const a = e.target.closest('a[href]');
                if (!a || a.target === '_blank' || e.metaKey || e.ctrlKey || e.shiftKey) return;
                const href = a.getAttribute('href');
                if (!href || href.charAt(0) !== '/' || href.startsWith('//')) return;
                if (href.startsWith('/admin')) {
                    const fixed = global.adminUrl(href);
                    if (fixed !== href) {
                        e.preventDefault();
                        global.location.href = fixed;
                    }
                } else if (href.startsWith('/api') && global.APP_BASE_PATH) {
                    const fixed = global.apiUrl(href);
                    if (fixed !== href) {
                        e.preventDefault();
                        global.location.href = fixed;
                    }
                }
            },
            true
        );
    };

    global.fixAdminPathIfNeeded();
    global.installAdminLinkGuard();

    /** Rewrite links added later (DataTables, etc.). */
    if (typeof MutationObserver !== 'undefined') {
        let t = null;
        const obs = new MutationObserver(function () {
            if (t) clearTimeout(t);
            t = setTimeout(function () {
                global.rewriteAdminRootLinks(document);
            }, 50);
        });
        function startObserver() {
            if (!document.body) return;
            obs.observe(document.body, { childList: true, subtree: true });
        }
        if (document.body) startObserver();
        else document.addEventListener('DOMContentLoaded', startObserver);
    }
})(window);
