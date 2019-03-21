#!/bin/bash

   #===============================================================================================================
   #                                                                                                                                              
   #         FILE: mask_cluster_report.sh /path/to/cluster-report.tar.gz
   #
   #        USAGE: 1) Run it. 
   #			   2) Look for file in same directory as original cluster report called cluster-report-*.masked.tar.gz
   #
   #  DESCRIPTION: Exports all MemSQL stored procedures 
   #      OPTIONS:  
   # REQUIREMENTS: MemSQL
   #       AUTHOR: Mike Czabator (mczabator@memsql.com)
   #      CREATED: 03.21.2010
   #      UPDATED:      
   #      VERSION: 1.0
   #      EUL    : THIS CODE IS OFFERED ON AN “AS-IS” BASIS AND NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS GIVEN. 
   #           THE AUTHOR EXPRESSLY DISCLAIMS ALL WARRANTIES OF ANY KIND, WHETHER EXPRESS OR IMPLIED.
   #           YOU ASSUME ALL RISK ASSOCIATED WITH THE QUALITY, PERFORMANCE, INSTALLATION AND USE OF THE SOFTWARE INCLUDING, 
   #           BUT NOT LIMITED TO, THE RISKS OF PROGRAM ERRORS, DAMAGE TO EQUIPMENT, LOSS OF DATA OR SOFTWARE PROGRAMS, 
   #           OR UNAVAILABILITY OR INTERRUPTION OF OPERATIONS. 
   #           YOU ARE SOLELY RESPONSIBLE FOR DETERMINING THE APPROPRIATENESS OF USE THE SOFTWARE AND ASSUME ALL RISKS ASSOCIATED WITH ITS USE.
   #
   #===============================================================================================================

function isIn()
{
if [ -z "$1" ]; then
    return
fi

for i in "${EXPECTED_ARGS[@]}"; do
    if [ "$i" == "$1" ];then
        return 1
    fi
done

return 0
}
EXPECTED_ARGS=( 1 )
E_BADARGS=65

if isIn $# ; then
  echo "Usage: $0 filepath"
  exit $E_BADARGS
fi

filepath=${1%/}
filename="${filepath##*/}"
filepath_noext=${filepath%.tar.gz}
filename_noext=${filename%.tar.gz}

mkdir $filepath_noext
tar -zxvf "$filepath" --directory "$filepath_noext"
find $filepath_noext  -type f | xargs perl -i -pe 'if (/(\d{1,3}\.){3}\d{1,3}/g) { s/(\d{1,3}\.){2}\d{1,3}/[**Masked IP**]/g;}'
tar -zcvf "$filepath_noext.masked.tar.gz" -C "$filepath_noext/$filename_noext/" .
