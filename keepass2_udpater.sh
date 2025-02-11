#!/bin/sh

echo '[*] Update keepass2 package to a specific KeePass version from https://keepass.info/download.html'

if [ -z "$1" ]; then
    echo "[*] Usage: $0 <target_version>"
    echo '[-] No version (see https://keepass.info/download.html) specified, exiting'
    exit 1
fi

echo '[*] Set fingerprint of Dominik Reichl public key (verified on 2025-02-09 at https://keepass.info/integrity.html)'
public_key_fingerprint='D95044283EE948D911E8B606A4F762DC58C6F98E'

echo '[*] Set variables'
target_version="$1"
keepass_archive='KeePass.zip'
keepass_archive_signature='KeePass.zip.asc'
keepass2_path='/usr/lib/keepass2/'

echo '[*] Install keepass2'
sudo apt install -qq keepass2

echo '[*] Download KeePass archive and signature'
wget --no-verbose --output-document "$keepass_archive" "https://netix.dl.sourceforge.net/project/keepass/KeePass%202.x/${target_version}/KeePass-${target_version}.zip"
wget --no-verbose --output-document "$keepass_archive_signature" "https://keepass.info/integrity/v2/KeePass-${target_version}.zip.asc"

echo '[*] Verify KeePass archive with signature and public key of Dominik Reichl'
gpg --quiet --assert-signer "$public_key_fingerprint" --auto-key-retrieve --verify "$keepass_archive_signature" "$keepass_archive"

if [ $? -ne 0 ]; then
    echo '[-] Signature verification failed, exiting'
    exit 1
fi

echo '[*] Update executables'
sudo unzip -oq "$keepass_archive" KeePass.exe KeePass.exe.config -d "$keepass2_path"

echo '[*] Clean up'
rm "$keepass_archive_signature" "$keepass_archive"

echo '[+] Update successful'
