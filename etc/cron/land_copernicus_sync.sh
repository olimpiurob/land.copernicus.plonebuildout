#!/bin/bash

# copy filestorage related stuff
rsync -aqx --delete --numeric-ids root@gerbil:/var/local/daviz.eionet.europa.eu/var/filestorage/ /var/eeawebtest/zodbfilestorage/daviz.eionet.europa.eu.DEVEL
rsync -aqx --delete --numeric-ids root@gerbil:/var/local/daviz.eionet.europa.eu/var/blobstorage/ /var/eeawebtest/zodbblobstorage/daviz.eionet.europa.eu.DEVEL

rm -f /var/eeawebtest/daviz.eionet.europa.eu.DEVEL/var/filestorage/Data.fs.lock

chown -R zope-www:zope-www /var/eeawebtest/zodbfilestorage/daviz.eionet.europa.eu.DEVEL
chown -R zope-www:zope-www /var/eeawebtest/zodbblobstorage/daviz.eionet.europa.eu.DEVEL

# restart instance
/var/eeawebtest/daviz.eionet.europa.eu.DEVEL/bin/zeoserver restart
/var/eeawebtest/daviz.eionet.europa.eu.DEVEL/bin/www1 restart
/var/eeawebtest/daviz.eionet.europa.eu.DEVEL/bin/www2 restart
