## -*- meson -*-

project(
  'rpmwhy',
  version: '1.0',
  default_options: [],
)

_package_bugreport   = 'https://github.com/mlewissmith/rpmwhy/issues'
_package_url         = 'https://github.com/mlewissmith/rpmwhy'
_package_summary     = 'Query all packages that require/recommend CAPABILITY'
_package_description = '''
Why is a given package on my system?
rpmwhy is a wrapper around rpm -q --what{requires,recommends}.
'''

################################################################################

PROJECT_NAME    = meson.project_name()
PROJECT_VERSION = meson.project_version()

## autotools compatibility
PACKAGE_NAME        = get_option('PACKAGE_NAME')==''        ? PROJECT_NAME                 : get_option('PACKAGE_NAME')
PACKAGE_VERSION     = get_option('PACKAGE_VERSION')==''     ? PROJECT_VERSION              : get_option('PACKAGE_VERSION')
PACKAGE_BUGREPORT   = get_option('PACKAGE_BUGREPORT')==''   ? _package_bugreport           : get_option('PACKAGE_BUGREPORT')
PACKAGE_URL         = get_option('PACKAGE_URL')==''         ? _package_url                 : get_option('PACKAGE_URL')
_package_tarname    = PACKAGE_NAME.to_lower().underscorify().replace('_','-')
PACKAGE_TARNAME     = get_option('PACKAGE_TARNAME')==''     ? _package_tarname             : get_option('PACKAGE_TARNAME')
_package_string     = PACKAGE_NAME+' '+PACKAGE_VERSION
PACKAGE_STRING      = get_option('PACKAGE_STRING')==''      ? _package_string              : get_option('PACKAGE_STRING')
## extensions
PACKAGE_SUMMARY     = get_option('PACKAGE_SUMMARY')==''     ? _package_summary             : get_option('PACKAGE_SUMMARY')
PACKAGE_DESCRIPTION = get_option('PACKAGE_DESCRIPTION')=='' ? _package_description.strip() : get_option('PACKAGE_DESCRIPTION').strip()
_package_varname    = PACKAGE_NAME.underscorify()
PACKAGE_VARNAME     = get_option('PACKAGE_VARNAME')==''     ? _package_varname             : get_option('PACKAGE_VARNAME')
## aliases
NAME    = PACKAGE_NAME
VERSION = PACKAGE_VERSION
PACKAGE = PACKAGE_TARNAME

message(PACKAGE_SUMMARY+'\n'+PACKAGE_DESCRIPTION)

summary({'PROJECT_NAME'        : PROJECT_NAME,
         'PROJECT_VERSION'     : PROJECT_VERSION},
        section: 'Project macros')
summary({'PACKAGE_NAME'        : PACKAGE_NAME,
         'PACKAGE_VERSION'     : PACKAGE_VERSION,
         'PACKAGE_STRING'      : PACKAGE_STRING,
         'PACKAGE_BUGREPORT'   : PACKAGE_BUGREPORT,
         'PACKAGE_URL'         : PACKAGE_URL,
         'PACKAGE_TARNAME'     : PACKAGE_TARNAME,
         'PACKAGE_VARNAME'     : PACKAGE_VARNAME,
         'PACKAGE_SUMMARY'     : PACKAGE_SUMMARY,
         'PACKAGE_DESCRIPTION' : PACKAGE_DESCRIPTION},
        section: 'Package macros')
summary({'NAME'                : NAME,
         'VERSION'             : VERSION,
         'PACKAGE'             : PACKAGE},
        section: 'Alias macros')

################################################################################

## FULLY expanded configuration substitutions
configx = configuration_data(
  {
    ## meson project macros
    'PROJECT_NAME'        : PROJECT_NAME,
    'PROJECT_VERSION'     : PROJECT_VERSION,
    ## package macros
    'PACKAGE_NAME'        : PACKAGE_NAME,
    'PACKAGE_VERSION'     : PACKAGE_VERSION,
    'PACKAGE_BUGREPORT'   : PACKAGE_BUGREPORT,
    'PACKAGE_URL'         : PACKAGE_URL,
    'PACKAGE_TARNAME'     : PACKAGE_TARNAME,
    'PACKAGE_STRING'      : PACKAGE_STRING,
    'PACKAGE_VARNAME'     : PACKAGE_VARNAME,
    'PACKAGE_SUMMARY'     : PACKAGE_SUMMARY,
    'PACKAGE_DESCRIPTION' : PACKAGE_DESCRIPTION,
    ## alias macros
    'NAME'                : NAME,
    'VERSION'             : VERSION,
    'PACKAGE'             : PACKAGE,

    ## meson standard directories - fully expanded
    'prefix'         : get_option('prefix'),
    'bindir'         : get_option('bindir').startswith('/')         ? get_option('bindir')         : get_option('prefix')/get_option('bindir'),
    'datadir'        : get_option('datadir').startswith('/')        ? get_option('datadir')        : get_option('prefix')/get_option('datadir'),
    'includedir'     : get_option('includedir').startswith('/')     ? get_option('includedir')     : get_option('prefix')/get_option('includedir'),
    'infodir'        : get_option('infodir').startswith('/')        ? get_option('infodir')        : get_option('prefix')/get_option('infodir'),
    'libdir'         : get_option('libdir').startswith('/')         ? get_option('libdir')         : get_option('prefix')/get_option('libdir'),
    'libexecdir'     : get_option('libexecdir').startswith('/')     ? get_option('libexecdir')     : get_option('prefix')/get_option('libexecdir'),
    'localedir'      : get_option('localedir').startswith('/')      ? get_option('localedir')      : get_option('prefix')/get_option('localedir'),
    'localstatedir'  : get_option('localstatedir').startswith('/')  ? get_option('localstatedir')  : get_option('prefix')/get_option('localstatedir'),
    'mandir'         : get_option('mandir').startswith('/')         ? get_option('mandir')         : get_option('prefix')/get_option('mandir'),
    'sbindir'        : get_option('sbindir').startswith('/')        ? get_option('sbindir')        : get_option('prefix')/get_option('sbindir'),
    'sharedstatedir' : get_option('sharedstatedir').startswith('/') ? get_option('sharedstatedir') : get_option('prefix')/get_option('sharedstatedir'),
    'sysconfdir'     : get_option('sysconfdir').startswith('/')     ? get_option('sysconfdir')     : get_option('prefix')/get_option('sysconfdir'),
  },
)

summary({'bindir'         : configx.get('bindir'),
         'datadir'        : configx.get('datadir'),
         'includedir'     : configx.get('includedir'),
         'infodir'        : configx.get('infodir'),
         'libdir'         : configx.get('libdir'),
         'libexecdir'     : configx.get('libexecdir'),
         'localedir'      : configx.get('localedir'),
         'localstatedir'  : configx.get('localstatedir'),
         'mandir'         : configx.get('mandir'),
         'prefix'         : configx.get('prefix'),
         'sbindir'        : configx.get('sbindir'),
         'sharedstatedir' : configx.get('sharedstatedir'),
         'sysconfdir'     : configx.get('sysconfdir')},
        section: 'Directory macros: meson standard')

## Directories (autotools compatibility)
configx.set( 'datarootdir',       configx.get('datadir') )
configx.set( 'docdir',            configx.get('datadir')/'doc'/PACKAGE )
configx.set( 'dvidir',            configx.get('docdir') )
configx.set( 'exec_prefix',       configx.get('prefix') )
configx.set( 'htmldir',           configx.get('docdir') )
configx.set( 'oldincludedir',     '/usr/include' )
configx.set( 'pdfdir',            configx.get('docdir') )
configx.set( 'psdir',             configx.get('docdir') )
configx.set( 'runstatedir',       configx.get('localstatedir')/'run' )
configx.set( 'pkglibexecdir',     configx.get('libexecdir')/PACKAGE )
configx.set( 'pkgdatadir',        configx.get('datadir')/PACKAGE )
configx.set( 'pkgincludedir',     configx.get('includedir')/PACKAGE )
configx.set( 'pkglibdir',         configx.get('libdir')/PACKAGE )
configx.set( 'pkglocalstatedir',  configx.get('localstatedir')/PACKAGE )
configx.set( 'pkgsharedstatedir', configx.get('sharedstatedir')/PACKAGE )

summary({'datarootdir'       : configx.get('datarootdir'),
         'docdir'            : configx.get('docdir'),
         'dvidir'            : configx.get('dvidir'),
         'exec_prefix'       : configx.get('exec_prefix'),
         'htmldir'           : configx.get('htmldir'),
         'oldincludedir'     : configx.get('oldincludedir'),
         'pdfdir'            : configx.get('pdfdir'),
         'psdir'             : configx.get('psdir'),
         'runstatedir'       : configx.get('runstatedir'),
         'pkglibexecdir'     : configx.get('pkglibexecdir'),
         'pkgdatadir'        : configx.get('pkgdatadir'),
         'pkgincludedir'     : configx.get('pkgincludedir'),
         'pkglibdir'         : configx.get('pkglibdir'),
         'pkglocalstatedir'  : configx.get('pkglocalstatedir'),
         'pkgsharedstatedir' : configx.get('pkgsharedstatedir')},
        section: 'Directory macros: autoconf compatibility')

################################################################################

__rpmwhy = configure_file(
  input         : 'rpmwhy.sh',
  output        : 'rpmwhy',
  configuration : configx,
  install       : true,
  install_dir   : configx.get('bindir'),
  install_mode  : 'rwxr-xr-x',
)

