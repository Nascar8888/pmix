# -*- shell-script -*-
#
# Copyright (c) 2009-2013 Cisco Systems, Inc.  All rights reserved. 
# Copyright (c) 2013      Los Alamos National Security, LLC.  All rights reserved. 
# Copyright (c) 2013-2014 Intel, Inc. All rights reserved
# $COPYRIGHT$
# 
# Additional copyrights may follow
# 
# $HEADER$
#

# MCA_hwloc_CONFIG([action-if-found], [action-if-not-found])
# --------------------------------------------------------------------
AC_DEFUN([PMIX_HWLOC_CONFIG],[

    PMIX_VAR_SCOPE_PUSH([pmix_hwloc_support pmix_hwloc_dir pmix_hwloc_libdir])

    AC_ARG_WITH([hwloc],
                [AC_HELP_STRING([--with-hwloc=DIR],
                                [Search for hwloc headers and libraries in DIR ])])

    AC_ARG_WITH([hwloc-libdir],
                [AC_HELP_STRING([--with-hwloc-libdir=DIR],
                                [Search for hwloc libraries in DIR ])])

    pmix_hwloc_support=0
    if test $pmix_dist_enabled != 1; then
        AC_MSG_CHECKING([for hwloc in])
        if test ! -z "$with_hwloc" -a "$with_hwloc" != "yes"; then
            pmix_hwloc_dir=$with_hwloc
            if test -d $with_hwloc/lib; then
                pmix_hwloc_libdir=$with_hwloc/lib
            elif -d $with_hwloc/lib64; then
                pmix_hwloc_libdir=$with_hwloc/lib64
            else
                AC_MSG_RESULT([Could not find $with_hwloc/lib or $with_hwloc/lib64])
                AC_MSG_ERROR([Can not continue])
            fi
            AC_MSG_RESULT([$pmix_hwloc_dir and $pmix_hwloc_libdir])
        else
            AC_MSG_RESULT([(default search paths)])
        fi
        AS_IF([test ! -z "$with_hwloc_libdir" && test "$with_hwloc_libdir" != "yes"],
              [pmix_hwloc_libdir="$with_hwloc_libdir"])

        PMIX_CHECK_PACKAGE([pmix_hwloc],
                           [hwloc.h],
                           [hwloc],
                           [hwloc_topology_dup],
                           [-lhwloc],
                           [$pmix_hwloc_dir],
                           [$pmix_hwloc_libdir],
                           [pmix_hwloc_support=1],
                           [pmix_hwloc_support=0])
        if test $pmix_hwloc_support == "1"; then
            CPPFLAGS="$pmix_hwloc_CPPFLAGS $CPPFLAGS"
            LIBS="$LIBS -lhwloc"
            LDFLAGS="$pmix_hwloc_LDFLAGS $LDFLAGS"
        fi
    fi

    if test ! -z "$with_hwloc" && test "$with_hwloc" != "no" && test "$pmix_hwloc_support" != "1"; then
        AC_MSG_WARN([HWLOC SUPPORT REQUESTED AND NOT FOUND. PMIX HWLOC])
        AC_MSG_WARN([SUPPORT REQUIRES A MINIMUM OF VERSION 1.9.1])
        AC_MSG_ERROR([CANNOT CONTINUE])
    fi

    AC_MSG_CHECKING([can hwloc support be built])
    if test "$pmix_hwloc_support" != "1"; then
        AC_MSG_RESULT([no])
    else
        AC_MSG_RESULT([yes])
    fi
    
    AC_DEFINE_UNQUOTED(PMIX_HAVE_HWLOC, [$pmix_hwloc_support],
                      [Whether we have hwloc support or not])

    PMIX_VAR_SCOPE_POP
])dnl
