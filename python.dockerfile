#!/usr/bin/env -S docker build --compress -t pvtmert/python -f

ARG PREFIX=/opt
ARG BASE=debian:testing
FROM ${BASE} as build

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
RUN curl -#L https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tar.xz \
	| xz -dc \
	| tar --strip=1 -x

RUN ( \
echo '*static*' ; \
echo '# -*- makefile -*-'                                                              ; \
echo '# The file Setup is used by the makesetup script to construct the files'         ; \
echo '# Makefile and config.c, from Makefile.pre and config.c.in,'                     ; \
echo '# respectively.  Note that Makefile.pre is created from Makefile.pre.in'         ; \
echo '# by the toplevel configure script.'                                             ; \
echo '# (VPATH notes: Setup and Makefile.pre are in the build directory, as'           ; \
echo '# are Makefile and config.c; the *.in files are in the source directory.)'       ; \
echo '# Each line in this file describes one or more optional modules.'                ; \
echo '# Modules configured here will not be compiled by the setup.py script,'          ; \
echo '# so the file can be used to override setup.pys behavior.'                       ; \
echo '# Tag lines containing just the word "*static*", "*shared*" or "*disabled*"'     ; \
echo '# (without the quotes but with the stars) are used to tag the following module'  ; \
echo '# descriptions. Tag lines may alternate throughout this file.  Modules are'      ; \
echo '# built statically when they are preceded by a "*static*" tag line or when'      ; \
echo '# there is no tag line between the start of the file and the module'             ; \
echo '# description.  Modules are built as a shared library when they are preceded by' ; \
echo '# a "*shared*" tag line.  Modules are not built at all, not by the Makefile,'    ; \
echo '# nor by the setup.py script, when they are preceded by a "*disabled*" tag'      ; \
echo '# line.'                                                                  ; \
echo '# Lines have the following structure:'                                    ; \
echo '# <module> ... [<sourcefile> ...] [<cpparg> ...] [<library> ...]'         ; \
echo '# <sourcefile> is anything ending in .c (.C, .cc, .c++ are C++ files)'    ; \
echo '# <cpparg> is anything starting with -I, -D, -U or -C'                    ; \
echo '# <library> is anything ending in .a or beginning with -l or -L'          ; \
echo '# <module> is anything else but should be a valid Python'                 ; \
echo '# identifier (letters, digits, underscores, beginning with non-digit)'    ; \
echo '# (As the makesetup script changes, it may recognize some other'          ; \
echo '# arguments as well, e.g. *.so and *.sl as libraries.  See the big'       ; \
echo '# case statement in the makesetup script.)'                               ; \
echo '# Lines can also have the form'                                           ; \
echo '# <name> = <value>'                                                       ; \
echo '# which defines a Make variable definition inserted into Makefile.in'     ; \
echo '# The build process works like this:'                                     ; \
echo '# 1. Build all modules that are declared as static in Modules/Setup,'     ; \
echo '#    combine them into libpythonxy.a, combine that into python.'          ; \
echo '# 2. Build all modules that are listed as shared in Modules/Setup.'       ; \
echo '# 3. Invoke setup.py. That builds all modules that'                       ; \
echo '#    a) are not builtin, and'                                             ; \
echo '#    b) are not listed in Modules/Setup, and'                             ; \
echo '#    c) can be build on the target'                                       ; \
echo '# Therefore, modules declared to be shared will not be'                   ; \
echo '# included in the config.c file, nor in the list of objects to be'        ; \
echo '# added to the library archive, and their linker options wont be'         ; \
echo '# added to the linker options. Rules to create their .o files and'        ; \
echo '# their shared libraries will still be added to the Makefile, and'        ; \
echo '# their names will be collected in the Make variable SHAREDMODS.  This'   ; \
echo '# is used to build modules as shared libraries.  (They can be'            ; \
echo '# installed using "make sharedinstall", which is implied by the'          ; \
echo '# toplevel "make install" target.)  (For compatibility,'                  ; \
echo '# *noconfig* has the same effect as *shared*.)'                           ; \
echo '# NOTE: As a standard policy, as many modules as can be supported by a'   ; \
echo '# platform should be present.  The distribution comes with all modules'   ; \
echo '# enabled that are supported by most platforms and dont require you'      ; \
echo '# to ftp sources from elsewhere.'                                         ; \
echo '# Some special rules to define PYTHONPATH.'                               ; \
echo '# Edit the definitions below to indicate which options you are using.'    ; \
echo '# Dont add any whitespace or comments!'                                   ; \
echo '# Directories where library files get installed.'                         ; \
echo '# DESTLIB is for Python modules; MACHDESTLIB for shared libraries.'       ; \
echo 'DESTLIB=$(LIBDEST)'                                                       ; \
echo 'MACHDESTLIB=$(BINLIBDEST)'                                                ; \
echo '# NOTE: all the paths are now relative to the prefix that is computed'    ; \
echo '# at run time!'                                                           ; \
echo '# Standard path -- dont edit.'                                            ; \
echo '# No leading colon since this is the first entry.'                        ; \
echo '# Empty since this is now just the runtime prefix.'                       ; \
echo 'DESTPATH='                                                                ; \
echo '# Site specific path components -- should begin with : if non-empty'      ; \
echo 'SITEPATH='                                                                ; \
echo '# Standard path components for test modules'                              ; \
echo 'TESTPATH='                                                                ; \
echo 'COREPYTHONPATH=$(DESTPATH)$(SITEPATH)$(TESTPATH)'                         ; \
echo 'PYTHONPATH=$(COREPYTHONPATH)'                                             ; \
echo '# The modules listed here cant be built as shared libraries for'          ; \
echo '# various reasons; therefore they are listed here instead of in the'      ; \
echo '# normal order.'                                                          ; \
echo '# This only contains the minimal set of modules required to run the'      ; \
echo '# setup.py script in the root of the Python source tree.'                 ; \
echo 'posix -DPy_BUILD_CORE_BUILTIN -I$(srcdir)/Include/internal posixmodule.c  # posix (UNIX) system calls'                       ; \
echo 'errno errnomodule.c                                                       # posix (UNIX) errno values'                       ; \
echo 'pwd pwdmodule.c                                                           # this is needed to find out the users home dir'   ; \
echo '# if $HOME is not set' ; \
echo '_sre _sre.c                                                               # Fredrik Lundhs new regular expressions'          ; \
echo '_codecs _codecsmodule.c                                                   # access to the builtin codecs and codec registry' ; \
echo '_weakref _weakref.c                                                       # weak references'                                 ; \
echo '_functools -DPy_BUILD_CORE_BUILTIN -I$(srcdir)/Include/internal _functoolsmodule.c            # Tools for working with functions and callable objects' ; \
echo '_operator _operator.c                                                                         # operator.add() and similar goodies'                    ; \
echo '_collections _collectionsmodule.c                                                             # Container types'                                       ; \
echo '_abc _abc.c                                                                                   # Abstract base classes'                                 ; \
echo 'itertools itertoolsmodule.c                                                                   # Functions creating iterators for efficient looping'    ; \
echo 'atexit atexitmodule.c                                                                         # Register functions to be run at interpreter-shutdown'  ; \
echo '_signal -DPy_BUILD_CORE_BUILTIN -I$(srcdir)/Include/internal signalmodule.c'                                                          ; \
echo '_stat _stat.c                                                                                 # stat.h interface'                     ; \
echo 'time -DPy_BUILD_CORE_BUILTIN -I$(srcdir)/Include/internal timemodule.c -lm                    # -lm # time operations and variables'  ; \
echo '_thread -DPy_BUILD_CORE_BUILTIN -I$(srcdir)/Include/internal _threadmodule.c                  # low-level threading interface'        ; \
echo '# access to ISO C locale support'                                                             ; \
echo '_locale -DPy_BUILD_CORE_BUILTIN _localemodule.c #-lintl'                                      ; \
echo '# Standard I/O baseline'                                                                      ; \
echo '_io -DPy_BUILD_CORE_BUILTIN -I$(srcdir)/Include/internal -I$(srcdir)/Modules/_io _io/_iomodule.c _io/iobase.c _io/fileio.c _io/bytesio.c _io/bufferedio.c _io/textio.c _io/stringio.c' ; \
echo '# faulthandler module'                                                       ; \
echo 'faulthandler faulthandler.c'                                                 ; \
echo '# debug tool to trace memory blocks allocated by Python'                     ; \
echo '# bpo-35053: The module must be builtin since _Py_NewReference()'            ; \
echo '# can call _PyTraceMalloc_NewReference().'                                   ; \
echo '_tracemalloc _tracemalloc.c hashtable.c'                                     ; \
echo '# The rest of the modules listed in this file are all commented out by'      ; \
echo '# default.  Usually they can be detected and built as dynamically'           ; \
echo '# loaded modules by the new setup.py script added in Python 2.1.  If'        ; \
echo '# youre on a platform that doesnt support dynamic loading, want to'          ; \
echo '# compile modules statically into the Python binary, or need to'             ; \
echo '# specify some odd set of compiler switches, you can uncomment the'          ; \
echo '# appropriate lines below.'                                                  ; \
echo '# ======================================================================'    ; \
echo '# The Python symtable module depends on .h files that setup.py doesnt track' ; \
echo '_symtable symtablemodule.c'                                                  ; \
echo '# Uncommenting the following line tells makesetup that all following'        ; \
echo '# modules are to be built as shared libraries (see above for more'           ; \
echo '# detail; also note that *static* or *disabled* cancels this effect):'       ; \
echo '#*shared*' ; \
echo '# GNU readline.  Unlike previous Python incarnations, GNU readline is'       ; \
echo '# now incorporated in an optional module, configured in the Setup file'      ; \
echo '# instead of by a configure script switch.  You may have to insert a'        ; \
echo '# -L option pointing to the directory where libreadline.* lives,'            ; \
echo '# and you may have to change -ltermcap to -ltermlib or perhaps remove'       ; \
echo '# it, depending on your system -- see the GNU readline instructions.'        ; \
echo '# Its okay for this to be a shared library, too.'                            ; \
echo 'readline readline.c -lreadline -ltermcap'                                    ; \
echo '# Modules that should always be present (non UNIX dependent):'               ; \
echo 'array arraymodule.c                                                       # array objects'                        ; \
echo 'cmath cmathmodule.c _math.c -lm                                           # complex math library functions'       ; \
echo 'math mathmodule.c _math.c   -lm                                           # math library functions, e.g. sin()'   ; \
echo '_contextvars _contextvarsmodule.c                                         # Context Variables'                    ; \
echo '_struct _struct.c                                                         # binary structure packing/unpacking'   ; \
echo '_weakref _weakref.c                                                       # basic weak reference support'         ; \
echo '_random _randommodule.c                                                   # Random number generator' ; \
echo '_elementtree -I$(srcdir)/Modules/expat -DHAVE_EXPAT_CONFIG_H -DUSE_PYEXPAT_CAPI _elementtree.c # elementtree accelerator' ; \
echo '_pickle _pickle.c                                                         # pickle accelerator'      ; \
echo '_datetime _datetimemodule.c                                               # datetime accelerator'    ; \
echo '_bisect _bisectmodule.c                                                   # Bisection algorithms'    ; \
echo '_heapq _heapqmodule.c                                                     # Heap queue algorithm'    ; \
echo '_asyncio _asynciomodule.c                                                 # Fast asyncio Future'     ; \
echo '_json -I$(srcdir)/Include/internal -DPy_BUILD_CORE_BUILTIN _json.c        # _json speedups'          ; \
echo '_statistics _statisticsmodule.c # statistics accelerator'                 ; \
echo 'unicodedata unicodedata.c                                                 # static Unicode character database' ; \
echo '# Modules with some UNIX dependencies -- on by default:'                  ; \
echo '# (If you have a really backward UNIX, select and socket may not be'      ; \
echo '# supported...)'                                                          ; \
echo 'fcntl fcntlmodule.c                                                       # fcntl(2) and ioctl(2)'              ; \
echo 'spwd spwdmodule.c                                                         # spwd(3)'                            ; \
echo 'grp grpmodule.c                                                           # grp(3)'                             ; \
echo 'select selectmodule.c                                                     # select(2); not on ancient System V' ; \
echo '# Memory-mapped files (also works on Win32).'                             ; \
echo 'mmap mmapmodule.c'                                                        ; \
echo '# CSV file helper'                                                        ; \
echo '_csv _csv.c'                                                              ; \
echo '# Socket module helper for socket(2)'                                     ; \
echo '_socket socketmodule.c'                                                   ; \
echo '# Socket module helper for SSL support; you must comment out the other'   ; \
echo '# socket line above, and possibly edit the SSL variable:'                 ; \
echo 'SSL=/usr/local/ssl'                                                       ; \
echo '_ssl _ssl.c -DUSE_SSL -I$(SSL)/include -I$(SSL)/include/openssl -L$(SSL)/lib -lssl -lcrypto' ; \
echo '# The crypt module is now disabled by default because it breaks builds'   ; \
echo '# on many systems (where -lcrypt is needed), e.g. Linux (I believe).'     ; \
echo '_crypt _cryptmodule.c -lcrypt                                             # crypt(3); needs -lcrypt on some systems' ; \
echo '# Some more UNIX dependent modules -- off by default, since these'        ; \
echo '# are not supported by all UNIX systems:'                                 ; \
echo 'nis nismodule.c -lnsl                                                     # Sun yellow pages -- not everywhere' ; \
echo 'termios termios.c                                                         # Steen Lumholts termios module'      ; \
echo 'resource resource.c                                                       # Jeremy Hyltons rlimit interface'    ; \
echo '_posixsubprocess _posixsubprocess.c  # POSIX subprocess module helper'    ; \
echo '# Multimedia modules -- off by default.'                                  ; \
echo '# These dont work for 64-bit platforms!!!'                                ; \
echo '# #993173 says audioop works on 64-bit platforms, though.'                ; \
echo '# These represent audio samples or images as strings:'                    ; \
echo '#audioop audioop.c                                                        # Operations on audio samples' ; \
echo '# Note that the _md5 and _sha modules are normally only built if the'     ; \
echo '# system does not have the OpenSSL libs containing an optimized version.' ; \
echo '# The _md5 module implements the RSA Data Security, Inc. MD5'             ; \
echo '# Message-Digest Algorithm, described in RFC 1321.'                       ; \
echo '_md5 md5module.c'                                                         ; \
echo '# The _sha module implements the SHA checksum algorithms.'                ; \
echo '# (NISTs Secure Hash Algorithms.)'                                        ; \
echo '_sha1 sha1module.c'                                                       ; \
echo '_sha256 sha256module.c'                                                   ; \
echo '_sha512 sha512module.c'                                                   ; \
echo '_sha3 _sha3/sha3module.c'                                                 ; \
echo '# _blake module'                                                          ; \
echo '_blake2 _blake2/blake2module.c _blake2/blake2b_impl.c _blake2/blake2s_impl.c' ; \
echo '# Lance Ellinghauss syslog module'                                            ; \
echo 'syslog syslogmodule.c                                                     # syslog daemon interface' ; \
echo '# Curses support, requiring the System V version of curses, often'        ; \
echo '# provided by the ncurses library.  e.g. on Linux, link with -lncurses'   ; \
echo '# instead of -lcurses).'                                                  ; \
echo '_curses _cursesmodule.c -lcurses -ltermcap'                               ; \
echo '# Wrapper for the panel library thats part of ncurses and SYSV curses.'   ; \
echo '_curses_panel _curses_panel.c -lpanel -lncurses'                          ; \
echo '# Modules that provide persistent dictionary-like semantics.  You will'   ; \
echo '# probably want to arrange for at least one of them to be available on'   ; \
echo '# your machine, though none are defined by default because of library'    ; \
echo '# dependencies.  The Python module dbm/__init__.py provides an'           ; \
echo '# implementation independent wrapper for these; dbm/dumb.py provides'     ; \
echo '# similar functionality (but slower of course) implemented in Python.'    ; \
echo '#_dbm _dbmmodule.c                                                        # dbm(3) may require -lndbm or similar' ; \
echo '# Anthony Baxters gdbm module.  GNU dbm(3) will require -lgdbm:'          ; \
echo '_gdbm _gdbmmodule.c -I/usr/local/include -L/usr/local/lib -lgdbm'         ; \
echo '# Helper module for various ascii-encoders'                               ; \
echo 'binascii binascii.c'                                                      ; \
echo '# Fred Drakes interface to the Python parser'                             ; \
echo 'parser parsermodule.c'                                                    ; \
echo '# Andrew Kuchlings zlib module.'                                          ; \
echo '# This require zlib 1.1.3 (or later).'                                    ; \
echo '# See http://www.gzip.org/zlib/'                                          ; \
echo 'zlib zlibmodule.c -I$(prefix)/include -L$(exec_prefix)/lib -lz'           ; \
echo '# Interface to the Expat XML parser'                                      ; \
echo '# More information on Expat can be found at www.libexpat.org.'            ; \
echo 'pyexpat expat/xmlparse.c expat/xmlrole.c expat/xmltok.c pyexpat.c -I$(srcdir)/Modules/expat -DHAVE_EXPAT_CONFIG_H -DXML_POOR_ENTROPY -DUSE_PYEXPAT_CAPI' ; \
echo '# Another example -- the xxsubtype module shows C-level subtyping in action'  ; \
echo 'xxsubtype xxsubtype.c'                                                        ; \
echo '# Uncommenting the following line tells makesetup that all following modules' ; \
echo '# are not built (see above for more detail).'                                 ; \
echo '#*disabled*'                                                                  ; \
echo '#_sqlite3 _tkinter _curses pyexpat'                                           ; \
echo '#_codecs_jp _codecs_kr _codecs_tw unicodedata'                                ; \
echo '_lzma _lzmamodule.c -llzma' ; \
echo '_bz2 _bz2module.c   -lbz2'  ; \
echo '#_sqlite3' ; \
) | tee Modules/Setup
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
