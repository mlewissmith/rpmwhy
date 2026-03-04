## -*- meson -*-

# Abuse buildsystem to update metafiles (README etc) within source tree
# - `meson compile .meta`

__cp = find_program('cp')

META_SRCFILES = [
  'README.md',
  'COMPILING',
  'HACKING',
]

META_TGTFILES = []

foreach f : META_SRCFILES
  META_TGTFILES += configure_file(
    input         : f,
    output        : f,
    configuration : configx,
    install       : false,
  )
endforeach

custom_target(
  '.meta',
  input: META_TGTFILES,
  output: '.meta.PHONY',
  command: [ __cp, '-v', '-t', '@SOURCE_ROOT@', '@INPUT@' ],
  build_by_default: false,
  build_always_stale: true,
  install: false
)

