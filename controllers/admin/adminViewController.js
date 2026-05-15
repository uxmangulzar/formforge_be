const path = require('path');

const getDashboard = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/dashboard.html'));
};

const getExercisePage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/exercises.html'));
};

const getExerciseCategoriesPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/exercise_categories.html'));
};

const getChallengesPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/challenges.html'));
};

const getAddChallengePage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/add_challenge.html'));
};

const getViewChallengePage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/view_challenge.html'));
};

const getEditChallengePage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/edit_challenge.html'));
};

const getLoginPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/login.html'));
};

const getSettingsPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/settings.html'));
};

const getTrainingModesPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/training_modes.html'));
};

const getSubscriptionPlansPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/subscription_plans.html'));
};

const getAddSubscriptionPlanPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/add_subscription_plan.html'));
};

const getEditSubscriptionPlanPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/edit_subscription_plan.html'));
};

const getUserSubscriptionsPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/user_subscriptions.html'));
};

const getUserSubscriptionDetailPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/user_subscription_detail.html'));
};

const getAddTrainingModePage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/add_training_mode.html'));
};

const getViewTrainingModePage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/view_training_mode.html'));
};

const getEditTrainingModePage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/edit_training_mode.html'));
};

const getWaitlistPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/waitlist.html'));
};

const getLeaderboardsPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/leaderboards.html'));
};

const getUsersPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/users.html'));
};

const getAddUserPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/add_user.html'));
};

const getViewUserPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/view_user.html'));
};

const getEditUserPage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/edit_user.html'));
};

const getEditExercisePage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/edit_exercise.html'));
};

const getAddExercisePage = (req, res) => {
    res.sendFile(path.join(__dirname, '../../admin/views/add_exercise.html'));
};

module.exports = {
    getDashboard,
    getExercisePage,
    getExerciseCategoriesPage,
    getChallengesPage,
    getAddChallengePage,
    getViewChallengePage,
    getEditChallengePage,
    getLoginPage,
    getSettingsPage,
    getTrainingModesPage,
    getSubscriptionPlansPage,
    getAddSubscriptionPlanPage,
    getEditSubscriptionPlanPage,
    getUserSubscriptionsPage,
    getUserSubscriptionDetailPage,
    getAddTrainingModePage,
    getViewTrainingModePage,
    getEditTrainingModePage,
    getWaitlistPage,
    getLeaderboardsPage,
    getUsersPage,
    getEditExercisePage,
    getAddExercisePage,
    getAddUserPage,
    getViewUserPage,
    getEditUserPage
};
