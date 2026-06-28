
all: init scan

init:
	./init.sh

scan:
	./scan.sh

clean:
	#ls -d [[:alnum:]]*/| xargs rm -rf
	rm -rf MyApplication/  MyApplication.cookiecutter/  MyApplication.COPY
