/*
 * windows platform specific defintions
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
// #include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>

#define S_ISREG(m) (m & _S_IFREG)
#define S_ISLNK(m)  0
#define S_ISDIR(m) (m & _S_IFDIR)
#define S_IXUSR 0777777
#define S_IXGRP 0777777
#define S_IXOTH 0777777
#define PATH_MAX    1024
#define R_OK        4
#define lstat stat
#define readlink(a,b,c) 