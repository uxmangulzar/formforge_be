/**
 * Detect app base when admin is served under a subpath (e.g. /be/admin on repvio.fit).
 * Local dev: /admin/... → APP_BASE_PATH = ''
 * Production: /be/admin/... → APP_BASE_PATH = '/be'
 */
(function (global) {
    function detectAppBase() {
        if (typeof global.__APP_BASE_PATH__ === 'string') {
            return global.__APP_BASE_PATH__;
        }
        const path = global.location.pathname;
        const idx = path.indexOf('/admin');
        if (idx >= 0) return path.slice(0, idx);
        return '';
    }

    const APP_BASE = detectAppBase();
    global.APP_BASE_PATH = APP_BASE;
    global.ADMIN_BASE = APP_BASE + '/admin';

    global.adminUrl = function adminUrl(path) {
        if (!path || path === '/') return global.ADMIN_BASE + '/dashboard';
        let p = path.startsWith('/') ? path : '/' + path;
        if (p.startsWith('/admin')) return global.APP_BASE_PATH + p;
        if (p.startsWith(global.ADMIN_BASE)) return p;
        return global.ADMIN_BASE + p;
    };

    /** Prefix /admin and /api links in the DOM when deployed under a subpath. */
    global.rewriteAdminRootLinks = function rewriteAdminRootLinks(root) {
        if (!global.APP_BASE_PATH) return;
        const scope = root && root.querySelectorAll ? root : document;
        scope.querySelectorAll('a[href^="/admin"], a[href^="/api"]').forEach((el) => {
            const href = el.getAttribute('href');
            if (!href || href.startsWith(global.APP_BASE_PATH)) return;
            el.setAttribute('href', global.APP_BASE_PATH + href);
        });
    };
})(window);
