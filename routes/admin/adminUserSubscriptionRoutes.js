const express = require('express');
const router = express.Router();
const { protectAdmin } = require('../../middleware/adminAuth');
const {
    getAdminUserSubscriptions,
    getAdminUserSubscriptionById,
    getAdminSubscriptionLogs,
    getAdminSubscriptionLogsById,
    createAdminUserSubscription,
    updateAdminUserSubscriptionExpiry,
    deactivateAdminUserSubscription,
    cancelAdminUserSubscription,
    refundAdminUserSubscription,
    deleteAdminUserSubscription,
    syncAdminUserSubscriptionFromStore,
    getAdminUserSubscriptionStoreSyncs
} = require('../../controllers/admin/adminUserSubscriptionController');

router.use(protectAdmin);

router.get('/logs', getAdminSubscriptionLogs);
router.get('/', getAdminUserSubscriptions);
router.post('/', createAdminUserSubscription);
router.get('/:id/logs', getAdminSubscriptionLogsById);
router.get('/:id/store-syncs', getAdminUserSubscriptionStoreSyncs);
router.get('/:id', getAdminUserSubscriptionById);
router.post('/:id/sync-store', syncAdminUserSubscriptionFromStore);
router.patch('/:id/expiry', updateAdminUserSubscriptionExpiry);
router.patch('/:id/deactivate', deactivateAdminUserSubscription);
router.patch('/:id/cancel', cancelAdminUserSubscription);
router.post('/:id/refund', refundAdminUserSubscription);
router.delete('/:id', deleteAdminUserSubscription);

module.exports = router;
