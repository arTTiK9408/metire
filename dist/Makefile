BINARY = metire

build:
	dart pub get
	dart compile exe bin/metire.dart -o $(BINARY)

clean:
	rm -f $(BINARY)

deb: build
	mkdir -p dist/debian/usr/bin
	cp $(BINARY) dist/debian/usr/bin/
	dpkg-deb --build dist/debian metire_1.0_amd64.deb

rpm: build
	rpmbuild -ba dist/fedora/metire.spec
