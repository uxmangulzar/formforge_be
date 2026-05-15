/* global Swal */

const pageState = {
    subscriptionId: null,
    userId: null,
    currentPlanName: '',
    page: 1,
    limit: 20,
    action: '',
    syncPage: 1,
    syncLimit: 15
};

function authHeaders() {
    return {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + (localStorage.getItem('adminToken') || '')
    };
}

function escapeHtml(s) {
    if (s == null || s === '') return '—';
    const d = document.createElement('div');
    d.textContent = s;
    return d.innerHTML;
}

function fmtDateTime(d) {
    if (!d) return '—';
    return new Date(d).toLocaleString();
}

function fmtDate(d) {
    if (!d) return '—';
    return new Date(d).toLocaleDateString();
}

function statusTag(s) {
    const key = (s || 'active').toLowerCase();
    const cls = {
        active: 'tag-active',
        trialing: 'tag-trial',
        cancelled: 'tag-cancelled',
        expired: 'tag-expired',
        paused: 'tag-paused'
    }[key] || 'tag-expired';
    return (
        '<span class="px-3 py-1 rounded-full text-[10px] font-bold uppercase ' +
        cls +
        '">' +
        escapeHtml(key) +
        '</span>'
    );
}

function getSubscriptionIdFromPath() {
    const parts = window.location.pathname.split('/').filter(Boolean);
    const idx = parts.indexOf('user-subscriptions');
    if (idx === -1 || !parts[idx + 1]) return null;
    return parts[idx + 1];
}

function formatActionLabel(action) {
    return String(action || '')
        .replace(/_/g, ' ')
        .replace(/\b\w/g, (c) => c.toUpperCase());
}

function formatLogDetails(log) {
    const meta = log.metadata || {};
    const items = [];

    if (log.action === 'created') {
        if (meta.status) items.push({ label: 'Status', value: meta.status });
        if (meta.platform) items.push({ label: 'Platform', value: meta.platform });
        if (meta.expires_at) items.push({ label: 'Expires', value: fmtDateTime(meta.expires_at) });
    } else if (log.action === 'expiry_updated') {
        if (meta.previous_expires_at != null) {
            items.push({ label: 'Previous', value: fmtDateTime(meta.previous_expires_at) });
        }
        items.push({ label: 'New expiry', value: fmtDateTime(meta.expires_at) });
    } else if (log.action === 'deleted' && meta.snapshot) {
        const snap = meta.snapshot;
        if (snap.plan?.name) items.push({ label: 'Plan', value: snap.plan.name });
        if (snap.status) items.push({ label: 'Status', value: snap.status });
        if (snap.platform) items.push({ label: 'Platform', value: snap.platform });
        if (snap.expires_at) items.push({ label: 'Expired', value: fmtDateTime(snap.expires_at) });
    } else if (log.action === 'store_synced' && meta.updates) {
        if (meta.previous?.status && meta.updates.status && meta.previous.status !== meta.updates.status) {
            items.push({ label: 'Status', value: meta.previous.status + ' → ' + meta.updates.status });
        }
        if (meta.previous?.expires_at !== meta.updates?.expires_at) {
            items.push({
                label: 'Expires',
                value: fmtDateTime(meta.previous?.expires_at) + ' → ' + fmtDateTime(meta.updates?.expires_at)
            });
        }
        if (meta.previous?.auto_renew !== meta.updates?.auto_renew) {
            items.push({
                label: 'Auto renew',
                value: (meta.previous.auto_renew ? 'Yes' : 'No') + ' → ' + (meta.updates.auto_renew ? 'Yes' : 'No')
            });
        }
        if (meta.store?.environment) {
            items.push({ label: 'Environment', value: meta.store.environment });
        }
    } else if (log.action === 'cancelled' && meta.store) {
        if (meta.store.action === 'cancelled') items.push({ label: 'Google Play', value: 'Renewals stopped' });
        else if (meta.store.action === 'manual_required') items.push({ label: 'App Store', value: 'Manual step required' });
        else if (meta.store.error) items.push({ label: 'Store', value: meta.store.error });
        else if (meta.store.message) items.push({ label: 'Store', value: meta.store.message });
    } else if (meta.store) {
        if (meta.store.action === 'refunded') items.push({ label: 'Google Play', value: 'Refunded' });
        else if (meta.store.action === 'manual_required') items.push({ label: 'App Store', value: 'Manual step required' });
        else if (meta.store.error) items.push({ label: 'Store', value: meta.store.error });
        else if (meta.store.skipped) items.push({ label: 'Store', value: 'Skipped' });
        else items.push({ label: 'Store', value: 'Updated' });
    }

    if (!items.length && meta && Object.keys(meta).length) {
        Object.entries(meta).forEach(([key, val]) => {
            if (val != null && typeof val !== 'object') {
                items.push({ label: key.replace(/_/g, ' '), value: String(val) });
            }
        });
    }

    if (!items.length) return '<span class="text-gray-500">—</span>';

    return (
        '<ul class="log-detail-list">' +
        items
            .map(
                (item) =>
                    '<li><strong>' +
                    escapeHtml(item.label) +
                    ':</strong> ' +
                    escapeHtml(item.value) +
                    '</li>'
            )
            .join('') +
        '</ul>'
    );
}

function logSubscriptionLabel(log) {
    if (log.user_subscription_id === pageState.subscriptionId) {
        return (
            '<span class="font-semibold">' +
            escapeHtml(pageState.currentPlanName) +
            '</span> <span class="log-current-badge">current</span>'
        );
    }
    const snap = log.metadata?.snapshot;
    if (snap?.plan?.name) {
        return '<span class="text-gray-400">' + escapeHtml(snap.plan.name) + ' <span class="text-xs">(removed)</span></span>';
    }
    return '<span class="text-xs font-mono text-gray-500">' + escapeHtml(log.user_subscription_id?.slice(0, 8) || '—') + '…</span>';
}

function actionClass(action) {
    const map = {
        created: 'log-action--created',
        deleted: 'log-action--deleted',
        refunded: 'log-action--refunded',
        cancelled: 'log-action--cancelled',
        store_synced: 'log-action--created'
    };
    return map[action] || '';
}

function isStorePlatform(platform) {
    return platform === 'google_play' || platform === 'app_store';
}

function setStoreSyncConsoleSyncing(active) {
    const el = document.getElementById('storeSyncConsole');
    if (active) el.classList.add('is-syncing');
    else el.classList.remove('is-syncing');
}

function clearStoreSyncConsole() {
    const el = document.getElementById('storeSyncConsole');
    el.textContent = '';
    el.scrollTop = 0;
}

function appendStoreSyncLine(line) {
    const el = document.getElementById('storeSyncConsole');
    if (!line) return;
    if (el.textContent === 'Waiting for store sync…') {
        el.textContent = line;
    } else {
        el.textContent = (el.textContent ? el.textContent + '\n' : '') + line;
    }
    el.scrollTop = el.scrollHeight;
    console.log('[Admin Store Sync]', line);
}

function renderStoreSyncConsole(lines, isError) {
    const el = document.getElementById('storeSyncConsole');
    setStoreSyncConsoleSyncing(false);
    if (!lines || !lines.length) {
        el.textContent = isError ? 'Sync failed.' : 'No output.';
        return;
    }
    el.textContent = lines.join('\n');
    el.scrollTop = el.scrollHeight;
    lines.forEach((line) => console.log('[Admin Store Sync]', line));
}

function formatSyncType(t) {
    return String(t || 'pull').replace(/_/g, ' ');
}

function renderStoreSyncTable(rows) {
    const tbody = document.getElementById('storeSyncTableBody');
    tbody.innerHTML = rows
        .map((row) => {
            const storeCol =
                (row.store_status || '—') +
                (row.store_expires_at ? '<br><span class="text-gray-500 text-xs">exp ' + escapeHtml(fmtDateTime(row.store_expires_at)) + '</span>' : '');
            return (
                '<tr>' +
                '<td class="whitespace-nowrap">' +
                escapeHtml(fmtDateTime(row.createdAt)) +
                '</td>' +
                '<td>' +
                escapeHtml(formatSyncType(row.sync_type)) +
                '</td>' +
                '<td><span class="sync-status--' +
                escapeHtml(row.status) +
                ' font-semibold uppercase text-[10px]">' +
                escapeHtml(row.status) +
                '</span></td>' +
                '<td>' +
                storeCol +
                '</td>' +
                '<td>' +
                (row.user_updated ? '<span class="text-green-400">Updated</span>' : '—') +
                '</td>' +
                '<td>' +
                escapeHtml(row.message || row.error_detail || '—') +
                '</td>' +
                '</tr>'
            );
        })
        .join('');
}

function updateStoreSyncPagination(pagination) {
    const bar = document.getElementById('storeSyncPagination');
    const info = document.getElementById('storeSyncPageInfo');
    const prevBtn = document.getElementById('storeSyncPrevBtn');
    const nextBtn = document.getElementById('storeSyncNextBtn');

    if (!pagination || pagination.total === 0) {
        bar.classList.add('hidden');
        return;
    }

    bar.classList.remove('hidden');
    const from = (pagination.page - 1) * pagination.limit + 1;
    const to = Math.min(pagination.page * pagination.limit, pagination.total);
    info.textContent = 'Showing ' + from + '–' + to + ' of ' + pagination.total;
    prevBtn.disabled = !pagination.hasPrev;
    nextBtn.disabled = !pagination.hasNext;
}

async function loadStoreSyncs(page) {
    if (!pageState.subscriptionId) return;
    pageState.syncPage = page;

    const card = document.getElementById('storeSyncCard');
    const res = await fetch(
        '/api/admin/user-subscriptions/' +
            encodeURIComponent(pageState.subscriptionId) +
            '/store-syncs?page=' +
            page +
            '&limit=' +
            pageState.syncLimit,
        { headers: authHeaders() }
    );
    const json = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(json.message || 'Failed to load store sync history');

    const rows = json.data || [];
    if (!rows.length) {
        document.getElementById('storeSyncTableEmpty').classList.remove('hidden');
        document.getElementById('storeSyncTableWrap').classList.add('hidden');
        document.getElementById('storeSyncPagination').classList.add('hidden');
        return;
    }

    document.getElementById('storeSyncTableEmpty').classList.add('hidden');
    document.getElementById('storeSyncTableWrap').classList.remove('hidden');
    renderStoreSyncTable(rows);
    updateStoreSyncPagination(json.pagination);

    if (rows[0].console) {
        renderStoreSyncConsole(rows[0].console);
    }

    card.classList.remove('hidden');
}

function startClientSyncConsole(platform) {
    clearStoreSyncConsole();
    setStoreSyncConsoleSyncing(true);
    const label = platform === 'google_play' ? 'Google Play' : 'App Store';
    appendStoreSyncLine('[' + new Date().toLocaleTimeString('en-GB', { hour12: false }) + '] ▶ Sync requested from admin');
    appendStoreSyncLine('[' + new Date().toLocaleTimeString('en-GB', { hour12: false }) + '] Connecting to ' + label + '…');
    appendStoreSyncLine('[' + new Date().toLocaleTimeString('en-GB', { hour12: false }) + '] Waiting for server response…');
}

async function syncFromStore(platformHint) {
    const btn = document.getElementById('btnSyncStore');
    const note = document.getElementById('storeSyncNote');
    if (!pageState.subscriptionId) return null;

    const platform = platformHint || pageState.platform;
    btn.disabled = true;
    note.classList.remove('hidden');
    note.textContent = 'Syncing from store…';
    startClientSyncConsole(platform);

    const res = await fetch(
        '/api/admin/user-subscriptions/' + encodeURIComponent(pageState.subscriptionId) + '/sync-store',
        { method: 'POST', headers: authHeaders() }
    );
    const json = await res.json().catch(() => ({}));
    btn.disabled = false;
    setStoreSyncConsoleSyncing(false);

    if (!res.ok) {
        note.textContent = json.message || 'Store sync failed';
        if (json.console && json.console.length) {
            renderStoreSyncConsole(json.console, true);
        } else {
            appendStoreSyncLine('[' + new Date().toLocaleTimeString('en-GB', { hour12: false }) + '] ✗ ' + (json.message || 'Sync failed'));
        }
        throw new Error(json.message || 'Store sync failed');
    }

    note.textContent = json.message || (json.changed ? 'Updated from store.' : 'Already up to date.');
    if (json.console && json.console.length) {
        renderStoreSyncConsole(json.console);
    }
    await loadStoreSyncs(1);
    return json.data;
}

function renderLogsTable(logs) {
    const tbody = document.getElementById('logsTableBody');
    tbody.innerHTML = logs
        .map(
            (log) =>
                '<tr>' +
                '<td class="whitespace-nowrap">' +
                escapeHtml(fmtDateTime(log.createdAt)) +
                '</td>' +
                '<td><span class="log-action ' +
                actionClass(log.action) +
                '">' +
                escapeHtml(formatActionLabel(log.action)) +
                '</span></td>' +
                '<td>' +
                logSubscriptionLabel(log) +
                '</td>' +
                '<td>' +
                formatLogDetails(log) +
                '</td>' +
                '<td>' +
                escapeHtml(log.note || '—') +
                '</td>' +
                '</tr>'
        )
        .join('');
}

function updateLogsPagination(pagination) {
    const bar = document.getElementById('logsPagination');
    const info = document.getElementById('logsPageInfo');
    const prevBtn = document.getElementById('logsPrevBtn');
    const nextBtn = document.getElementById('logsNextBtn');

    if (!pagination || pagination.total === 0) {
        bar.classList.add('hidden');
        return;
    }

    bar.classList.remove('hidden');
    const from = (pagination.page - 1) * pagination.limit + 1;
    const to = Math.min(pagination.page * pagination.limit, pagination.total);
    info.textContent =
        'Showing ' +
        from +
        '–' +
        to +
        ' of ' +
        pagination.total +
        ' (page ' +
        pagination.page +
        '/' +
        pagination.totalPages +
        ')';
    prevBtn.disabled = !pagination.hasPrev;
    nextBtn.disabled = !pagination.hasNext;
}

async function loadLogs(page) {
    if (!pageState.userId) return;
    pageState.page = page;

    document.getElementById('logsLoading').classList.remove('hidden');
    document.getElementById('logsTableWrap').classList.add('hidden');
    document.getElementById('logsEmpty').classList.add('hidden');
    document.getElementById('logsPagination').classList.add('hidden');

    let url =
        '/api/admin/user-subscriptions/logs?user_id=' +
        encodeURIComponent(pageState.userId) +
        '&page=' +
        page +
        '&limit=' +
        pageState.limit;
    if (pageState.action) {
        url += '&action=' + encodeURIComponent(pageState.action);
    }

    const res = await fetch(url, { headers: authHeaders() });
    const json = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(json.message || 'Failed to load logs');

    document.getElementById('logsLoading').classList.add('hidden');
    const logs = json.data || [];

    if (!logs.length) {
        document.getElementById('logsEmpty').classList.remove('hidden');
        return;
    }

    document.getElementById('logsTableWrap').classList.remove('hidden');
    renderLogsTable(logs);
    updateLogsPagination(json.pagination);
}

function renderSubscription(sub) {
    const userName = sub.user?.full_name || sub.user?.email || 'User';
    const planName = sub.plan?.name || 'Plan';
    pageState.currentPlanName = planName;
    pageState.userId = sub.user_id;
    pageState.platform = sub.platform;

    document.getElementById('pageTitle').textContent = userName;
    document.getElementById('pageSubtitle').textContent =
        planName +
        ' · ' +
        (sub.plan?.currency || 'USD') +
        ' ' +
        (sub.plan?.price != null ? Number(sub.plan.price).toFixed(2) : '');
    document.getElementById('statusBadge').innerHTML = statusTag(sub.status);
    document.getElementById('fieldPlatform').textContent = (sub.platform || '—').replace(/_/g, ' ');
    document.getElementById('fieldStarted').textContent = fmtDateTime(sub.started_at);
    document.getElementById('fieldExpires').textContent = fmtDateTime(sub.expires_at);
    document.getElementById('fieldAutoRenew').textContent = sub.auto_renew ? 'Yes' : 'No';
    document.getElementById('fieldEmail').textContent = sub.user?.email || '—';
    document.getElementById('fieldSubId').textContent = sub.id || '—';

    const syncBtn = document.getElementById('btnSyncStore');
    const syncCard = document.getElementById('storeSyncCard');
    if (isStorePlatform(sub.platform) && sub.store_purchase_token && !sub.refunded_at) {
        syncBtn.classList.remove('hidden');
        syncCard.classList.remove('hidden');
    } else {
        syncBtn.classList.add('hidden');
        syncCard.classList.add('hidden');
    }
}

function showError(message) {
    document.getElementById('loadingState').classList.add('hidden');
    document.getElementById('contentState').classList.add('hidden');
    document.getElementById('errorState').classList.remove('hidden');
    document.getElementById('errorMessage').textContent = message;
}

async function initPage() {
    const id = getSubscriptionIdFromPath();
    if (!id) {
        showError('Invalid subscription link.');
        return;
    }
    pageState.subscriptionId = id;

    try {
        const res = await fetch('/api/admin/user-subscriptions/' + encodeURIComponent(id), {
            headers: authHeaders()
        });
        const json = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(json.message || 'Subscription not found');

        let sub = json.data;
        renderSubscription(sub);

        if (isStorePlatform(sub.platform) && sub.store_purchase_token && !sub.refunded_at) {
            document.getElementById('storeSyncCard').classList.remove('hidden');
            try {
                await loadStoreSyncs(1);
            } catch (syncHistErr) {
                console.warn('Store sync history:', syncHistErr.message);
            }
        }
        document.getElementById('loadingState').classList.add('hidden');
        document.getElementById('contentState').classList.remove('hidden');

        await loadLogs(1);
    } catch (err) {
        showError(err.message || 'Failed to load');
    }
}

document.addEventListener('DOMContentLoaded', function () {
    document.getElementById('btnSyncStore').addEventListener('click', async function () {
        try {
            const synced = await syncFromStore(pageState.platform);
            if (synced) renderSubscription(synced);
            await loadLogs(1);
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Sync failed', text: err.message });
        }
    });

    document.getElementById('storeSyncPrevBtn').addEventListener('click', async function () {
        if (pageState.syncPage <= 1) return;
        try {
            await loadStoreSyncs(pageState.syncPage - 1);
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message });
        }
    });

    document.getElementById('storeSyncNextBtn').addEventListener('click', async function () {
        try {
            await loadStoreSyncs(pageState.syncPage + 1);
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message });
        }
    });

    document.getElementById('actionFilter').addEventListener('change', async function () {
        pageState.action = this.value;
        try {
            await loadLogs(1);
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message });
        }
    });

    document.getElementById('logsPrevBtn').addEventListener('click', async function () {
        if (pageState.page <= 1) return;
        try {
            await loadLogs(pageState.page - 1);
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message });
        }
    });

    document.getElementById('logsNextBtn').addEventListener('click', async function () {
        try {
            await loadLogs(pageState.page + 1);
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message });
        }
    });

    initPage();
});
