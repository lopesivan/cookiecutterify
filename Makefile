
all: init scan

init:
	./init.sh

scan:
	./scan.sh

dist: MyApplication
	tar cvzf MyApplication.tar.gz MyApplication

clean:
	#ls -d [[:alnum:]]*/| xargs rm -rf
	rm -rf MyApplication/  MyApplication.cookiecutter/  MyApplication.COPY
