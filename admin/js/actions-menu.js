/**
 * Floating action menu (appended to body) — avoids table overflow clipping.
 */
(function (global) {
    const PORTAL_ID = 'admin-actions-portal';

    function getPortal() {
        let el = document.getElementById(PORTAL_ID);
        if (!el) {
            el = document.createElement('div');
            el.id = PORTAL_ID;
            el.className = 'admin-actions-portal';
            el.setAttribute('role', 'menu');
            document.body.appendChild(el);
        }
        return el;
    }

    function close() {
        const el = document.getElementById(PORTAL_ID);
        if (el) {
            el.innerHTML = '';
            el.style.display = 'none';
            el.removeAttribute('data-trigger-id');
        }
        document.querySelectorAll('.admin-actions-trigger.is-open').forEach((b) => {
            b.classList.remove('is-open');
        });
    }

    function positionPortal(trigger, portal) {
        portal.style.display = 'block';
        portal.style.visibility = 'hidden';
        const menuW = portal.offsetWidth || 210;
        const menuH = portal.offsetHeight || 200;
        portal.style.visibility = '';

        const rect = trigger.getBoundingClientRect();
        const pad = 8;
        let left = rect.right - menuW;
        let top = rect.bottom + 6;

        if (left < pad) left = pad;
        if (left + menuW > window.innerWidth - pad) {
            left = window.innerWidth - menuW - pad;
        }

        const spaceBelow = window.innerHeight - rect.bottom;
        if (spaceBelow < menuH + 12 && rect.top > menuH + 12) {
            top = rect.top - menuH - 6;
        }
        if (top < pad) top = pad;

        portal.style.left = left + 'px';
        portal.style.top = top + 'px';
    }

    function open(trigger, html) {
        if (!trigger || !html) return;
        close();

        const portal = getPortal();
        portal.innerHTML = html;
        trigger.classList.add('is-open');
        portal.setAttribute('data-trigger-id', trigger.id || '');

        requestAnimationFrame(() => {
            positionPortal(trigger, portal);
        });
    }

    function openFromWrap(trigger) {
        const wrap = trigger.closest('.admin-actions-wrap, .plan-actions-wrap, .sub-actions-wrap');
        if (!wrap) return;
        const template = wrap.querySelector('.admin-actions-menu-template');
        if (!template) return;
        open(trigger, template.innerHTML);
    }

    if (!global.AdminActionsMenu) {
        global.AdminActionsMenu = { open, openFromWrap, close };
    }

    document.addEventListener('click', (e) => {
        const portal = document.getElementById(PORTAL_ID);
        if (!portal || portal.style.display === 'none') return;
        if (portal.contains(e.target)) return;
        if (e.target.closest('.admin-actions-trigger')) return;
        close();
    });

    window.addEventListener('resize', close);
    window.addEventListener('scroll', close, true);
})(window);
