---------------------------
-- ccDynamicDifficultyConfig by Texafornian
--
-- Used by "ccDynamicDifficulty" script

------------------
-- DO NOT TOUCH!
------------------

ccDynamicDifficultySettings = {}

-- How much the difficulty will increase or decrease per player connection event.
ccDynamicDifficultySettings.difficultyPerPlayer = 10

-- If enabled, the difficulty will stop increasing after a specified value.
ccDynamicDifficultySettings.maxDifficultyEnabled = true

-- The highest possible difficulty value.
-- Requires maxDifficultyEnabled to be set to true!
ccDynamicDifficultySettings.maxDifficulty = 100
