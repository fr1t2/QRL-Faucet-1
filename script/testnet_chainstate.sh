#!/bin/bash

# Script grabs the curent state files, tar's them up, hashes the tar file and notarises 
# it on the QRL blockchain through a message_tx.

# This script requires 
# - a fully synced node
# - a QRL wallet with funds enough for the TX fee
# - 
# 

epochNow=`date +%s`
# uploadDir=/var/www/html/qrl.co.in/assets/QRL_state/
uploadDir=/var/www/html/qrl.co.in/assets/state
stateDir=/var/www/html/qrl/testnet_state
fileName="QRL_Testnet_State.tar.gz"
checkSumFileName="Testnet_State_Checksums.txt"
statsFileName="QRL_Testnet_Node_Stats.json"
user="fr1t2"

mkdir $stateDir -p 

# copy the files over
rsync -a /home/$user/.qrl-testnet/data/state $stateDir

# zip them up a little
tar -czvf $uploadDir/$fileName $stateDir/*

chainState=$(sudo -H -u $user /home/$user/.local/bin/qrl --json --host 127.0.0.1 --port_pub 19010 state)
chainSize=$(du -hs /home/$user/.qrl/data/state/ | awk '{print $1}')
tarFileSize=$(du -hs $uploadDir/$fileName | awk '{print $1}')

# get the sha and md5 sums into a file
echo "-------- SHA3-512 Sum --------" > ${uploadDir}/${checkSumFileName}
openssl dgst -sha3-512 $uploadDir/$fileName >> ${uploadDir}/${checkSumFileName}
echo "" >> ${uploadDir}/${checkSumFileName} 

echo "-------- SHA3-256 Sum --------" >> ${uploadDir}/${checkSumFileName}
openssl dgst -sha3-256 $uploadDir/$fileName >> ${uploadDir}/${checkSumFileName}
echo "" >> ${uploadDir}/${checkSumFileName} 

echo "-------- SHA-256 Sum --------" >> ${uploadDir}/${checkSumFileName}
sha256sum $uploadDir/$fileName >> ${uploadDir}/${checkSumFileName}
echo "" >> ${uploadDir}/${checkSumFileName} 

echo "-------- MD5 Sum --------" >> ${uploadDir}/${checkSumFileName}
md5sum  $uploadDir/$fileName >> ${uploadDir}/${checkSumFileName}


# Write the STATS File for consumption by the server for data
timestampJson="{ \"Unix_Timestamp\": \"$epochNow\" }"
chainSizeJson="{ \"Uncompressed_Chain_Size\": \"$chainSize\" }"
tarFileSizeJson="{ \"Tar_FileSize\": \"$tarFileSize\" }"

echo "[" > ${uploadDir}/${statsFileName}
echo $chainState "," >> ${uploadDir}/${statsFileName}

echo $timestampJson "," >> ${uploadDir}/${statsFileName}
echo $chainSizeJson "," >> ${uploadDir}/${statsFileName}
echo $tarFileSizeJson >> ${uploadDir}/${statsFileName}
echo "]" >> ${uploadDir}/${statsFileName}
echo "" > ${uploadDir}/index.html

# make sure you own the folder or are a part of the www-data group
sudo chown www-data:www-data $uploadDir -R
