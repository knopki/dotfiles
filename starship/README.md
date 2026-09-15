# Starship

Starship is owned by many writers: `mise` and (sometimes) the Noctalia theme
generator. `mise` manages the static settings as a marker-delimited block plus
the `$schema` line; Noctalia owns the root `palette` selector and the generated
`[palettes.noctalia]` block.

Do NOT turn these into one whole-file `copy`: apply would erase the generated
palette. Do NOT move `$schema` inside the block: Noctalia inserts `palette`
right after the first `"$schema"` line, which would then be overwritten on the
next mise apply.
