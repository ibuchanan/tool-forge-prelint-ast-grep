# Agent guidance

This repository is a set of `ast-grep` rules.
Create all agent-generated temporary files and directories under `.scratch/`,
retaining the `tmp_rovo_` prefix.
Don't clean them up when finished
because .scratch will be cleaned by the user.
