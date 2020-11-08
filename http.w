@* http.

@* Include defintions.

@<include files@>=
#include "platform.h"
#include <microhttpd.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_SYS_STAT_H
#include <sys/stat.h>
#endif 
#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif 


@* declarations.

@<declarations of functions@>=
enum MHD_Result
ahc_echo (void *cls,
          struct MHD_Connection *connection,
          const char *url,
          const char *method,
          const char *version,
          const char *upload_data,
          size_t *upload_data_size, void **ptr);

@*main.

@c
@<include...@>@;
@<decl...@>@;

int
main (int argc, char *const *argv)
{
  struct MHD_Daemon *d;

  if (argc != 2)
  {
    printf ("%s PORT\n", argv[0]);
    return 1;
  }
  unsigned int flags = MHD_USE_THREAD_PER_CONNECTION;
  flags |= MHD_USE_INTERNAL_POLLING_THREAD;
  flags |= MHD_USE_ERROR_LOG;

  d = MHD_start_daemon ( flags, @|
                        atoi(argv[1]), @|
                        NULL , NULL,/* accept policy callback */   
                        &ahc_echo , NULL, /* access handler callback */
                        MHD_OPTION_END);
  if (d == NULL)
    return 1;
  (void) getc (stdin);
  MHD_stop_daemon (d);
  return 0;
}

@*processing.

@(dummy.c@>=
@<include...@>@;
@<decl...@>@;

enum MHD_Result
ahc_echo (void *cls,
          struct MHD_Connection *connection,
          const char *url,
          const char *method,
          const char *version,
          const char *upload_data,
          size_t *upload_data_size, void **ptr)
{
    fprintf(stderr, "ECHO url:%s\n method:%s\n", url, method);
    return MHD_NO;
}
@*INDEX.
