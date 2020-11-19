#!/usr/bin/env -S docker build --compress -t pvtmert/python -f

ARG PREFIX=/opt
ARG BASE=debian:testing
FROM ${BASE} AS build

RUN apt update
RUN apt install -y \
	build-essential gcc \
	xz-utils curl make \
	libreadline-dev \
	libsqlite3-dev \
	libncurses-dev \
	libmcrypt-dev \
	libmpdec-dev \
	libgdbm-dev \
	liblzma-dev \
	libssl-dev \
	zlib1g-dev \
	libffi-dev \
	libbz2-dev \
	liblz-dev \
	libc6-dev \
	libc-dev \
	uuid-dev \
	lzma-dev \
	file \
	clang \
	llvm \
	lld \
	zip \
	git

ARG MAJ=3
ARG MIN=8
ARG PATCH=1
ARG VERSION=${MAJ}.${MIN}.${PATCH}
WORKDIR /data
RUN curl -#L https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tar.gz \
	| tar --strip=1 -xzC .

RUN echo                                                                                                                                                                                     '\n\
*static*                                                                                                                                                                                      \n\
# -*- makefile -*-                                                                                                                                                                            \n\
# The file Setup is used by the makesetup script to construct the files                                                                                                                       \n\
# Makefile and config.c, from Makefile.pre and config.c.in,                                                                                                                                   \n\
# respectively.  Note that Makefile.pre is created from Makefile.pre.in                                                                                                                       \n\
# by the toplevel configure script.                                                                                                                                                           \n\
# (VPATH notes: Setup and Makefile.pre are in the build directory, as                                                                                                                         \n\
# are Makefile and config.c; the *.in files are in the source directory.)                                                                                                                     \n\
# Each line in this file describes one or more optional modules.                                                                                                                              \n\
# Modules configured here will not be compiled by the setup.py script,                                                                                                                        \n\
# so the file can be used to override setup.pys behavior.                                                                                                                                     \n\
# Tag lines containing just the word "*static*", "*shared*" or "*disabled*"                                                                                                                   \n\
# (without the quotes but with the stars) are used to tag the following module                                                                                                                \n\
# descriptions. Tag lines may alternate throughout this file.  Modules are                                                                                                                    \n\
# built statically when they are preceded by a "*static*" tag line or when                                                                                                                    \n\
# there is no tag line between the start of the file and the module                                                                                                                           \n\
# description.  Modules are built as a shared library when they are preceded by                                                                                                               \n\
# a "*shared*" tag line.  Modules are not built at all, not by the Makefile,                                                                                                                  \n\
# nor by the setup.py script, when they are preceded by a "*disabled*" tag                                                                                                                    \n\
# line.                                                                                                                                                                                       \n\
# Lines have the following structure:                                                                                                                                                         \n\
# <module> ... [<sourcefile> ...] [<cpparg> ...] [<library> ...]                                                                                                                              \n\
# <sourcefile> is anything ending in .c (.C, .cc, .c++ are C++ files)                                                                                                                         \n\
# <cpparg> is anything starting with -I, -D, -U or -C                                                                                                                                         \n\
# <library> is anything ending in .a or beginning with -l or -L                                                                                                                               \n\
# <module> is anything else but should be a valid Python                                                                                                                                      \n\
# identifier (letters, digits, underscores, beginning with non-digit)                                                                                                                         \n\
# (As the makesetup script changes, it may recognize some other                                                                                                                               \n\
# arguments as well, e.g. *.so and *.sl as libraries.  See the big                                                                                                                            \n\
# case statement in the makesetup script.)                                                                                                                                                    \n\
# Lines can also have the form                                                                                                                                                                \n\
# <name> = <value>                                                                                                                                                                            \n\
# which defines a Make variable definition inserted into Makefile.in                                                                                                                          \n\
# The build process works like this:                                                                                                                                                          \n\
# 1. Build all modules that are declared as static in Modules/Setup,                                                                                                                          \n\
#    combine them into libpythonxy.a, combine that into python.                                                                                                                               \n\
# 2. Build all modules that are listed as shared in Modules/Setup.                                                                                                                            \n\
# 3. Invoke setup.py. That builds all modules that                                                                                                                                            \n\
#    a) are not builtin, and                                                                                                                                                                  \n\
#    b) are not listed in Modules/Setup, and                                                                                                                                                  \n\
#    c) can be build on the target                                                                                                                                                            \n\
# Therefore, modules declared to be shared will not be                                                                                                                                        \n\
# included in the config.c file, nor in the list of objects to be                                                                                                                             \n\
# added to the library archive, and their linker options wont be                                                                                                                              \n\
# added to the linker options. Rules to create their .o files and                                                                                                                             \n\
# their shared libraries will still be added to the Makefile, and                                                                                                                             \n\
# their names will be collected in the Make variable SHAREDMODS.  This                                                                                                                        \n\
# is used to build modules as shared libraries.  (They can be                                                                                                                                 \n\
# installed using "make sharedinstall", which is implied by the                                                                                                                               \n\
# toplevel "make install" target.)  (For compatibility,                                                                                                                                       \n\
# *noconfig* has the same effect as *shared*.)                                                                                                                                                \n\
# NOTE: As a standard policy, as many modules as can be supported by a                                                                                                                        \n\
# platform should be present.  The distribution comes with all modules                                                                                                                        \n\
# enabled that are supported by most platforms and dont require you                                                                                                                           \n\
# to ftp sources from elsewhere.                                                                                                                                                              \n\
# Some special rules to define PYTHONPATH.                                                                                                                                                    \n\
# Edit the definitions below to indicate which options you are using.                                                                                                                         \n\
# Dont add any whitespace or comments!                                                                                                                                                        \n\
# Directories where library files get installed.                                                                                                                                              \n\
# DESTLIB is for Python modules; MACHDESTLIB for shared libraries.                                                                                                                            \n\
DESTLIB=$(LIBDEST)                                                                                                                                                                            \n\
MACHDESTLIB=$(BINLIBDEST)                                                                                                                                                                     \n\
# NOTE: all the paths are now relative to the prefix that is computed                                                                                                                         \n\
# at run time!                                                                                                                                                                                \n\
# Standard path -- dont edit.                                                                                                                                                                 \n\
# No leading colon since this is the first entry.                                                                                                                                             \n\
# Empty since this is now just the runtime prefix.                                                                                                                                            \n\
DESTPATH=                                                                                                                                                                                     \n\
# Site specific path components -- should begin with : if non-empty                                                                                                                           \n\
SITEPATH=                                                                                                                                                                                     \n\
# Standard path components for test modules                                                                                                                                                   \n\
TESTPATH=                                                                                                                                                                                     \n\
COREPYTHONPATH=$(DESTPATH)$(SITEPATH)$(TESTPATH)                                                                                                                                              \n\
PYTHONPATH=$(COREPYTHONPATH)                                                                                                                                                                  \n\
# The modules listed here cant be built as shared libraries for                                                                                                                               \n\
# various reasons; therefore they are listed here instead of in the                                                                                                                           \n\
# normal order.                                                                                                                                                                               \n\
# This only contains the minimal set of modules required to run the                                                                                                                           \n\
# setup.py script in the root of the Python source tree.                                                                                                                                      \n\
posix -DPy_BUILD_CORE_BUILTIN -I$(srcdir)/Include/internal posixmodule.c  # posix (UNIX) system calls                                                                                         \n\
errno errnomodule.c                                                       # posix (UNIX) errno values                                                                                         \n\
pwd pwdmodule.c                                                           # this is needed to find out the users home dir                                                                     \n\
# if $HOME is not set                                                                                                                                                                         \n\
_sre _sre.c                                                               # Fredrik Lundhs new regular expressions                                                                            \n\
_codecs _codecsmodule.c                                                   # access to the builtin codecs and codec registry                                                                   \n\
_weakref _weakref.c                                                       # weak references                                                                                                   \n\
_functools -DPy_BUILD_CORE_BUILTIN -I$(srcdir)/Include/internal _functoolsmodule.c            # Tools for working with functions and callable objects                                         \n\
_operator _operator.c                                                                         # operator.add() and similar goodies                                                            \n\
_collections _collectionsmodule.c                                                             # Container types                                                                               \n\
_abc _abc.c                                                                                   # Abstract base classes                                                                         \n\
itertools itertoolsmodule.c                                                                   # Functions creating iterators for efficient looping                                            \n\
atexit atexitmodule.c                                                                         # Register functions to be run at interpreter-shutdown                                          \n\
_signal -DPy_BUILD_CORE_BUILTIN -I$(srcdir)/Include/internal signalmodule.c                                                                                                                   \n\
_stat _stat.c                                                                                 # stat.h interface                                                                              \n\
time -DPy_BUILD_CORE_BUILTIN -I$(srcdir)/Include/internal timemodule.c -lm                    # -lm # time operations and variables                                                           \n\
_thread -DPy_BUILD_CORE_BUILTIN -I$(srcdir)/Include/internal _threadmodule.c                  # low-level threading interface                                                                 \n\
# access to ISO C locale support                                                                                                                                                              \n\
_locale -DPy_BUILD_CORE_BUILTIN _localemodule.c #-lintl                                                                                                                                       \n\
# Standard I/O baseline                                                                                                                                                                       \n\
_io -DPy_BUILD_CORE_BUILTIN -I$(srcdir)/Include/internal -I$(srcdir)/Modules/_io _io/_iomodule.c _io/iobase.c _io/fileio.c _io/bytesio.c _io/bufferedio.c _io/textio.c _io/stringio.c         \n\
# faulthandler module                                                                                                                                                                         \n\
faulthandler faulthandler.c                                                                                                                                                                   \n\
# debug tool to trace memory blocks allocated by Python                                                                                                                                       \n\
# bpo-35053: The module must be builtin since _Py_NewReference()                                                                                                                              \n\
# can call _PyTraceMalloc_NewReference().                                                                                                                                                     \n\
_tracemalloc _tracemalloc.c hashtable.c                                                                                                                                                       \n\
# The rest of the modules listed in this file are all commented out by                                                                                                                        \n\
# default.  Usually they can be detected and built as dynamically                                                                                                                             \n\
# loaded modules by the new setup.py script added in Python 2.1.  If                                                                                                                          \n\
# youre on a platform that doesnt support dynamic loading, want to                                                                                                                            \n\
# compile modules statically into the Python binary, or need to                                                                                                                               \n\
# specify some odd set of compiler switches, you can uncomment the                                                                                                                            \n\
# appropriate lines below.                                                                                                                                                                    \n\
# ======================================================================                                                                                                                      \n\
# The Python symtable module depends on .h files that setup.py doesnt track                                                                                                                   \n\
_symtable symtablemodule.c                                                                                                                                                                    \n\
# Uncommenting the following line tells makesetup that all following                                                                                                                          \n\
# modules are to be built as shared libraries (see above for more                                                                                                                             \n\
# detail; also note that *static* or *disabled* cancels this effect):                                                                                                                         \n\
#*shared*                                                                                                                                                                                     \n\
# GNU readline.  Unlike previous Python incarnations, GNU readline is                                                                                                                         \n\
# now incorporated in an optional module, configured in the Setup file                                                                                                                        \n\
# instead of by a configure script switch.  You may have to insert a                                                                                                                          \n\
# -L option pointing to the directory where libreadline.* lives,                                                                                                                              \n\
# and you may have to change -ltermcap to -ltermlib or perhaps remove                                                                                                                         \n\
# it, depending on your system -- see the GNU readline instructions.                                                                                                                          \n\
# Its okay for this to be a shared library, too.                                                                                                                                              \n\
readline readline.c -lreadline -ltermcap                                                                                                                                                      \n\
# Modules that should always be present (non UNIX dependent):                                                                                                                                 \n\
array arraymodule.c                                                       # array objects                                                                                                     \n\
cmath cmathmodule.c _math.c -lm                                           # complex math library functions                                                                                    \n\
math mathmodule.c _math.c   -lm                                           # math library functions, e.g. sin()                                                                                \n\
_contextvars _contextvarsmodule.c                                         # Context Variables                                                                                                 \n\
_struct _struct.c                                                         # binary structure packing/unpacking                                                                                \n\
_weakref _weakref.c                                                       # basic weak reference support                                                                                      \n\
_random _randommodule.c                                                   # Random number generator                                                                                           \n\
_elementtree -I$(srcdir)/Modules/expat -DHAVE_EXPAT_CONFIG_H -DUSE_PYEXPAT_CAPI _elementtree.c # elementtree accelerator                                                                      \n\
_pickle _pickle.c                                                         # pickle accelerator                                                                                                \n\
_datetime _datetimemodule.c                                               # datetime accelerator                                                                                              \n\
_bisect _bisectmodule.c                                                   # Bisection algorithms                                                                                              \n\
_heapq _heapqmodule.c                                                     # Heap queue algorithm                                                                                              \n\
_asyncio _asynciomodule.c                                                 # Fast asyncio Future                                                                                               \n\
_json -I$(srcdir)/Include/internal -DPy_BUILD_CORE_BUILTIN _json.c        # _json speedups                                                                                                    \n\
_statistics _statisticsmodule.c # statistics accelerator                                                                                                                                      \n\
unicodedata unicodedata.c                                                 # static Unicode character database                                                                                 \n\
# Modules with some UNIX dependencies -- on by default:                                                                                                                                       \n\
# (If you have a really backward UNIX, select and socket may not be                                                                                                                           \n\
# supported...)                                                                                                                                                                               \n\
fcntl fcntlmodule.c                                                       # fcntl(2) and ioctl(2)                                                                                             \n\
spwd spwdmodule.c                                                         # spwd(3)                                                                                                           \n\
grp grpmodule.c                                                           # grp(3)                                                                                                            \n\
select selectmodule.c                                                     # select(2); not on ancient System V                                                                                \n\
# Memory-mapped files (also works on Win32).                                                                                                                                                  \n\
mmap mmapmodule.c                                                                                                                                                                             \n\
# CSV file helper                                                                                                                                                                             \n\
_csv _csv.c                                                                                                                                                                                   \n\
# Socket module helper for socket(2)                                                                                                                                                          \n\
_socket socketmodule.c                                                                                                                                                                        \n\
# Socket module helper for SSL support; you must comment out the other                                                                                                                        \n\
# socket line above, and possibly edit the SSL variable:                                                                                                                                      \n\
SSL=/usr/local/ssl                                                                                                                                                                            \n\
_ssl _ssl.c -DUSE_SSL -I$(SSL)/include -I$(SSL)/include/openssl -L$(SSL)/lib -lssl -lcrypto                                                                                                   \n\
# The crypt module is now disabled by default because it breaks builds                                                                                                                        \n\
# on many systems (where -lcrypt is needed), e.g. Linux (I believe).                                                                                                                          \n\
_crypt _cryptmodule.c -lcrypt                                             # crypt(3); needs -lcrypt on some systems                                                                           \n\
# Some more UNIX dependent modules -- off by default, since these                                                                                                                             \n\
# are not supported by all UNIX systems:                                                                                                                                                      \n\
nis nismodule.c -lnsl                                                     # Sun yellow pages -- not everywhere                                                                                \n\
termios termios.c                                                         # Steen Lumholts termios module                                                                                     \n\
resource resource.c                                                       # Jeremy Hyltons rlimit interface                                                                                   \n\
_posixsubprocess _posixsubprocess.c  # POSIX subprocess module helper                                                                                                                         \n\
# Multimedia modules -- off by default.                                                                                                                                                       \n\
# These dont work for 64-bit platforms!!!                                                                                                                                                     \n\
# #993173 says audioop works on 64-bit platforms, though.                                                                                                                                     \n\
# These represent audio samples or images as strings:                                                                                                                                         \n\
#audioop audioop.c                                                        # Operations on audio samples                                                                                       \n\
# Note that the _md5 and _sha modules are normally only built if the                                                                                                                          \n\
# system does not have the OpenSSL libs containing an optimized version.                                                                                                                      \n\
# The _md5 module implements the RSA Data Security, Inc. MD5                                                                                                                                  \n\
# Message-Digest Algorithm, described in RFC 1321.                                                                                                                                            \n\
_md5 md5module.c                                                                                                                                                                              \n\
# The _sha module implements the SHA checksum algorithms.                                                                                                                                     \n\
# (NISTs Secure Hash Algorithms.)                                                                                                                                                             \n\
_sha1 sha1module.c                                                                                                                                                                            \n\
_sha256 sha256module.c                                                                                                                                                                        \n\
_sha512 sha512module.c                                                                                                                                                                        \n\
_sha3 _sha3/sha3module.c                                                                                                                                                                      \n\
# _blake module                                                                                                                                                                               \n\
_blake2 _blake2/blake2module.c _blake2/blake2b_impl.c _blake2/blake2s_impl.c                                                                                                                  \n\
# Lance Ellinghauss syslog module                                                                                                                                                             \n\
syslog syslogmodule.c                                                     # syslog daemon interface                                                                                           \n\
# Curses support, requiring the System V version of curses, often                                                                                                                             \n\
# provided by the ncurses library.  e.g. on Linux, link with -lncurses                                                                                                                        \n\
# instead of -lcurses).                                                                                                                                                                       \n\
_curses _cursesmodule.c -lcurses -ltermcap                                                                                                                                                    \n\
# Wrapper for the panel library thats part of ncurses and SYSV curses.                                                                                                                        \n\
_curses_panel _curses_panel.c -lpanel -lncurses                                                                                                                                               \n\
# Modules that provide persistent dictionary-like semantics.  You will                                                                                                                        \n\
# probably want to arrange for at least one of them to be available on                                                                                                                        \n\
# your machine, though none are defined by default because of library                                                                                                                         \n\
# dependencies.  The Python module dbm/__init__.py provides an                                                                                                                                \n\
# implementation independent wrapper for these; dbm/dumb.py provides                                                                                                                          \n\
# similar functionality (but slower of course) implemented in Python.                                                                                                                         \n\
#_dbm _dbmmodule.c                                                        # dbm(3) may require -lndbm or similar                                                                              \n\
# Anthony Baxters gdbm module.  GNU dbm(3) will require -lgdbm:                                                                                                                               \n\
_gdbm _gdbmmodule.c -I/usr/local/include -L/usr/local/lib -lgdbm                                                                                                                              \n\
# Helper module for various ascii-encoders                                                                                                                                                    \n\
binascii binascii.c                                                                                                                                                                           \n\
# Fred Drakes interface to the Python parser                                                                                                                                                  \n\
parser parsermodule.c                                                                                                                                                                         \n\
# Andrew Kuchlings zlib module.                                                                                                                                                               \n\
# This require zlib 1.1.3 (or later).                                                                                                                                                         \n\
# See http://www.gzip.org/zlib/                                                                                                                                                               \n\
zlib zlibmodule.c -I$(prefix)/include -L$(exec_prefix)/lib -lz                                                                                                                                \n\
# Interface to the Expat XML parser                                                                                                                                                           \n\
# More information on Expat can be found at www.libexpat.org.                                                                                                                                 \n\
pyexpat expat/xmlparse.c expat/xmlrole.c expat/xmltok.c pyexpat.c -I$(srcdir)/Modules/expat -DHAVE_EXPAT_CONFIG_H -DXML_POOR_ENTROPY -DUSE_PYEXPAT_CAPI                                       \n\
# Another example -- the xxsubtype module shows C-level subtyping in action                                                                                                                   \n\
xxsubtype xxsubtype.c                                                                                                                                                                         \n\
# Uncommenting the following line tells makesetup that all following modules                                                                                                                  \n\
# are not built (see above for more detail).                                                                                                                                                  \n\
#*disabled*                                                                                                                                                                                   \n\
#_sqlite3 _tkinter _curses pyexpat                                                                                                                                                            \n\
#_codecs_jp _codecs_kr _codecs_tw unicodedata                                                                                                                                                 \n\
_lzma _lzmamodule.c -llzma                                                                                                                                                                    \n\
_bz2 _bz2module.c   -lbz2                                                                                                                                                                     \n\
#_sqlite3                                                                                                                                                                                     \n\
\n' | tee Modules/Setup
RUN echo '*static*' | tee -a Modules/Setup.local

ARG PREFIX
ARG BUILD=./build.dir
RUN trap 'cat config.log' EXIT \
	&& mkdir -p "${BUILD}" \
	&& cd "${BUILD}" \
	&& ../configure \
	LD="ld" \
	CC="gcc" \
	CXX="gcc++" \
	_LINKFORSHARED="-v -static-libgcc -static -Wl,--start-group" \
	_LDFLAGS_NODIST="-v -Wl,--export-dynamic" \
	--disable-profiling \
	--disable-shared \
	--disable-ipv6 \
	--enable-optimizations \
	--without-ensurepip \
	--without-pymalloc \
	--without-lto \
	--with-libc="" \
	--with-libm="" \
	--with-libs="" \
	--prefix="${PREFIX}"

RUN apt install -y ncdu less nano unzip
RUN make -C "${BUILD}" -j$(nproc) \
	_CC="gcc" \
	_LIBM="-l:libm.a" \
	_LIBC="-l:libc.a" \
	_LIBS="-l:libz.a -l:libdl.a -l:libutil.a -l:libcrypt.a -l:libreadline.a -l:libpthread.a" \
	_LINKFORSHARED="-v -Wl,-E -static -static-libgcc -l:libdl.a -l:libm.a" \
	_LIBS="-Wl,-Bstatic,--start-group,-lz,-lutil,-lcrypt,-lreadline,--end-group,-Bdynamic" \
	__LIBS="-lm -lz -ldl -lutil -lcrypt -lreadline" \
	python build_all install
RUN cd "${PREFIX}/lib/python${MAJ}.${MIN}" \
	&& find "${PREFIX}/lib/python${MAJ}.${MIN}" \( \
		-false \
		-or -iname "test" \
		-or -iname "__pycache__" \
		-or -iname "*.exe" \
		-or -iname "config-${MAJ}.${MIN}-*" \
	\) -exec rm -rf {} + \
	&& mv -f lib-dynload .. \
	&& zip -Xymr "../python${MAJ}${MIN}.zip" .
RUN rm -rf \
	"${PREFIX}/share" \
	"${PREFIX}/include" \
	"${PREFIX}/lib/libpython${MAJ}.${MIN}.a"

#_LIBS="-lc" \
#_CFLAGS="" \
#LDFLAGS="-flto" \
#_LINKFORSHARED="-Wl,--no-export-dynamic,--start-group" \
#RUN make -j$(nproc) python build_all LINKFORSHARED=" "
#RUN make -j$(nproc) bininstall libinstall sharedinstall

FROM ${BASE}
ARG PREFIX
COPY --from=build "${PREFIX}" "${PREFIX}"
#RUN "${PREFIX}/bin/python3" -c 'import socket;\
#print(socket.gethostbyname("google.com"))'
RUN du -h "${PREFIX}" | sort -h | tee -a /du
