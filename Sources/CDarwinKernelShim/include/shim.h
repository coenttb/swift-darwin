#ifndef CDARWIN_SHIM_H
#define CDARWIN_SHIM_H

#if defined(__APPLE__)

#include <sys/mman.h>
#include <sys/types.h>
#include <fcntl.h>
#include <dlfcn.h>

// shm_open is declared as variadic in Darwin's sys/mman.h:
//   int shm_open(const char *, int, ...);
// This makes it unavailable to Swift.
// We provide a non-variadic wrapper.

static inline int swift_shm_open(const char *name, int oflag, mode_t mode) {
    return shm_open(name, oflag, mode);
}

// Darwin-only dynamic library loading flags.
// RTLD_MAIN_ONLY and RTLD_FIRST are Darwin-specific and not available on Linux.

static inline void *swift_RTLD_MAIN_ONLY(void) {
    return RTLD_MAIN_ONLY;
}

static inline int32_t swift_RTLD_FIRST(void) {
    return RTLD_FIRST;
}

#endif /* __APPLE__ */

#endif /* CDARWIN_SHIM_H */
