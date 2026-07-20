-- Revert extra columns if an earlier draft migration added them.
-- Signup email OTP uses existing resetPasswordToken + resetPasswordExpire columns.

ALTER TABLE users DROP COLUMN emailVerificationOtp;
ALTER TABLE users DROP COLUMN emailVerificationExpire;
