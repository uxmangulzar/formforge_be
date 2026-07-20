-- Allow deleting challenge-owned badges (CASCADE from challenges) without RESTRICT errors.
ALTER TABLE user_badges DROP FOREIGN KEY fk_user_badges_badge;
ALTER TABLE user_badges
    ADD CONSTRAINT fk_user_badges_badge
    FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE;
