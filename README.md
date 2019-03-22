# mask_cluster_report
Removes the IP addresses from the MemSQL cluster report.  Uses Perl regex for portability and consistency.  Designed to run on Linux, but also tested on MacOS

### Use: 
`mask_cluster_report.sh /path/to/cluster-report.tar.gz`

### example: 
```
[vagrant@localhost ~]$ ./mask_cluster_report.sh newdir/cluster-report-20181118T134028.tar.gz
masked report created at newdir/cluster-report-20181118T134028.masked.tar.gz
```
