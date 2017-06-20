# Spartan Linux

A Linux kernel with statically-compiled Busybox & Dropbear userspace. Supported targets:

- [x86_64-generic](targets/x86_64-generic)
- [i386-generic](targets/i386-generic)

Prerequisites:

- *nix environment (make, wget, tar, patch, etc),
- gperf, help2man & other [crosstool-ng](http://crosstool-ng.github.io/) dependencies,
- anything extra that a specific target requires.

Building:

```
$ make -j8 TARGET=x86_64-generic
```

See target-specific README for extra assembly instructions.
