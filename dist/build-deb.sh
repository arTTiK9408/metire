#!/bin/bash
set -euo pipefail

BINARY=metire
VERSION=${1:-1.0}

echo "Building $BINARY v$VERSION..."

dart pub get
dart compile exe bin/metire.dart -o $BINARY

mkdir -p dist/debian/usr/bin
cp $BINARY dist/debian/usr/bin/

dpkg-deb --build dist/debian "${BINARY}_${VERSION}_amd64.deb"
echo "Package created: ${BINARY}_${version}_amd64.deb"
