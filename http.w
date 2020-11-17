@* http.

@* File Structure.

@ Main Program.

@c
@<include...@>@;
@<decl...@>@;
@<type decl...@>@;
@<local functions@>@;
int
main (int argc, char *const *argv)
{
  struct MHD_Daemon *d;
  assert( MHD_is_feature_supported(MHD_FEATURE_MESSAGES));
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
                        @<accept policy callback...@>@|                        
                        @<http request...@>@|
                        @<http options@>@|
                        @<logging options@>@|
                        MHD_OPTION_END);
  if (d == NULL)
    return 1;
  (void) getc (stdin);
  MHD_stop_daemon (d);
  return 0;
}

@ library
@(dummy.c@>=
@<include...@>@;
@<decl...@>@;
@<library helper functions@>@;
@<library functions@>@;

@ @<include files@>=
#include "platform.h"
#include <microhttpd.h>
#include <assert.h>
#include <stdbool.h>

@ @<initialize request local data@>=
if (&aptr != *ptr)
{
  /* do never respond on first call */
  *ptr = &aptr;
  return MHD_YES;
}


@* declarations.

@<declarations of functions@>=
enum MHD_Result
cb_request (void *cls,
          struct MHD_Connection *connection,
          const char *url,
          const char *method,
          const char *version,
          const char *upload_data,
          size_t *upload_data_size, void **ptr);
void logger(void *cls,
                   const char *fm,
                   va_list ap);
@
@<type declarations@>=
typedef struct _Request * Request;

@
@<accept policy callback option@>=
NULL , NULL,

@
@<http request callback option@>=
&cb_request , NULL,

@
@<http options@>=
MHD_OPTION_CONNECTION_TIMEOUT, 256,


@ Define HTTPS related options. The key and a certificate needs to be set.
@<https specific options@>=
MHD_OPTION_HTTPS_MEM_KEY, key_pem,
MHD_OPTION_HTTPS_MEM_CERT, cert_pem,

@ @<logging options@>=
MHD_OPTION_EXTERNAL_LOGGER, logger, &argv,

@ @<library functions@>=
void logger(void *cls, const char *fm, va_list ap){
    fprintf(stderr, "!!!!! ");
    vfprintf(stderr, fm, ap);
    fprintf(stderr, "\n");
}




@*processing.

@
@<try open file@>=

  FILE *file = fopen (&url[1], "rb");
  struct stat buf;
  if (NULL != file)
  {
    int fd = fileno (file);
    if (-1 == fd)
    {
      fclose (file);
      file = NULL;
    }
    else if ( (0 != fstat (fd, &buf)) ||
         (! S_ISREG (buf.st_mode)) )
    {
      /* not a regular file, refuse to serve */
      fclose (file);
      file = NULL;
    }
  }


@ respond with data in file by using callbacks for data and for cleanup.
@<respond page from file content@>=
status_code = MHD_HTTP_OK;
response = MHD_create_response_from_callback (buf.st_size, 32 * 1024,       /* 32k  size */
                                                  &file_reader, file,
                                                  &file_free_callback);
@ file callback
@<library functions@>=
static ssize_t
file_reader (void *cls, uint64_t pos, char *buf, size_t max)
{
  FILE *file = cls;

  (void) fseek (file, pos, SEEK_SET);
  return fread (buf, 1, max, file);
}

@ file cleanup callback
@<library functions@>=
static void
file_free_callback (void *cls)
{
  fclose ((FILE*)cls);
}


@
@<respond static page@>=
response = MHD_create_response_from_buffer (    strlen (page),
                                                (void *) page,
                                                MHD_RESPMEM_PERSISTENT);
@ @<library functions@>=
enum MHD_Result print_key_value(void *cls,
                         enum MHD_ValueKind kind,
                         const char *key,
                         const char *value){
  fprintf(stderr, "*** %d:%s:%s\n", kind, key, value);                         
  return MHD_YES;
}

@ @<check for allowed method@>=
  if ( (0 != strcmp (method, MHD_HTTP_METHOD_GET)) &&
       (0 != strcmp (method, MHD_HTTP_METHOD_HEAD)) )
    return MHD_NO;              /* unexpected method */
@ @<log request info@>=
  fprintf(stderr, "ECHO url:%s\n method:%s\n", url, method);
  fprintf(stderr, "   upload data size: %d\n", *upload_data_size);
  MHD_get_connection_values(connection, 
                MHD_HEADER_KIND | MHD_COOKIE_KIND | MHD_POSTDATA_KIND | MHD_FOOTER_KIND, 
                print_key_value, NULL);

@ @<library functions@>=
enum MHD_Result
post_iterator (void *cls,
               enum MHD_ValueKind kind,
               const char *key,
               const char *filename,
               const char *content_type,
               const char *transfer_encoding,
               const char *data, uint64_t off, size_t size)
{
  struct Request *request = cls;

  fprintf(stderr, "### %s\n", key);
  return MHD_YES;
}

@ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@<local functions@>=
static void
request_completed_callback (void *cls,
                            struct MHD_Connection *connection,
                            void **con_cls,
                            enum MHD_RequestTerminationCode toe)
{
  (void) cls;         /* Unused. Silent compiler warning. */
  (void) connection;  /* Unused. Silent compiler warning. */
  (void) toe;         /* Unused. Silent compiler warning. */
  fprintf(stderr, "end of request\n");
}


@ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@<library functions@>=
enum MHD_Result
cb_request (void *cls,
          struct MHD_Connection *connection,
          const char *url,
          const char *method,
          const char *version,
          const char *upload_data,
          size_t *upload_data_size, void **ptr)
{
  static char *page = "{\"data\":1}";
  static int aptr;
  struct MHD_Response *response = NULL;
  int ret;
  unsigned int status_code = MHD_HTTP_NOT_IMPLEMENTED;
  
  @<log request info@>@;

  if ( (0 == strcmp (method, MHD_HTTP_METHOD_POST)) ) {
    fprintf(stderr, "Upload data size: %d\n", *upload_data_size);
    if( *upload_data_size == 0)
        return MHD_YES; 
    else{
      fprintf(stderr, "CONTENT: ");
      for(int i= 0;i<*upload_data_size;i++){
        fprintf(stderr, "%02x ", upload_data[i]);
      }
      for(int i= 0;i<*upload_data_size;i++){
        fprintf(stderr, "%c", upload_data[i]);
      }
      fprintf(stderr, " %p\n", response);
      const char *xpage = "XXX";
      if(false)
          response = MHD_create_response_from_buffer(   *upload_data_size,
                                                        (void*)upload_data,
                                                        MHD_RESPMEM_MUST_COPY);
      else
          response = MHD_create_response_from_buffer(   strlen(xpage),
                                                        (void*)xpage,
                                                        MHD_RESPMEM_MUST_COPY);
      MHD_add_response_header (response,
                           MHD_HTTP_HEADER_CONTENT_ENCODING,
                           "application/json");
      if(false)
          *upload_data_size = 0;
      status_code = MHD_HTTP_OK;
      ret = MHD_queue_response (connection, status_code, response);
      fprintf(stderr, "x queued response %d -> %d\n", status_code, ret);  
      MHD_destroy_response (response);
      return MHD_YES;
    }
  }
  if(response == NULL){
    @<try open file@>@;
    if(file) {
      @<respond page from file content@>@;
    }
  }
  if(response == NULL) {
    @<respond static page@>@;
  }
  fprintf(stderr, "response %p\n", response);
  ret = MHD_queue_response (connection, status_code, response);
  fprintf(stderr, "queued response %d -> %d\n", status_code, ret);  
  MHD_destroy_response (response);
  return ret;
}

@ @<library helper functions@>=
/* empty */

@ @<local functions@>=
/* empty */

@*INDEX.
