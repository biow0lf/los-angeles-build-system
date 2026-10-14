#! /bin/bash

melange index \
	--signing-key keys/melange.rsa \
	-o packages-out/x86_64/APKINDEX.tar.gz \
	packages-out/x86_64/*.apk

