/** Admin panel base path — keep in sync with app.use('/admin', adminRoutes) */
window.ADMIN_BASE = '/admin';

window.adminUrl = function adminUrl(path) {
    if (!path || path === '/') return window.ADMIN_BASE + '/dashboard';
    const p = path.startsWith('/') ? path : '/' + path;
    if (p.startsWith(window.ADMIN_BASE)) return p;
    return window.ADMIN_BASE + p;
};
