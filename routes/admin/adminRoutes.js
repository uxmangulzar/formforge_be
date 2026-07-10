const express = require('express');
const router = express.Router();
const adminViewController = require('../../controllers/admin/adminViewController');

// Admin Panel Routes
router.get('/dashboard', adminViewController.getDashboard);
router.get('/exercises', adminViewController.getExercisePage);
router.get('/exercise-categories/view/:id', adminViewController.getViewExerciseCategoryPage);
router.get('/exercise-categories/edit/:id', adminViewController.getEditExerciseCategoryPage);
router.get('/exercise-categories', adminViewController.getExerciseCategoriesPage);
router.get('/challenges/add', adminViewController.getAddChallengePage);
router.get('/challenges/view/:id', adminViewController.getViewChallengePage);
router.get('/challenges/edit/:id', adminViewController.getEditChallengePage);
router.get('/challenges', adminViewController.getChallengesPage);
router.get('/settings', adminViewController.getSettingsPage);
router.get('/account', adminViewController.getAccountPage);
router.get('/training-modes/add', adminViewController.getAddTrainingModePage);
router.get('/training-modes/view/:id', adminViewController.getViewTrainingModePage);
router.get('/training-modes/edit/:id', adminViewController.getEditTrainingModePage);
router.get('/training-modes', adminViewController.getTrainingModesPage);
router.get('/subscription-plans/add', adminViewController.getAddSubscriptionPlanPage);
router.get('/subscription-plans/edit/:id', adminViewController.getEditSubscriptionPlanPage);
router.get('/subscription-plans', adminViewController.getSubscriptionPlansPage);
router.get('/user-subscriptions/:id', adminViewController.getUserSubscriptionDetailPage);
router.get('/user-subscriptions', adminViewController.getUserSubscriptionsPage);
router.get('/waitlist', adminViewController.getWaitlistPage);
router.get('/leaderboards', adminViewController.getLeaderboardsPage);
router.get('/users', adminViewController.getUsersPage);
router.get('/users/add', adminViewController.getAddUserPage);
router.get('/users/view/:id', adminViewController.getViewUserPage);
router.get('/users/edit/:id', adminViewController.getEditUserPage);
router.get('/exercises/edit/:id', adminViewController.getEditExercisePage);
router.get('/exercises/add', adminViewController.getAddExercisePage);
router.get('/login', adminViewController.getLoginPage);

// Redirect root admin to dashboard
router.get('/', (req, res) => res.redirect((process.env.PUBLIC_BASE_PATH || '').replace(/\/$/, '') + '/admin/dashboard'));

module.exports = router;
