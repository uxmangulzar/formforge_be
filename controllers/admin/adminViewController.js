const fs = require('fs');
const path = require('path');

const VIEWS_DIR = path.join(__dirname, '../../admin/views');

/** Inline in <head> before paint — keeps dark theme when navigating between admin routes. */
const THEME_BOOT_SNIPPET = `<script id="repvio-theme-boot">
(function(){try{var isLogin=/\\/admin\\/login$/.test(location.pathname);var t=isLogin?'dark':(localStorage.getItem('theme')||'light');document.documentElement.setAttribute('data-theme',t);}catch(e){}var p=location.pathname,i=p.indexOf('/admin'),b=i>=0?p.slice(0,i):'';document.write('<link id="repvio-tailwind-css" rel="stylesheet" href="'+b+'/css/tailwind-built.css"><link id="repvio-theme-css" rel="stylesheet" href="'+b+'/css/style.css">');})();
</script>`;

function sendAdminView(res, filename) {
    const filePath = path.join(VIEWS_DIR, filename);
    fs.readFile(filePath, 'utf8', (err, html) => {
        if (err) {
            return res.status(500).send('Failed to load admin view');
        }
        if (!html.includes('repvio-theme-boot')) {
            html = html.replace(/<head([^>]*)>/i, '<head$1>\n    ' + THEME_BOOT_SNIPPET);
        }
        res.type('html').send(html);
    });
}

const getDashboard = (req, res) => sendAdminView(res, 'dashboard.html');
const getExercisePage = (req, res) => sendAdminView(res, 'exercises.html');
const getExerciseCategoriesPage = (req, res) => sendAdminView(res, 'exercise_categories.html');
const getEditExerciseCategoryPage = (req, res) => sendAdminView(res, 'edit_exercise_category.html');
const getViewExerciseCategoryPage = (req, res) => sendAdminView(res, 'view_exercise_category.html');
const getChallengesPage = (req, res) => sendAdminView(res, 'challenges.html');
const getAddChallengePage = (req, res) => sendAdminView(res, 'add_challenge.html');
const getViewChallengePage = (req, res) => sendAdminView(res, 'view_challenge.html');
const getEditChallengePage = (req, res) => sendAdminView(res, 'edit_challenge.html');
const getLoginPage = (req, res) => sendAdminView(res, 'login.html');
const getSettingsPage = (req, res) => sendAdminView(res, 'settings.html');
const getAccountPage = (req, res) => sendAdminView(res, 'account.html');
const getTrainingModesPage = (req, res) => sendAdminView(res, 'training_modes.html');
const getSubscriptionPlansPage = (req, res) => sendAdminView(res, 'subscription_plans.html');
const getAddSubscriptionPlanPage = (req, res) => sendAdminView(res, 'add_subscription_plan.html');
const getEditSubscriptionPlanPage = (req, res) => sendAdminView(res, 'edit_subscription_plan.html');
const getUserSubscriptionsPage = (req, res) => sendAdminView(res, 'user_subscriptions.html');
const getUserSubscriptionDetailPage = (req, res) => sendAdminView(res, 'user_subscription_detail.html');
const getAddTrainingModePage = (req, res) => sendAdminView(res, 'add_training_mode.html');
const getViewTrainingModePage = (req, res) => sendAdminView(res, 'view_training_mode.html');
const getEditTrainingModePage = (req, res) => sendAdminView(res, 'edit_training_mode.html');
const getWaitlistPage = (req, res) => sendAdminView(res, 'waitlist.html');
const getLeaderboardsPage = (req, res) => sendAdminView(res, 'leaderboards.html');
const getUsersPage = (req, res) => sendAdminView(res, 'users.html');
const getAddUserPage = (req, res) => sendAdminView(res, 'add_user.html');
const getViewUserPage = (req, res) => sendAdminView(res, 'view_user.html');
const getEditUserPage = (req, res) => sendAdminView(res, 'edit_user.html');
const getEditExercisePage = (req, res) => sendAdminView(res, 'edit_exercise.html');
const getAddExercisePage = (req, res) => sendAdminView(res, 'add_exercise.html');

module.exports = {
    getDashboard,
    getExercisePage,
    getExerciseCategoriesPage,
    getEditExerciseCategoryPage,
    getViewExerciseCategoryPage,
    getChallengesPage,
    getAddChallengePage,
    getViewChallengePage,
    getEditChallengePage,
    getLoginPage,
    getSettingsPage,
    getAccountPage,
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
