const express = require('express');
const router = express.Router();
const { protectAdmin } = require('../../middleware/adminAuth');
const {
    getAdminSubscriptionPlans,
    getAdminSubscriptionPlanById,
    getAdminStoreProvisioningStatus,
    verifyAdminSubscriptionPlanOnGooglePlay,
    verifyAdminSubscriptionPlanOnAppStore,
    completeAdminSubscriptionPlanAppStoreMetadata,
    activateAdminSubscriptionPlanOnGooglePlay,
    createAdminSubscriptionPlan,
    updateAdminSubscriptionPlan,
    deleteAdminSubscriptionPlan
} = require('../../controllers/admin/adminSubscriptionPlanController');

router.use(protectAdmin);

router.get('/store-status', getAdminStoreProvisioningStatus);
router.get('/', getAdminSubscriptionPlans);
router.post('/', createAdminSubscriptionPlan);
router.get('/:id/verify-google-play', verifyAdminSubscriptionPlanOnGooglePlay);
router.get('/:id/verify-app-store', verifyAdminSubscriptionPlanOnAppStore);
router.post('/:id/complete-app-store-metadata', completeAdminSubscriptionPlanAppStoreMetadata);
router.post('/:id/activate-google-play', activateAdminSubscriptionPlanOnGooglePlay);
router.get('/:id', getAdminSubscriptionPlanById);
router.put('/:id', updateAdminSubscriptionPlan);
router.delete('/:id', deleteAdminSubscriptionPlan);

module.exports = router;
