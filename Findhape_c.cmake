# cnt
# coe
# err
# fmt
# io
# mem

find_library(
	HAPE_CNT_LIB 
	NAMES cnt 
	PATHS 	"C:/Program Files/hape_c/lib"
			"C:/Program Files (x86)/hape_c/lib")

find_library(
	HAPE_ERR_LIB
	NAMES err 
	PATHS 	"C:/Program Files/hape_c/lib"
			"C:/Program Files (x86)/hape_c/lib")
			
find_library(
	HAPE_FMT_LIB
	NAMES fmt 
	PATHS 	"C:/Program Files/hape_c/lib"
			"C:/Program Files (x86)/hape_c/lib")
			
find_library(
	HAPE_IO_LIB
	NAMES io
	PATHS 	"C:/Program Files/hape_c/lib"
			"C:/Program Files (x86)/hape_c/lib")
			
find_library(
	HAPE_MEM_LIB
	NAMES mem
	PATHS 	"C:/Program Files/hape_c/lib"
			"C:/Program Files (x86)/hape_c/lib")


find_path(
	HAPE_INCLUDE
	NAMES 	"cnt.h"
	HINTS	include/hape 
	PATHS 	"C:/Program Files/hape_c/include/hape"
	 		"C:/Program Files (x86)/hape_c/include/hape"
	 		"/usr/local/include/hape" )			