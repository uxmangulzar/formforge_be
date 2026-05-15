const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { connectDB, sequelize } = require('./database/db');
const { errorHandler } = require('./middleware/errorMiddleware');
const WaitlistUser = require('./models/waitlistUserModel');
const Setting = require('./models/settingModel');

// Routes
const waitlistRoutes = require('./routes/waitlistRoutes');
const authRoutes = require('./routes/authRoutes');
const profileRoutes = require('./routes/profileRoutes');
const exerciseRoutes = require('./routes/exerciseRoutes');
const adminRoutes = require('./routes/admin/adminRoutes');
const adminAuthRoutes = require('./routes/admin/adminAuthRoutes');
const adminUserRoutes = require('./routes/admin/adminUserRoutes');
const adminChallengeRoutes = require('./routes/admin/adminChallengeRoutes');
const adminBadgeRoutes = require('./routes/admin/adminBadgeRoutes');
const adminSettingRoutes = require('./routes/admin/adminSettingRoutes');
const adminTrainingModeRoutes = require('./routes/admin/adminTrainingModeRoutes');
const adminNotificationRoutes = require('./routes/admin/adminNotificationRoutes');
const adminExerciseCategoryRoutes = require('./routes/admin/adminExerciseCategoryRoutes');
const adminExerciseRoutes = require('./routes/admin/adminExerciseRoutes');
const adminLeaderboardRoutes = require('./routes/admin/adminLeaderboardRoutes');
const adminSubscriptionPlanRoutes = require('./routes/admin/adminSubscriptionPlanRoutes');
const adminUserSubscriptionRoutes = require('./routes/admin/adminUserSubscriptionRoutes');
const uploadRoutes = require('./routes/uploadRoutes');
const SubscriptionPlan = require('./models/subscriptionPlanModel');
const UserSubscription = require('./models/userSubscriptionModel');
const UserSubscriptionLog = require('./models/userSubscriptionLogModel');
const UserSubscriptionStoreSync = require('./models/userSubscriptionStoreSyncModel');
const User = require('./models/userModel');
const Profile = require('./models/profileModel');
const Exercise = require('./models/exerciseModel');
const ExerciseCategory = require('./models/exerciseCategoryModel');
const Challenge = require('./models/challengeModel');
const ChallengeStage = require('./models/challengeStageModel');
const ChallengeStageExercise = require('./models/challengeStageExerciseModel');
const UserChallenge = require('./models/userChallengeModel');
const UserChallengeStageProgress = require('./models/userChallengeStageProgressModel');
const UserChallengeExerciseProgress = require('./models/userChallengeExerciseProgressModel');
const Badge = require('./models/badgeModel');
const BadgeRule = require('./models/badgeRuleModel');
const UserBadge = require('./models/userBadgeModel');
const Notification = require('./models/notificationModel');
const AdminNotificationSetting = require('./models/adminNotificationSettingModel');

// Define Associations
User.hasOne(Profile, { foreignKey: 'user_id', as: 'profile' });
Profile.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

Challenge.hasMany(ChallengeStage, { foreignKey: 'challenge_id', as: 'stages' });
ChallengeStage.belongsTo(Challenge, { foreignKey: 'challenge_id', as: 'challenge' });

ChallengeStage.hasMany(ChallengeStageExercise, { foreignKey: 'challenge_stage_id', as: 'stageExercises' });
ChallengeStageExercise.belongsTo(ChallengeStage, { foreignKey: 'challenge_stage_id', as: 'stage' });
ChallengeStageExercise.belongsTo(Exercise, { foreignKey: 'exercise_id', as: 'exercise' });
Exercise.hasMany(ChallengeStageExercise, { foreignKey: 'exercise_id', as: 'challengeStageExercises' });

Exercise.belongsTo(ExerciseCategory, { foreignKey: 'category_id', as: 'exerciseCategory' });
ExerciseCategory.hasMany(Exercise, { foreignKey: 'category_id', as: 'exercises' });

User.hasMany(UserChallenge, { foreignKey: 'user_id', as: 'userChallenges' });
UserChallenge.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
Challenge.hasMany(UserChallenge, { foreignKey: 'challenge_id', as: 'userChallenges' });
UserChallenge.belongsTo(Challenge, { foreignKey: 'challenge_id', as: 'challenge' });

UserChallenge.hasMany(UserChallengeStageProgress, { foreignKey: 'user_challenge_id', as: 'stageProgress' });
UserChallengeStageProgress.belongsTo(UserChallenge, { foreignKey: 'user_challenge_id', as: 'userChallenge' });
ChallengeStage.hasMany(UserChallengeStageProgress, { foreignKey: 'challenge_stage_id', as: 'userStageProgress' });
UserChallengeStageProgress.belongsTo(ChallengeStage, { foreignKey: 'challenge_stage_id', as: 'challengeStage' });

UserChallenge.hasMany(UserChallengeExerciseProgress, { foreignKey: 'user_challenge_id', as: 'exerciseProgress' });
UserChallengeExerciseProgress.belongsTo(UserChallenge, { foreignKey: 'user_challenge_id', as: 'userChallenge' });
ChallengeStageExercise.hasMany(UserChallengeExerciseProgress, { foreignKey: 'challenge_stage_exercise_id', as: 'userExerciseProgress' });
UserChallengeExerciseProgress.belongsTo(ChallengeStageExercise, { foreignKey: 'challenge_stage_exercise_id', as: 'challengeStageExercise' });

Badge.hasMany(BadgeRule, { foreignKey: 'badge_id', as: 'rules' });
BadgeRule.belongsTo(Badge, { foreignKey: 'badge_id', as: 'badge' });
Challenge.hasMany(BadgeRule, { foreignKey: 'challenge_id', as: 'badgeRules' });
BadgeRule.belongsTo(Challenge, { foreignKey: 'challenge_id', as: 'challenge' });

Challenge.hasMany(Badge, { foreignKey: 'challenge_id', as: 'challengeBadges' });
Badge.belongsTo(Challenge, { foreignKey: 'challenge_id', as: 'challengeOwner' });

User.hasMany(UserBadge, { foreignKey: 'user_id', as: 'userBadges' });
UserBadge.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
Badge.hasMany(UserBadge, { foreignKey: 'badge_id', as: 'userBadges' });
UserBadge.belongsTo(Badge, { foreignKey: 'badge_id', as: 'badge' });

User.hasMany(Notification, { foreignKey: 'recipient_user_id', as: 'notifications' });
Notification.belongsTo(User, { foreignKey: 'recipient_user_id', as: 'recipient' });

User.hasOne(AdminNotificationSetting, { foreignKey: 'user_id', as: 'notificationSettings' });
AdminNotificationSetting.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

User.hasMany(UserSubscription, { foreignKey: 'user_id', as: 'subscriptions' });
UserSubscription.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
SubscriptionPlan.hasMany(UserSubscription, { foreignKey: 'subscription_plan_id', as: 'userSubscriptions' });
UserSubscription.belongsTo(SubscriptionPlan, { foreignKey: 'subscription_plan_id', as: 'plan' });
UserSubscription.hasMany(UserSubscriptionLog, {
    foreignKey: 'user_subscription_id',
    as: 'logs'
});
UserSubscription.hasMany(UserSubscriptionStoreSync, {
    foreignKey: 'user_subscription_id',
    as: 'storeSyncs'
});
UserSubscriptionStoreSync.belongsTo(UserSubscription, {
    foreignKey: 'user_subscription_id',
    as: 'userSubscription'
});

UserSubscriptionLog.belongsTo(UserSubscription, {
    foreignKey: 'user_subscription_id',
    as: 'subscription'
});

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('admin')); // Serve admin static assets
app.use('/uploads', express.static('uploads')); // Serve uploaded files

// Routes Usage
app.use('/api/waitlist', waitlistRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/exercises', exerciseRoutes);
app.use('/api/admin/auth', adminAuthRoutes);
app.use('/api/admin/users', adminUserRoutes);
app.use('/api/admin/challenges', adminChallengeRoutes);
app.use('/api/admin/badges', adminBadgeRoutes);
app.use('/api/admin/settings', adminSettingRoutes);
app.use('/api/admin/training-modes', adminTrainingModeRoutes);
app.use('/api/admin/notifications', adminNotificationRoutes);
app.use('/api/admin/exercise-categories', adminExerciseCategoryRoutes);
app.use('/api/admin/exercises', adminExerciseRoutes);
app.use('/api/admin/leaderboard', adminLeaderboardRoutes);
app.use('/api/admin/subscription-plans', adminSubscriptionPlanRoutes);
app.use('/api/admin/user-subscriptions', adminUserSubscriptionRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/', adminRoutes); // Use admin panel routes at base URL


// Health Check Route
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'OK' });
});

// Error Middleware
app.use(errorHandler);

const startServer = async () => {
    try {
        await connectDB();

        // Sync: use alter in non-production so new model columns (e.g. challenges.starts_at) are added
        // to tables that already existed from an older sync. Set NODE_ENV=production or DB_SYNC_ALTER=false to skip.
        const syncAlter =
            process.env.DB_SYNC_ALTER === 'true' ||
            (process.env.DB_SYNC_ALTER !== 'false' && process.env.NODE_ENV !== 'production');
        try {
            await sequelize.sync({ alter: syncAlter });
        } catch (syncErr) {
            const code = syncErr?.parent?.code || syncErr?.original?.code;
            // MySQL max 64 keys per table — repeated alter:true can duplicate indexes; skip alter so the app still boots.
            if (syncAlter && code === 'ER_TOO_MANY_KEYS') {
                console.warn(
                    '⚠️  sequelize.sync({ alter: true }) failed (ER_TOO_MANY_KEYS). Retrying with alter: false.\n' +
                    '   Fix: drop duplicate indexes on the reported table, or set DB_SYNC_ALTER=false in .env.'
                );
                await sequelize.sync({ alter: false });
            } else {
                throw syncErr;
            }
        }

        app.listen(PORT, () => {
            console.log(`
🚀 Server is screaming at http://localhost:${PORT}
🛠️  Mode: Development
            `);
        });
    } catch (error) {
        console.error('Failed to start server:', error);
    }
};

startServer();
