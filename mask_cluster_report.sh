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

function check_file_type()
{
	if [[ "$1" == *"cluster-report-"*"tar.gz" ]]; then
		return 1
	fi
return 0 
}

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

function rename_dir()
{
	for dir in $filepath_noext/$filename_noext/*    
	do
	    dir_path=${dir%*/}      # remove the trailing "/"
	    dir_name=${dir_path##*/}    # print everything after the final "/"
	    new_dir_name=`echo $dir_name |  perl -ne 's/(?!0\.0\.0\.0|\d{1,3}.0\.0\.1)(\d{1,3}\.){2}\d{1,3}/x.x.x/g; print $_'`
	    mv $dir_path $filepath_noext/$filename_noext/$new_dir_name

	done
}


# start 
EXPECTED_ARGS=( 1 ) # number of args expected
E_BADARGS=65


if isIn $# ; then #check to make sure argument count = EXPECTED_ARGS
  echo "Usage: $0 /path/to/cluster-report.tar.gz"
  exit $E_BADARGS
fi

if check_file_type $@ ; then #check that files meets mask: *"cluster-report-"*"tar.gz"
  echo "Input must be a cluster report .tar.gz file! (ex. cluster-report-20181118T134028.tar.gz)"
  echo "Usage: $0 /path/to/cluster-report.tar.gz"
  exit $E_BADARGS
fi


filepath=${1%/}
filename="${filepath##*/}"
filepath_noext=${filepath%.tar.gz}
filename_noext=${filename%.tar.gz}

mkdir $filepath_noext # create directory for CR
tar -zxf "$filepath" --directory "$filepath_noext" # extract CR
find $filepath_noext  -type f | xargs perl -i -pe 'if (/(?!0\.0\.0\.0|\d{1,3}.0\.0\.1)(\d{1,3}\.){3}\d{1,3}/g) { s/(\d{1,3}\.){2}\d{1,3}/[**Masked IP**]/g;}' # use PERL regex to mask IPs (skipping 127.0.0.1 and 0.0.0.0)
rename_dir # rename the directories with IP addresses in them 
tar -zcf "$filepath_noext.masked.tar.gz" -C "$filepath_noext/" . # recompress the directory 
echo "masked report created at $filepath_noext.masked.tar.gz"
rm -rf $filepath_noext # remove working files
