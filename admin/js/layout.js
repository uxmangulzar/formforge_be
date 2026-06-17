/**
 * Layout Loader for Repvio Admin Panel
 * Injects sidebar and header into pages.
 * Requires admin-paths.js loaded first (sets APP_BASE_PATH / ADMIN_BASE).
 */

const ADMIN_BASE = window.ADMIN_BASE || '/admin';
const APP_BASE_PATH = window.APP_BASE_PATH || '';

// Global Auth Guard & Theme Initialization
const initTheme = () => {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
};
initTheme();

const isAdminLoginPage =
    window.location.pathname === ADMIN_BASE + '/login' ||
    window.location.pathname.endsWith('/admin/login');
if (!localStorage.getItem('adminToken') && !isAdminLoginPage) {
    window.location.href = typeof adminUrl === 'function' ? adminUrl('/login') : ADMIN_BASE + '/login';
}

const MOBILE_NAV_MQ = window.matchMedia('(max-width: 1023px)');

function isMobileNav() {
    return MOBILE_NAV_MQ.matches;
}

function closeMobileSidebar() {
    document.body.classList.remove('sidebar-mobile-open');
    const btn = document.getElementById('mobile-menu-btn');
    if (btn) btn.setAttribute('aria-expanded', 'false');
}

function openMobileSidebar() {
    document.body.classList.add('sidebar-mobile-open');
    const btn = document.getElementById('mobile-menu-btn');
    if (btn) btn.setAttribute('aria-expanded', 'true');
}

function toggleMobileSidebar() {
    if (document.body.classList.contains('sidebar-mobile-open')) {
        closeMobileSidebar();
    } else {
        openMobileSidebar();
    }
}

window.toggleMobileSidebar = toggleMobileSidebar;
window.closeMobileSidebar = closeMobileSidebar;
window.openMobileSidebar = openMobileSidebar;

/** One delegated handler — works after header is injected; avoids double-toggle */
function setupMobileMenuDelegation() {
    if (window.__mobileMenuDelegation) return;
    window.__mobileMenuDelegation = true;
    document.addEventListener(
        'click',
        function (e) {
            const menuBtn = e.target.closest('#mobile-menu-btn');
            if (!menuBtn || !isMobileNav()) return;
            e.preventDefault();
            e.stopPropagation();
            toggleMobileSidebar();
        },
        true
    );
}
setupMobileMenuDelegation();

function initMobileNav() {
    if (isAdminLoginPage) return;

    document.body.classList.add('admin-layout');

    if (!document.getElementById('sidebar-overlay')) {
        const overlay = document.createElement('div');
        overlay.id = 'sidebar-overlay';
        overlay.setAttribute('aria-hidden', 'true');
        overlay.addEventListener('click', closeMobileSidebar);
        document.body.appendChild(overlay);
    }

    const nav = document.getElementById('admin-nav');
    if (nav && !nav.dataset.mobileBound) {
        nav.dataset.mobileBound = '1';
        nav.querySelectorAll('a.nav-item').forEach((link) => {
            link.addEventListener('click', () => {
                if (isMobileNav()) closeMobileSidebar();
            });
        });
    }

    if (!window.__adminMobileResizeBound) {
        window.__adminMobileResizeBound = true;
        MOBILE_NAV_MQ.addEventListener('change', () => {
            if (!isMobileNav()) {
                closeMobileSidebar();
                const sidebar = document.getElementById('admin-sidebar');
                if (sidebar) sidebar.classList.remove('sidebar-collapsed');
            }
        });
    }

    wrapDataTablesForScroll();
    setTimeout(wrapDataTablesForScroll, 600);
    setTimeout(wrapDataTablesForScroll, 2000);
}

window.wrapAdminTables = wrapDataTablesForScroll;

function wrapDataTablesForScroll() {
    document.querySelectorAll('.dataTables_wrapper').forEach((wrapper) => {
        const table = wrapper.querySelector('table');
        if (
            table?.dataset?.noScrollWrap === 'true' ||
            wrapper.closest('[data-no-table-scroll]')
        ) {
            return;
        }
        if (wrapper.parentElement && wrapper.parentElement.classList.contains('admin-table-scroll')) {
            return;
        }
        const scroll = document.createElement('div');
        scroll.className = 'admin-table-scroll';
        wrapper.parentNode.insertBefore(scroll, wrapper);
        scroll.appendChild(wrapper);
    });
}

async function loadLayout() {
    try {
        // 0. Inject Theme CSS
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = APP_BASE_PATH + '/css/style.css';
        document.head.appendChild(link);

        // 1. Load Sidebar
        const sidebarRes = await fetch(APP_BASE_PATH + '/views/layouts/sidebar.html');
        const sidebarHtml = await sidebarRes.text();
        const sidebarContainer = document.getElementById('sidebar-container');
        if (sidebarContainer) {
            sidebarContainer.innerHTML = sidebarHtml;
            if (typeof rewriteAdminRootLinks === 'function') rewriteAdminRootLinks(sidebarContainer);
            highlightActiveNav();
            applySidebarState();
            initMobileNav();
        }

        // 2. Load Header
        const headerRes = await fetch(APP_BASE_PATH + '/views/layouts/header.html');
        const headerHtml = await headerRes.text();
        const headerContainer = document.getElementById('header-container');
        if (headerContainer) {
            headerContainer.innerHTML = headerHtml;
            setPageTitles();
            injectThemeToggle();
            initAdminNotifications();
        }

        // 3. Set Admin Name if available
        const adminUser = JSON.parse(localStorage.getItem('adminUser'));
        if (adminUser) {
            const userName = adminUser.email.split('@')[0];
            if (document.getElementById('admin-name')) {
                document.getElementById('admin-name').innerText = userName;
            }
            if (document.getElementById('header-user-name')) {
                document.getElementById('header-user-name').innerText = userName.charAt(0).toUpperCase() + userName.slice(1);
            }
            if (document.getElementById('user-initials')) {
                document.getElementById('user-initials').innerText = userName.substring(0, 2).toUpperCase();
            }
        }

    } catch (error) {
        console.error('Error loading layout components:', error);
    }
}

function toggleUserDropdown() {
    const dropdown = document.getElementById('user-dropdown');
    dropdown.classList.toggle('hidden');
}

function toggleSidebar() {
    if (isMobileNav()) {
        toggleMobileSidebar();
        return;
    }
    const sidebar = document.getElementById('admin-sidebar');
    if (!sidebar) return;
    sidebar.classList.toggle('sidebar-collapsed');
    const isCollapsed = sidebar.classList.contains('sidebar-collapsed');
    localStorage.setItem('sidebarCollapsed', isCollapsed);
}

// Apply sidebar state on load
function applySidebarState() {
    const sidebar = document.getElementById('admin-sidebar');
    if (!sidebar) return;
    if (isMobileNav()) {
        sidebar.classList.remove('sidebar-collapsed');
        return;
    }
    const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
    if (isCollapsed) {
        sidebar.classList.add('sidebar-collapsed');
    }
}

// Close dropdowns / mobile sidebar when clicking outside (bubble phase, after menu capture handler)
window.addEventListener('click', function (e) {
    if (e.target.closest('#mobile-menu-btn')) return;

    const userDd = document.getElementById('user-dropdown');
    const userBtn = document.getElementById('header-user-menu-btn');
    if (userDd && userBtn && !userDd.contains(e.target) && !userBtn.contains(e.target)) {
        userDd.classList.add('hidden');
    }

    const notifPanel = document.getElementById('notifications-panel');
    const notifBtn = document.getElementById('notifications-btn');
    if (notifPanel && notifBtn && !notifPanel.contains(e.target) && !notifBtn.contains(e.target)) {
        notifPanel.classList.add('hidden');
    }

    const menuBtn = document.getElementById('mobile-menu-btn');
    const sidebar = document.getElementById('admin-sidebar');
    if (
        document.body.classList.contains('sidebar-mobile-open') &&
        sidebar &&
        !sidebar.contains(e.target) &&
        menuBtn &&
        !menuBtn.contains(e.target)
    ) {
        closeMobileSidebar();
    }
});

function highlightActiveNav() {
    const currentPath = window.location.pathname;
    const navItems = document.querySelectorAll('.nav-item');
    
    navItems.forEach(item => {
        const link = item.getAttribute('href');
        if (currentPath.includes(link) && link !== '#') {
            item.classList.add('nav-active');
        } else {
            item.classList.remove('nav-active');
        }
    });
}

function setPageTitles() {
    const titleEl = document.getElementById('page-title');
    const subtitleEl = document.getElementById('page-subtitle');
    const path = window.location.pathname;

    if (path.includes('dashboard')) {
        titleEl.innerText = 'Dashboard Overview';
        subtitleEl.innerText = "Welcome back, here's what's happening today.";
    } else if (path.includes('exercise-categories')) {
        titleEl.innerText = 'Exercise categories';
        subtitleEl.innerText = 'Slugs for API filters and the exercise form dropdown.';
    } else if (path.includes('exercises')) {
        titleEl.innerText = 'Exercise Library';
        subtitleEl.innerText = 'Manage your AI-powered movement library.';
    } else if (path.includes('challenges/view')) {
        titleEl.innerText = 'Challenge details';
        subtitleEl.innerText = 'Overview of stages and exercises.';
    } else if (path.includes('challenges/edit')) {
        titleEl.innerText = 'Edit challenge';
        subtitleEl.innerText = 'Update schedule, stages, and exercises.';
    } else if (path.includes('challenges/add')) {
        titleEl.innerText = 'Create Challenge';
        subtitleEl.innerText = 'Define schedule, stages, and linked exercises.';
    } else if (path.includes('challenges')) {
        titleEl.innerText = 'Challenges';
        subtitleEl.innerText = 'Multi-stage programs, dates, and progress.';
    } else if (path.includes('/training-modes/view')) {
        titleEl.innerText = 'Training mode details';
        subtitleEl.innerText = 'Read-only overview of this mode.';
    } else if (path.includes('/training-modes/edit')) {
        titleEl.innerText = 'Edit training mode';
        subtitleEl.innerText = 'Update slug, labels, and visibility.';
    } else if (path.includes('/training-modes/add')) {
        titleEl.innerText = 'Add training mode';
        subtitleEl.innerText = 'Create a new experience mode row.';
    } else if (path.includes('training-modes')) {
        titleEl.innerText = 'Training modes';
        subtitleEl.innerText = 'Training, rehab, and gaming experience modes.';
    } else if (/\/user-subscriptions\/[^/]+/.test(path)) {
        titleEl.innerText = 'Subscription activity';
        subtitleEl.innerText = 'Plan details and full audit history for this user.';
    } else if (path.includes('user-subscriptions')) {
        titleEl.innerText = 'User subscriptions';
        subtitleEl.innerText = 'See which user is on which plan.';
    } else if (path.includes('subscription-plans/add')) {
        titleEl.innerText = 'Create subscription plan';
        subtitleEl.innerText = 'Manual store IDs or auto-create on Google Play / App Store.';
    } else if (path.includes('subscription-plans/edit')) {
        titleEl.innerText = 'Edit subscription plan';
        subtitleEl.innerText = 'Update plan details and store product IDs.';
    } else if (path.includes('subscription-plans')) {
        titleEl.innerText = 'Subscription plans';
        subtitleEl.innerText = 'Manage pricing, trials, and store product IDs.';
    } else if (path.includes('settings')) {
        titleEl.innerText = 'App settings';
        subtitleEl.innerText = 'Key–value configuration (no delete; toggle active as needed).';
    } else if (path.includes('leaderboards')) {
        titleEl.innerText = 'Leaderboards';
        subtitleEl.innerText = 'App users by challenge points and waitlist referral ranks.';
    } else if (path.includes('users')) {
        titleEl.innerText = 'User Management';
        subtitleEl.innerText = 'Manage registered athletes and their access.';
    }
}

function injectThemeToggle() {
    const headerActions = document.getElementById('header-actions');
    if (headerActions && !document.getElementById('theme-toggle')) {
        const toggleBtn = document.createElement('button');
        toggleBtn.id = 'theme-toggle';
        toggleBtn.className = 'transition-all';
        const currentTheme = document.documentElement.getAttribute('data-theme');
        toggleBtn.innerHTML = currentTheme === 'dark' ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';
        toggleBtn.onclick = toggleTheme;
        
        // Insert before user profile
        headerActions.insertBefore(toggleBtn, headerActions.lastElementChild);
    }
}

async function initAdminNotifications() {
    if (isAdminLoginPage) return;
    const btn = document.getElementById('notifications-btn');
    const panel = document.getElementById('notifications-panel');
    const list = document.getElementById('notifications-list');
    const badge = document.getElementById('notifications-badge');
    const markAllBtn = document.getElementById('notifications-mark-all');
    if (!btn || !panel || !list || !badge || !markAllBtn) return;

    function escapeHtml(s) {
        if (s == null) return '';
        const d = document.createElement('div');
        d.textContent = s;
        return d.innerHTML;
    }

    function safeAdminPath(p) {
        if (typeof p !== 'string') return null;
        const t = p.trim();
        if (!t.startsWith('/') || t.startsWith('//') || t.startsWith('/api')) return null;
        if (t.startsWith(ADMIN_BASE)) return t;
        return ADMIN_BASE + (t === '/' ? '/dashboard' : t);
    }

    async function loadNotifications() {
        const token = localStorage.getItem('adminToken');
        if (!token) return;
        try {
            const res = await fetch(APP_BASE_PATH + '/api/admin/notifications?limit=40', {
                headers: { Authorization: 'Bearer ' + token }
            });
            const json = await res.json().catch(() => ({}));
            if (!res.ok) {
                list.innerHTML =
                    '<p class="notifications-panel-empty notifications-panel-error">' +
                    escapeHtml(json.message || 'Could not load notifications') +
                    '</p>';
                markAllBtn.disabled = true;
                return;
            }
            if (json.settings && json.settings.in_app_enabled === false) {
                markAllBtn.disabled = true;
                badge.classList.add('hidden');
                list.innerHTML =
                    '<p class="notifications-panel-empty">In-app notifications are off. Enable them under <a href="' +
                    ADMIN_BASE +
                    '/settings" class="notif-item-link">Settings → Notification preferences</a>.</p>';
                return;
            }
            const unread = json.unread_count ?? 0;
            if (unread > 0) {
                badge.textContent = unread > 99 ? '99+' : String(unread);
                badge.classList.remove('hidden');
            } else {
                badge.classList.add('hidden');
            }
            markAllBtn.disabled = unread === 0;

            const items = json.data || [];
            if (!items.length) {
                list.innerHTML =
                    '<p class="notifications-panel-empty">No notifications to show. Adjust type filters on <a href="' +
                    ADMIN_BASE +
                    '/settings" class="notif-item-link">Settings</a> if needed.</p>';
                return;
            }
            list.innerHTML = items
                .map((n) => {
                    const unreadCls = !n.read_at ? 'notif-item--unread' : '';
                    const path = n.metadata && safeAdminPath(n.metadata.path);
                    const link = path
                        ? '<a href="' +
                          escapeHtml(path) +
                          '" class="notif-item-link">Open</a>'
                        : '';
                    const dateStr = n.createdAt ? new Date(n.createdAt).toLocaleString() : '';
                    const markBtn = !n.read_at
                        ? '<button type="button" class="notif-item-mark" data-notif-mark-read="' +
                          escapeHtml(n.id) +
                          '">Mark read</button>'
                        : '';
                    return (
                        '<div class="notif-item ' +
                        unreadCls +
                        '">' +
                        '<div class="notif-item-type">' +
                        escapeHtml(n.type) +
                        '</div>' +
                        '<div class="notif-item-title">' +
                        escapeHtml(n.title) +
                        '</div>' +
                        (n.body ? '<div class="notif-item-body">' + escapeHtml(n.body) + '</div>' : '') +
                        link +
                        markBtn +
                        '<div class="notif-item-meta">' +
                        escapeHtml(dateStr) +
                        '</div>' +
                        '</div>'
                    );
                })
                .join('');
        } catch {
            list.innerHTML =
                '<p class="notifications-panel-empty notifications-panel-error">Network error.</p>';
            markAllBtn.disabled = true;
        }
    }

    panel.addEventListener('click', async (ev) => {
        const markAll = ev.target.closest('#notifications-mark-all');
        const markOne = ev.target.closest('[data-notif-mark-read]');
        if (!markAll && !markOne) return;
        ev.preventDefault();
        ev.stopPropagation();
        const token = localStorage.getItem('adminToken');
        if (!token) return;
        try {
            if (markAll && !markAll.disabled) {
                const res = await fetch(APP_BASE_PATH + '/api/admin/notifications/read-all', {
                    method: 'POST',
                    headers: { Authorization: 'Bearer ' + token }
                });
                const json = await res.json().catch(() => ({}));
                if (!res.ok) throw new Error(json.message || 'Failed to mark all read');
                await loadNotifications();
                return;
            }
            if (markOne) {
                const id = markOne.getAttribute('data-notif-mark-read');
                const res = await fetch(
                    APP_BASE_PATH + '/api/admin/notifications/' + encodeURIComponent(id) + '/read',
                    {
                        method: 'PATCH',
                        headers: { Authorization: 'Bearer ' + token }
                    }
                );
                const json = await res.json().catch(() => ({}));
                if (!res.ok) throw new Error(json.message || 'Failed to mark read');
                await loadNotifications();
            }
        } catch (e) {
            console.error(e);
        }
    });

    btn.addEventListener('click', async (ev) => {
        ev.stopPropagation();
        const wasHidden = panel.classList.contains('hidden');
        const userDd = document.getElementById('user-dropdown');
        if (userDd) userDd.classList.add('hidden');
        panel.classList.toggle('hidden');
        if (wasHidden) await loadNotifications();
    });

    await loadNotifications();
}

function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    
    const toggleBtn = document.getElementById('theme-toggle');
    if (toggleBtn) {
        toggleBtn.innerHTML = newTheme === 'dark' ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';
    }
}

async function logout() {
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminUser');
    window.location.href = typeof adminUrl === 'function' ? adminUrl('/login') : ADMIN_BASE + '/login';
}

// Rewrite static /admin links on page (tables, buttons, etc.)
function runWhenDomReady(fn) {
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', fn);
    } else {
        fn();
    }
}

if (typeof rewriteAdminRootLinks === 'function') {
    runWhenDomReady(() => rewriteAdminRootLinks(document));
    runWhenDomReady(() => {
        if (typeof fixAdminPathIfNeeded === 'function') fixAdminPathIfNeeded();
    });
}

// Initialize on load (layout.js may load after DOMContentLoaded when scripts are injected async)
runWhenDomReady(loadLayout);
