#!/bin/bash

REPO_DIR=/var/www/html/repos
REPOSYNC=/usr/bin/reposync
RESTORECON=/usr/sbin/restorecon
CHCON=/usr/bin/chcon

repos=$(cat <<EOS
rhel-8-for-x86_64-baseos-rpms
rhel-8-for-x86_64-appstream-rpms
EOS
)

# rhceph-4-tools-for-rhel-8-x86_64-rpms
ceph_repos=$(cat <<EOS
rhceph-4-tools-for-rhel-8-x86_64-rpms
ansible-2.9-for-rhel-8-x86_64-rpms
rhceph-4-mon-for-rhel-8-x86_64-rpms
rhceph-4-osd-for-rhel-8-x86_64-rpms
EOS
)


for repo in ${repos} ${ceph_repos}
do
#  echo $repo
   ${REPOSYNC} -p ${REPO_DIR} --download-metadata --repo=${repo}
done

# Give SElinux permissions
${RESTORECON} -irv ${REPO_DIR}
${CHCON} -R -t httpd_sys_content_t ${REPO_DIR}
