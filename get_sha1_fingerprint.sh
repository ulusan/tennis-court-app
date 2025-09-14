#!/bin/bash

echo "========================================"
echo "   Google OAuth SHA-1 Fingerprint Alıcı"
echo "========================================"
echo

echo "SHA-1 fingerprint alınıyor..."
echo

keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

echo
echo "========================================"
echo "   Yukarıdaki SHA1: değerini kopyalayın"
echo "   Google Console'da Android Client ID"
echo "   oluştururken bu değeri kullanın"
echo "========================================"
echo
