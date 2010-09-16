VERSION=0.0.1

all: swc docs test-build

swc:
	compc -load-config+=test/Runner-config.xml -include-sources=src -output=bin/dungdungdung-v$(VERSION).swc
docs:
	asdoc -load-config+=test/Runner-config.xml -doc-sources=src -output=docs
test-build:
	mxmlc test/Runner.mxml	
test: test-build
	open bin/index.html