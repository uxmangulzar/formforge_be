/* global $, Swal */

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

function statusTag(s) {
    const key = (s || 'active').toLowerCase();
    const cls = {
        active: 'tag-active',
        trialing: 'tag-trial',
        cancelled: 'tag-cancelled',
        expired: 'tag-expired',
        paused: 'tag-paused'
    }[key] || 'tag-expired';
    return '<span class="px-3 py-1 rounded-full text-[10px] font-bold uppercase ' + cls + '">' + escapeHtml(key) + '</span>';
}

function fmtDate(d) {
    if (!d) return '—';
    return new Date(d).toLocaleDateString();
}

function userCell(row) {
    const u = row.user || {};
    const name = u.full_name || '—';
    return (
        '<div><div class="font-semibold">' +
        escapeHtml(name) +
        '</div><div class="text-xs text-gray-500">' +
        escapeHtml(u.email || '') +
        '</div></div>'
    );
}

function planCell(row) {
    const p = row.plan || {};
    return (
        '<div class="font-semibold">' +
        escapeHtml(p.name || '—') +
        '</div><div class="text-xs text-gray-500">' +
        escapeHtml((p.currency || '') + ' ' + (p.price != null ? Number(p.price).toFixed(2) : '')) +
        '</div>'
    );
}

function toDatetimeLocalValue(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (Number.isNaN(d.getTime())) return '';
    const pad = (n) => String(n).padStart(2, '0');
    return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()) + 'T' + pad(d.getHours()) + ':' + pad(d.getMinutes());
}

function subMenuHtml(row) {
    const label = (row.user?.full_name || row.user?.email || 'User') + ' — ' + (row.plan?.name || 'Plan');
    let html =
        '<a href="/admin/user-subscriptions/' +
        escapeHtml(row.id) +
        '" class="sub-menu-item sub-menu-item--log"><i class="fas fa-list"></i> View activity</a>' +
        '<button type="button" class="sub-menu-item sub-menu-item--expiry sub-menu-expiry" data-id="' +
        escapeHtml(row.id) +
        '" data-expires="' +
        escapeHtml(row.expires_at || '') +
        '"><i class="fas fa-calendar"></i> Set expiry</button>';

    if (row.status !== 'cancelled' && !row.refunded_at) {
        html +=
            '<div class="sub-menu-divider"></div>' +
            '<button type="button" class="sub-menu-item sub-menu-item--deactivate sub-menu-deactivate" data-id="' +
            escapeHtml(row.id) +
            '" data-label="' +
            escapeHtml(label) +
            '"><i class="fas fa-pause"></i> Deactivate</button>' +
            '<button type="button" class="sub-menu-item sub-menu-item--cancel sub-menu-cancel" data-id="' +
            escapeHtml(row.id) +
            '" data-platform="' +
            escapeHtml(row.platform) +
            '"><i class="fas fa-ban"></i> Cancel</button>' +
            '<button type="button" class="sub-menu-item sub-menu-item--refund sub-menu-refund" data-id="' +
            escapeHtml(row.id) +
            '" data-platform="' +
            escapeHtml(row.platform) +
            '" data-label="' +
            escapeHtml(label) +
            '"><i class="fas fa-rotate-left"></i> Refund</button>';
    }

    html +=
        '<div class="sub-menu-divider"></div>' +
        '<button type="button" class="sub-menu-item sub-menu-item--delete sub-menu-delete" data-id="' +
        escapeHtml(row.id) +
        '" data-label="' +
        escapeHtml(label) +
        '"><i class="fas fa-trash"></i> Delete record</button>';
    return html;
}

function actionsCell(row) {
    return (
        '<div class="admin-actions-wrap">' +
        '<button type="button" class="admin-actions-trigger sub-actions-trigger" aria-label="Actions"><i class="fas fa-ellipsis-vertical"></i></button>' +
        '<div class="admin-actions-menu-template" hidden>' +
        subMenuHtml(row) +
        '</div></div>'
    );
}

let listStoreSyncApplied = false;

function reloadTable() {
    if ($.fn.DataTable.isDataTable('#subsTable')) {
        $('#subsTable').DataTable().ajax.reload(null, false);
    }
}

function buildListUrl() {
    let url = '/api/admin/user-subscriptions';
    const qs = new URLSearchParams();
    if (!listStoreSyncApplied) {
        qs.set('sync_stores', '1');
        listStoreSyncApplied = true;
    }
    const userId = params.get('user_id');
    if (userId) qs.set('user_id', userId);
    const q = qs.toString();
    return q ? url + '?' + q : url;
}

function initTable() {
    if ($.fn.DataTable.isDataTable('#subsTable')) {
        $('#subsTable').DataTable().destroy();
    }

    $('#subsTable').DataTable({
        ajax: {
            url: buildListUrl(),
            headers: { Authorization: 'Bearer ' + (localStorage.getItem('adminToken') || '') },
            dataSrc: 'data',
            error: function (xhr) {
                if (xhr.status === 401) window.location.href = (typeof adminUrl === 'function' ? adminUrl('/login') : '/admin/login');
            }
        },
        columns: [
            { data: null, render: (_, __, row) => userCell(row) },
            { data: null, render: (_, __, row) => planCell(row) },
            { data: 'status', render: (d) => statusTag(d) },
            { data: 'platform', render: (d) => '<span class="text-xs uppercase">' + escapeHtml(d) + '</span>' },
            { data: 'started_at', render: (d) => fmtDate(d) },
            { data: 'expires_at', render: (d) => fmtDate(d) },
            { data: null, orderable: false, render: (_, __, row) => actionsCell(row) }
        ],
        order: [[4, 'desc']],
        pageLength: 10,
        language: {
            searchPlaceholder: 'Search user, email, plan...',
            emptyTable: 'No user subscriptions yet. Assign a plan or sync from the app when billing is live.'
        }
    });
}

async function loadAssignOptions() {
    const [usersRes, plansRes] = await Promise.all([
        fetch('/api/admin/users', { headers: authHeaders() }),
        fetch('/api/admin/subscription-plans', { headers: authHeaders() })
    ]);
    const usersJson = await usersRes.json().catch(() => ({}));
    const plansJson = await plansRes.json().catch(() => ({}));

    const userSel = document.getElementById('assign_user_id');
    const planSel = document.getElementById('assign_plan_id');
    userSel.innerHTML = '';
    planSel.innerHTML = '';

    (usersJson.data || []).forEach((u) => {
        const name = u.profile?.full_name || u.email;
        const opt = document.createElement('option');
        opt.value = u.id;
        opt.textContent = name + ' (' + u.email + ')';
        userSel.appendChild(opt);
    });

    (plansJson.data || []).forEach((p) => {
        const opt = document.createElement('option');
        opt.value = p.id;
        opt.textContent = p.name + ' — ' + (p.currency || 'USD') + ' ' + Number(p.price).toFixed(2);
        planSel.appendChild(opt);
    });
}

function bindEvents() {
    document.getElementById('btnAssign').addEventListener('click', async () => {
        await loadAssignOptions();
        document.getElementById('assignModal').classList.add('is-open');
    });
    document.getElementById('assignCancel').addEventListener('click', () => {
        document.getElementById('assignModal').classList.remove('is-open');
    });
    document.getElementById('expiryCancel').addEventListener('click', () => {
        document.getElementById('expiryModal').classList.remove('is-open');
    });
    document.getElementById('assignForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const payload = {
            user_id: document.getElementById('assign_user_id').value,
            subscription_plan_id: document.getElementById('assign_plan_id').value,
            status: document.getElementById('assign_status').value,
            platform: document.getElementById('assign_platform').value
        };
        const exp = document.getElementById('assign_expires_at').value;
        if (exp) payload.expires_at = new Date(exp).toISOString();
        const token = document.getElementById('assign_purchase_token').value.trim();
        if (token) payload.store_purchase_token = token;

        try {
            const res = await fetch('/api/admin/user-subscriptions', {
                method: 'POST',
                headers: authHeaders(),
                body: JSON.stringify(payload)
            });
            const json = await res.json().catch(() => ({}));
            if (!res.ok) throw new Error(json.message || 'Failed');
            document.getElementById('assignModal').classList.remove('is-open');
            reloadTable();
            Swal.fire({ icon: 'success', title: 'Assigned', timer: 1200, showConfirmButton: false });
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message });
        }
    });

    document.getElementById('expiryForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const id = document.getElementById('expiry_sub_id').value;
        const val = document.getElementById('expiry_date').value;
        const body = { expires_at: val ? new Date(val).toISOString() : null };
        try {
            const res = await fetch('/api/admin/user-subscriptions/' + id + '/expiry', {
                method: 'PATCH',
                headers: authHeaders(),
                body: JSON.stringify(body)
            });
            const json = await res.json().catch(() => ({}));
            if (!res.ok) throw new Error(json.message || 'Failed');
            document.getElementById('expiryModal').classList.remove('is-open');
            reloadTable();
            Swal.fire({ icon: 'success', title: 'Expiry updated', timer: 1200, showConfirmButton: false });
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message });
        }
    });

    $('#subsTable').on('click', '.sub-actions-trigger', function (e) {
        e.stopPropagation();
        if (window.AdminActionsMenu) window.AdminActionsMenu.openFromWrap(this);
    });

    $(document).on('click', '#admin-actions-portal .sub-menu-expiry', function () {
        if (window.AdminActionsMenu) window.AdminActionsMenu.close();
        document.getElementById('expiry_sub_id').value = $(this).data('id');
        document.getElementById('expiry_date').value = toDatetimeLocalValue($(this).data('expires'));
        document.getElementById('expiryModal').classList.add('is-open');
    });

    $(document).on('click', '#admin-actions-portal .sub-menu-deactivate', async function () {
        if (window.AdminActionsMenu) window.AdminActionsMenu.close();
        const id = $(this).data('id');
        const label = $(this).data('label');
        const ok = await Swal.fire({
            icon: 'warning',
            title: 'Deactivate subscription?',
            html: '<p>Pauses access. For Google Play, revokes on store if purchase token is set.</p><p class="text-sm mt-2"><strong>' + escapeHtml(label) + '</strong></p>',
            showCancelButton: true,
            confirmButtonText: 'Deactivate'
        });
        if (!ok.isConfirmed) return;
        try {
            const res = await fetch('/api/admin/user-subscriptions/' + id + '/deactivate', {
                method: 'PATCH',
                headers: authHeaders(),
                body: JSON.stringify({})
            });
            const json = await res.json().catch(() => ({}));
            if (!res.ok) throw new Error(json.message || 'Failed');
            reloadTable();
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message });
        }
    });

    $(document).on('click', '#admin-actions-portal .sub-menu-cancel', async function () {
        if (window.AdminActionsMenu) window.AdminActionsMenu.close();
        const id = $(this).data('id');
        const platform = $(this).data('platform');
        const storeNote =
            platform === 'google_play'
                ? '<p class="text-xs text-gray-400 mt-2">Stops renewals on Google Play (access until expiry). Requires purchase token.</p>'
                : platform === 'app_store'
                  ? '<p class="text-xs text-gray-400 mt-2">Updates database. Apple renewals must be stopped in App Store Connect or by the user in iOS Settings.</p>'
                  : '';
        const ok = await Swal.fire({
            icon: 'warning',
            title: 'Cancel subscription?',
            html: '<p>Marks cancelled in database and updates the store when possible.</p>' + storeNote,
            showCancelButton: true,
            confirmButtonColor: '#ef4444'
        });
        if (!ok.isConfirmed) return;
        try {
            const res = await fetch('/api/admin/user-subscriptions/' + id + '/cancel', {
                method: 'PATCH',
                headers: authHeaders()
            });
            const json = await res.json().catch(() => ({}));
            if (!res.ok) throw new Error(json.message || 'Failed');
            let msg = json.message || 'Cancelled';
            if (json.store?.error) msg += '\n\nStore: ' + json.store.error;
            if (json.store?.message) msg += '\n\n' + json.store.message;
            await Swal.fire({ icon: 'success', title: 'Done', text: msg });
            reloadTable();
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message });
        }
    });

    $(document).on('click', '#admin-actions-portal .sub-menu-refund', async function () {
        if (window.AdminActionsMenu) window.AdminActionsMenu.close();
        const id = $(this).data('id');
        const label = $(this).data('label');
        const platform = $(this).data('platform');
        const storeNote =
            platform === 'google_play'
                ? '<p class="text-xs text-gray-400 mt-2">Refunds on Google Play when purchase token is saved.</p>'
                : platform === 'app_store'
                  ? '<p class="text-xs text-gray-400 mt-2">Updates database. Apple refunds must be issued in App Store Connect (no server refund API).</p>'
                  : '';
        const ok = await Swal.fire({
            icon: 'warning',
            title: 'Refund subscription?',
            html:
                '<p>Marks refunded in database and updates the store when possible.</p>' +
                storeNote +
                '<p class="text-sm mt-2"><strong>' +
                escapeHtml(label) +
                '</strong></p>',
            showCancelButton: true,
            confirmButtonText: 'Refund',
            confirmButtonColor: '#a78bfa'
        });
        if (!ok.isConfirmed) return;
        try {
            const res = await fetch('/api/admin/user-subscriptions/' + id + '/refund', {
                method: 'POST',
                headers: authHeaders(),
                body: JSON.stringify({})
            });
            const json = await res.json().catch(() => ({}));
            if (!res.ok) throw new Error(json.message || 'Failed');
            let msg = json.message || 'Refunded';
            if (json.store?.error) msg += '\n\nStore: ' + json.store.error;
            if (json.store?.message) msg += '\n\n' + json.store.message;
            await Swal.fire({ icon: 'success', title: 'Done', text: msg });
            reloadTable();
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message });
        }
    });

    $(document).on('click', '#admin-actions-portal .sub-menu-delete', async function () {
        if (window.AdminActionsMenu) window.AdminActionsMenu.close();
        const id = $(this).data('id');
        const label = $(this).data('label');
        const ok = await Swal.fire({
            icon: 'warning',
            title: 'Delete subscription record?',
            html: '<p>Removes from database. Log entry is kept.</p><p class="text-sm mt-2"><strong>' + escapeHtml(label) + '</strong></p>',
            showCancelButton: true,
            confirmButtonText: 'Delete',
            confirmButtonColor: '#ef4444'
        });
        if (!ok.isConfirmed) return;
        try {
            const res = await fetch('/api/admin/user-subscriptions/' + id, {
                method: 'DELETE',
                headers: authHeaders()
            });
            const json = await res.json().catch(() => ({}));
            if (!res.ok) throw new Error(json.message || 'Failed');
            reloadTable();
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message });
        }
    });
}

const params = new URLSearchParams(window.location.search);
$(document).ready(function () {
    initTable();
    bindEvents();
    if (params.get('user_id')) {
        loadAssignOptions().then(() => {
            document.getElementById('assign_user_id').value = params.get('user_id');
            document.getElementById('assignModal').classList.add('is-open');
        });
    }
});
