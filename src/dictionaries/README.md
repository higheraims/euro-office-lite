# Spellcheck dictionaries

Hunspell dictionaries served to the spellcheck worker
(`sdkjs/common/spell/spell/spell.js`). They live at the root of the served
frontend, so the runtime URL of a dictionary is
`dictionaries/<lang>/<lang>.aff` and `dictionaries/<lang>/<lang>.dic`; that
layout is what the worker builds internally and is not configurable.

This directory is unrelated to the `dictionaries/` directory at the repository
root, which belongs to the x2t / DoctRenderer converter.

## Provenance

Copied verbatim from https://github.com/Euro-Office/dictionaries at commit
`e7e25ba183a5cd24427256a6c3f20f1749894f33`. Nothing here is generated or
edited: to refresh a dictionary, copy the folder again from a newer commit and
update the SHA above.

The thesaurus files of `en_US` (`en_US_thes.dat`, `en_US_thes.idx`, about
15 MB) are deliberately not copied. Nothing in the application reads them and
they would ship in every installer.

## Licences

Each folder carries its own licence files; they are copied along with the
dictionary and must stay with it.

- `en_US` — see `license.txt` (SCOWL / Hunspell, BSD-style), `WordNet_license.txt`
  and `README_en_US.txt`. Hyphenation: `README_hyph_en_US.txt`.
- `es_ES` — see `LICENSE.md`: GPL-3.0-or-later, LGPL-3.0-or-later or MPL-1.1, at
  the user's choice; full texts in `GPLv3.txt`, `LGPLv3.txt`, `es_ES_LGPLv3.txt`,
  `es_ES_MPL-1.1.txt` and `LGPLv2.1.txt`. Hyphenation: `README_hyph_es_ES.txt`.

## Adding a language

1. Copy the whole language folder from the upstream repository into this
   directory, licence and README files included, keeping the upstream folder
   name (it must match the base name of its `.aff` and `.dic`).
2. Add that folder name to `manifest.json`.
3. Note the new provenance SHA above if it differs.

No code change is needed. The manifest is the only list the application reads,
and the build keeps it honest in both directions: it fails if the manifest names
a folder that is not here, and it fails if a folder here is not named by the
manifest. At runtime the bridge offers the editor the languages the manifest
names, intersected with the LCID table sdkjs itself publishes
(`AscCommon.spellcheckGetLanguages()`), so a folder whose name is not one of
those (a typo, or a language sdkjs does not know) reaches nothing and is worth
checking against that table before being added.

The `<lang>.json` file in each folder is upstream metadata (the LCIDs a folder
serves). It is kept for completeness; the application does not read it.
