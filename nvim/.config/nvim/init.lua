--
-- My nvim config
--
--
-- plugin config to improve start-up time.
-- it should be always on top on init.lua file
-- impatient needs to be setup before any other lua plugin is loaded
require("impatient")

-- my configs
require("knth.configs")
require("knth.mappings")
require("knth.plugins")
