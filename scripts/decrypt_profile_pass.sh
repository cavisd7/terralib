#!/bin/bash
echo "Enter encrypted password: "

read encryptedPass

echo $encryptedPass | base64 --decode | keybase pgp decrypt