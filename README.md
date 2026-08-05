# Dæmon Saigo Native Client SDK

[![GitHub tag](https://img.shields.io/github/release/DaemonEngine/saigo-release-scripts.svg)](https://github.com/DaemonEngine/saigo-release-scripts/releases/latest)  
[![Web](https://img.shields.io/badge/web-unvanquished.net-ffaaaa)](https://forums.unvanquished.net)
[![Forums](https://img.shields.io/badge/forums-forums.unvanquished.net-ffaaaa)](https://forums.unvanquished.net)
[![Wiki](https://img.shields.io/badge/wiki-wiki.unvanquished.net_%E2%80%A3_Native_Client-ffaaaa)](https://wiki.unvanquished.net/wiki/Native_Client)
[![Wiki](https://img.shields.io/badge/wiki-%E2%80%A3_Dæmon_Saigo_SDK-ffaaaa)](https://wiki.unvanquished.net/wiki/Tools/Saigo)  
[![Rules](https://img.shields.io/badge/chat-rules-ffdd00)](https://wiki.unvanquished.net/wiki/Chat#Rules)
[![IRC](https://img.shields.io/badge/irc-%23unvanquished%2C%23unvanquished--dev-9cf.svg)](https://unvanquished.net/chat/)
[![Matrix](https://img.shields.io/badge/matrix-Unvanquished-9cf?logo=matrix)](https://matrix.to/#/!WnuetRiQZJNBTKwMrF:matrix.org?via=matrix.org)
[![Discord](https://img.shields.io/badge/discord-Unvanquished-9cf?logo=discord)](https://discord.gg/usuDT9Pyna)

The Dæmon Saigo project makes possible to rebuild the Native Client Software Development Kit for usage with the [Dæmon game engine](https://github.com/DaemonEngine/Daemon).
Chromium development tools are **<ins>NOT</ins>** required to build.

Saigo is a modern toolchain for compiling and debugging Native Client applications.
Google never compiled the Saigo software development kit for something else than Linux on amd64,
and their build process relied on a very complex collection of repositories involving the execution of prebuilt binaries.
This project not only makes possible to rebuild Saigo for your preferred system and architecture,
but does it without running any shady precompiled executable provided by Google.

Native Client (also known as NaCl) is a sandboxing technology by Google.
It was used by Chrome extensions and Chrome apps.
The Dæmon engine is the open-source game engine powering the [Unvanquished game](https://unvanquished.net),
it uses Native Client to securely and portably run downloadable compiled games.
The Dæmon Game Engine isn't based on Chromium so the removal of NaCl in Chromium technologies doesn't remove NaCl in Dæmon.

Google publicly announced [in May of 2017](https://blog.chromium.org/2017/05/goodbye-pnacl-hello-webassembly.html)
the (then-)upcoming deprecation and abandonment of Native Client technologies in favor of WebAssembly in their own products.
They announced the actual deprecation [in 2020](https://developer.chrome.com/deprecated).
But Google also [supported](https://developer.chrome.com/docs/native-client) Native Client-powered ChromeOS 138 until ChromeOS 139 [in July of 2025](https://support.google.com/chrome/a/answer/10314655?&#139) and as such continued development of some Native Client technologies.
This extra development materialized in the maintenance of the loader and a toolchain named Saigo,
frequently rebased on the latest LLVM upstream at the time.
The runtime received commits from Google [until April of 2025](https://chromium.googlesource.com/native_client/src/native_client.git/+/e3fce84f253bc1e77bb239185c0fbff23dc8e3ee),
while Saigo received commits from Google [until January of 2025](https://chromium.googlesource.com/native_client/nacl-llvm-project-v10/+/9c7f0369cfdd591e580c5ccfc1f00fedee58029f) and the last rebase was over Clang 21.

In Japanese, _Saigo_ (さいご / 最後) means “_the last_”, “_the end_”, “_the final_” or “_the conclusion_”. This refers to the end of an era, the final stage of an event, or the last item in a sequence…

Nothing about Native Client should be expected from Google anymore.


## Sources

The present repository doesn't contain the Saigo code, it provides scripts and patches to build Saigo using Google upstream repositories.
This project also ships with the compilers and debugger some NaCl C/C++ headers historically stored in the runtime repository:

- [chromium.googlesource.com/native_client/nacl-llvm-project-v10](https://chromium.googlesource.com/native_client/nacl-llvm-project-v10) (Saigo NaCl Clang)
- [chromium.googlesource.com/native_client/nacl-binutils](https://chromium.googlesource.com/native_client/nacl-binutils) (NaCl Binutils)
- [chromium.googlesource.com/native_client/nacl-gdb](https://chromium.googlesource.com/native_client/nacl-gdb) (NaCl GDB)
- [github.com/DaemonEngine/native_client](https://github.com/DaemonEngine/native_client) (NaCl headers)

Patches are provided (stored in the present repository in the [`patches/`](patches/) directory) that CMake automatically applies over source repositories before building the software.
Those patches keep the tools buildables, improve cross-platform support (buildable for more systems and architectures), and reduce the build and runtime dependencies.

The related project to rebuild the Native Client runtime (including the NaCl loader) can be found there:

- [github.com/DaemonEngine/native_client](https://github.com/DaemonEngine/native_client)

That other project makes possible to rebuild the NaCl runtime with our own fixed and without Google's complex collection of repositories and without shady Google's precompiled binaries.
The Dæmon NaCl runtime isn't distributed with the Dæmon Saigo NaCl SDK as they both have their own release schedule.


## Status

Component|Status
-|-
Saigo native Clang|✅️ Rebuilt from scratch
Saigo native Binutils|✅️ Rebuilt from scratch
Saigo native GDB|✅️ Rebuilt from scratch
Saigo nexe libc|☑️ Repackaged
Saigo nexe libc++|☑️ Repackaged

It is now possible to rebuild the compiler binaries (the NaCl Saigo Clang and related Binutils),
and to do it for more platforms than initially supported by Google.

The compiler binaries have been successfully built for:

Architecture|Linux|Windows|macOS|FreeBSD
-|-|-|-|-
amd64|✅️|✅️|✅️|✅️
i686|✅️|✅️||✅️
arm64|✅️||✅️
armhf|✅️
ppc64el|✅️
riscv64|✅️
loong64|✅️

This is only about running the compilers natively to compile NaCl code (and related tools), the NaCl runtime for actually running NaCl code has stricter limitations.

The Windows build is meant to be cross-compiled from Linux using MinGW.

For now, the libc and libc++ libraries are copied from pre-compiled libraries provided by Google.
The libc is based on [Newlib](https://www.sourceware.org/newlib/).

Those libraries only contribute to untrusted binaries that run inside in the untrusted environment within the Native Client virtual machine,
meaning no pre-compiled code runs in the trusted environement outside of the Native Client sandbox.

In doing so this project already achieved the ability for someone to be able to recompile all the trusted code to not have to trust any precompiled code.

The toolchain being buildable for some platforms only means it's possible to run the toolchain on those platforms to produce Native Client executables (nexe),
it doesn't mean those Native Client executable will run on those platforms.
Running Native Client executables on new platforms would require new code in both the toolchain and the runtime and this is not planned.

On platforms that can run the loader under some compatibility mode (like running 32-bit loader on 64-bit environment,
or Linux running [box64](https://box86.org),
or macOS running the amd64 loader through Rosetta 2 on arm64,
or FreeBSD running the Linux loader on Linuxulator,
it means it makes possible to have a fully native toolchain to produce NaCl binaries on the same platforms.


## Systems

The suported operating systems to build the Saigo toolchain on are Linux, FreeBSD and macOS.
Building for Windows is done on Linux through cross-compilation.

Here are the systems you need to build Saigo for specific systems:

Target system|Build system|Compiler
-|-|-
Linux|Linux|GCC
Windows|Linux|MinGW
macOS|macOS|AppleClang
FreeBSD|FreeBSD|Clang

The release build script will select the compiler for you: for example it will use GCC when building Linux binaries even when Clang is installed.


## Build requirements

Those build scripts and CMake configuration are only tested in Unix-like environment.
Along Git, CMake and Make, the Bash shell, standard Coreutils and usual Unix utilities (Sed, Awk, Tar, Xz) are required.

The prerequisites are cumulatives.

CMake script:

- `cmake`
- `make` (GNU or obsolete Apple Make)
- `git`
- A C/C++ compiler collection for the target, the following ones are supported:
  * `gcc`/`g++` (GNU or MinGW GCC)
  * `clang`/`clang++` (LLVM or Apple Clang)

Release build script:

- `sed` (GNU or BSD Sed)
- `awk` (GNU or BSD Awk)
- `bash` (GNU or obsolete Apple Bash)

Release packaging script

- `tar` (GNU or BSD Tar)
- `xz`
- `jdupes` or `rdfind` from [jdupes](http://www.jdupes.com) or [Rdfind](https://rdfind.pauldreik.se)  
   Optional, but recommended to deduplicate tarball content before packaging.

Recommended:

- `ccache` from [CCache](https://ccache.dev)  
  Can save recompilation time when restarting a build.  
  It can be used with `icecc` from [IceCC](https://github.com/icecc/icecream) to distribute the build when present.
- `ninja` from [Ninja](https://ninja-build.org)  
  May be faster than Make, will be used for building LLVM when present.
- `mold` from [mold](https://github.com/rui314/mold)  
  May be faster than usual linkers, will be used when present.

CMake will automatically use those tools when found in `PATH`.

CMake will clone the source repositories (LLVM, Binutils, GDB…) using Git and will automatically apply the patches.

CMake will run `configure`, `make` and `ninja` commands automatically for you.
The release scripts will run `cmake` for you.

Even when providing CMake and Ninja, Make will be used for building Binutils as the building of Binutils and GDB uses autotools and requires Make.

CMake will also clean-up at the end of the build process the useless stuff built with LLVM, Binutils and GDB that their respective build systems could not disable, to keep the package small.


### No dependencies

No libraries other than the C and C++ libraries are required to build and run the Saigo SDK on Linux, macOS and FreeBSD.

Windows builds are statcically linked, not requiring any MinGW library.

Special efforts have been made to make sure the NaCl GDB only requires the `libc`.
For example a `mini-termcap` has been implemented and integrated to remove the dependency on `libncurses` and `libtinfo` on Unix-like systems.

Unlike Google's prebuilt `nacl-gdb`, a build of the Dæmon Saigo GDB will not break because your system isn't the one used to build it.
The same is true for the whole Saigo SDK.


## Build instructions

### CMake simple build

```
mkdir build && cd build
cmake ..
make -j8
```

The Saigo SDK can then be found in `build/install`.

The build of Binutils and GDB relies on autotools `configure` scripts and GNU Make, so `gmake` has to be used instead of `make` on BSD systems.

Replace the `8` job count with the amount of cores your computer provides.
Rebuilding Clang requires a powerful computer, as compilation is large and slow.

Building LLVM may require 8GB per link task, especially when building it with LTO enabled, so you may prefer to use `<RAM available in GB>/8` as job count.

The provided CMake script driving the compilation of all Saigo components will delete useless files after compilation and replace known duplicates with symbolinc links.

One can clean the build (including the deletion of the `install/` directory) with:

```
make distclean
```

This runs the standard `make clean` action to clean-up temporary build files, resets the build progression, and deletes the `install/` directory where things have been installed.


### Release multi-build

Using the `tools/release/build` helper only clones repositories once and then saves a lot of time and file space.

It is highly recommended to share the repository over the network accross all the build machine to let the build tasks reuse things as much as possible.

On Linux:

```
tools/release/build \
  linux-amd64 linux-i686 linux-arm64 linux-armhf \
  linux-ppc64el linux-riscv64 linux-loong64 \
  windows-amd64 windows-i686
```

On macOS:

```
tools/release/build macos-amd64 macos-arm64
```

On FreeBSD:

```
tools/release/build freebsd-amd64 freebsd-i686
```

The configuration for the targets is stored in the `tools/release/conf/` directory.

The build directory will be `build/<target>/` and the built files will be `build/<target>/install/`.

For building targets using LTO, one can do:

```
USE_LTO=ON tools/release/build <targets>
```

Beware that building using  LTO is much slower and can require crazy amount of RAM.
To prevent the kernel to trigger the OOM killer and to preserve your precious uptime, the `build` helper selects the job count accordingly to both CPU core availables and memory available.

The `build` task makes heavy usage of symbolic links to deduplicates file (see above).

An extra `tools/release/configure` helper is also provided to make possible to configure a build, but not build it.
This allows developers to just rebuild a specific target from scratch, while still using the release environment.
It takes the same arguments as the `tools/release/build` helper, but stops before building anything.
It is left to the developer to know how to build arbitrary CMake targets.


### Release multi-packaging

Packaging requires the Release multi build helper to be used first.

```
tools/release/package \
  linux-amd64 linux-arm64 linux-armhf linux-i686 \
  linux-ppc64el linux-riscv64 linux-loong64 \
  windows-amd64 windows-i686 \
  macos-amd64 macos-arm64 \
  freebsd-amd64 freebsd-i686
```

The packaged archives will be found in the `build/packages/saigosdk_version-<commit date>` directory, and the archives will be named `saigosdk-<target>_version-<commit date>.tar.xz`, along with a checksum file.

The `package` task will use `jdupes` or `rdfind` (if present) to deduplicate files even more using hard links before storing them in the tarball.

All symbolink links are turned into hardlinks in the Windows tarballs to both provide an efficient storage and make sure files are extracted as real files and not as broken links on Windows.

The `package` helper can run on a different system than the one having run the `build` one.

### Release multi-cleaning

This runs the custom `make distclean` action (see above).

```
tools/release/clean <targets>
```

The `clean` helper should run on the same system having run the `build` one.

## History

History of NaCl toolchains, from newer to older (only the latest version of them being mentionned):

- Dæmon Saigo Clang (LLVM 21)
- Google Saigo Clang (LLVM 21)
- Google PNaCl Clang (LLVM 3.6)
- Google NaCl GCC (GCC 4.4.3)

The Google Saigo toolchain compiler is based on Clang and had been frequently rebased over the latest LLVM, bringing the latest Clang and latest C++ standards to NaCl at the time.
Google Saigo Clang has not been updated since January of 2025.
A patch is provided to support the GCC LTO Auto option.
It is to build Saigo Clang using LTO, not to use LTO when building NaCl nexe executables with Saigo Clang.

The Saigo toolchain also requires a special branch of GNU Binutils which hasn't been updated since November of 2014.
Patches are provided to keep it buildable on modern systems and with modern compilers,
and to make it buildable for more architectures and for more systems like Windows when building with MinGW, Linux on RISC-V, or macOS on Apple Silicon.

The same happens with GDB that hasn't been updated by Google since January of 2014.
Patches are provided to keep it buildable today, to make it buildable on more systems, and to reduce the build and run time dependencies.

The lastest version of Saigo is based on LLVM Clang 21 and as such are expected C23 support and likely C2y partial draft support, C++23 support and likely C++2c partial draft support.

The libc++ is the one from the same LLVM Saigo is based on, and should be easy to build.
Unfortunately building some parts of the libc still requires the old NaCl GCC, which is now very old and very hard to build, and Google themselves had given up and did not rebuilt it with their scripts.

Out of convenience, the libc++ and libc is currently packaged from prebuilt packages by Google.
The libc and the libc++ are linked to binaries running in the Native Client virtual machine and as such, never runs outside of the sandbox.

Everything that runs on the trusted machine (your machine) is rebuilt from scratch.
No Google prebuilt binaries will be running on your computer when compiling the Saigo toolchain and when compiling NaCl code with the Saigo toolchain.


## Purpose

Purpose of this project is to provide a way to build native binaries for the toolchain running on developer's computer without:

- using Google-provided binaries to build NaCl code, that means Clang and Binutils are rebuilt from scratch;
- using Google-provided binaries to rebuild the toolchain itself, that means means no Google binaries are used to build Clang and Binutils themselves.

This also allows to run the toolchain on systems not supported by Google.
Google only built Saigo Clang for `linux-amd64`, and Google only built PNaCl Clang for `linux-amd64`, `windows-amd64`, `windows-i686` and `macos-am64`.

While the Saigo toolchain can only build `nexe` applications for `amd64`, `i686` and `armhf`.
While there is no Native Client loaders for other architectures and other systems than Linux, Windows and macOS,
those `nexe` applications and loaders can run on architecture and system variants using compatibility layers.
Those build scripts make possible to build and run a native Saigo toolchain on the same systems the NaCl loader is known to run either natively or through known compatibility layers.

System|Architecture|NaCl runtime|Saigo NaCl SDK
-|-|-|-
Linux|amd64|✅️ native|✅️ native
Linux|i686|✅️ native|✅️ native
Linux|arm64|☑️ compatible (armhf multiarch, box64)|✅️ native
Linux|armhf|✅ native|✅️ native
Linux|ppc64el|☑️ compatible (box64)|✅️ native
Linux|riscv64|☑️ compatible (box64)|✅️ native
Linux|loong64|☑️ compatible (box64, untested)|✅️ native
Windows|amd64|✅️ native|✅️ native
Windows|i686|✅️ native|✅️ native
macOS|amd64|✅️ native|✅️ native
macOS|arm64|☑️ compatible (Rosetta 2)|✅️ native
FreeBSD|amd64|☑️ compatible (Linuxulator)|✅️ native
FreeBSD|i686|☑️ compatible (Linuxulator)|✅️ native

For the nexe libc and libc++, this project repackages the Google pre-compiled libraries in order to reach a minimimum viable product state.
This precompiled code is meant to be executed within the Native Client sandbox and then doesn't require the same level of trust.

Contributions making possible to fully rebuild the libc without any Google-provided binaries is welcome,
but doesn't receive the same priority as providing a fully-rebuildable NaCl compiler toolchain.

Rebuilding the NaCl loader is possible thanks to this other project:

- [github.com/DaemonEngine/native_client](https://github.com/DaemonEngine/native_client)


## Supported nexe target platforms

The supported NaCl targets are:

- `nacl-amd64`
- `nacl-i686`
- `nacl-armhf`

Older PNaCl and older NaCl Binutils could be built for building the `nacl-mipsel` target,
and the NaCl loader can be built for running the `nacl-mipsel` target, but neither Saigo and related Binutils can be built for it.
No prebuilt `nacl-mipsel` libc/libc++ to be used with Saigo has never been distributed by Google.

Unlike PNaCl, Saigo doesn't compile to `pexe` (`nacl-le32`),
so the application code should be rebuilt as `nexe` for every target platform instead of compiling one `pexe` once and translating it to multiple `nexe` after that.
The `pexe` to `nexe` translation being very slow, the iterative rebuild of three targets is faster anyway.

It also means precompiled `pexe` static libraries for various common libraries provided by Google (FreeType, etc.) cannot be used.
Migrating a project from PNaCl to Saigo may then require to rebuild some dependencies.


## Limitations

Unlike early PNaCl, Saigo may not support exceptions.

There are some exception-related files provided there and there with Dæmon Saigo, but the feature have not been seen working.
Exceptions have never been seen working with Google-built Saigo to begin with, neither with some of the most recent PNaCl compilers from Google.
The support for exceptions seems to have been dropped a decade before Google deprecated NaCl in Chromium technologies.

Contributions to restore the exception support will be well appreciated.

Support for `setjmp`/`longjmp` is working.
