-- Performance Optimization: Additional Indexes
-- Run this after schema.sql to improve query performance

-- Index for filtering artworks by user_id (already exists in schema.sql)
-- CREATE INDEX IF NOT EXISTS idx_artworks_user_id ON artworks(user_id);

-- Index for sorting by created_at (already exists in schema.sql)
-- CREATE INDEX IF NOT EXISTS idx_artworks_created_at ON artworks(created_at);

-- Composite index for common query pattern: user_id + created_at
-- This helps when filtering by user and sorting by date
CREATE INDEX IF NOT EXISTS idx_artworks_user_created 
ON artworks(user_id, created_at DESC);

-- Index for category filtering (if filtering by category is common)
CREATE INDEX IF NOT EXISTS idx_artworks_category 
ON artworks(category) 
WHERE category IS NOT NULL;

-- Index for year filtering (if filtering by year is common)
CREATE INDEX IF NOT EXISTS idx_artworks_year 
ON artworks(year) 
WHERE year IS NOT NULL;

-- Note: These indexes improve query performance but slightly slow down INSERT/UPDATE
-- For most use cases, the performance gain is worth it

