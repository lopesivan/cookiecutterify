NAME   = HelloAndroid
COOKIE = cookiecutter-android-hello_android-kotlin
all: init scan

init:
	./init.sh

scan:
	./scan.sh

dist: $(NAME)
	tar cvzf $(NAME).tar.gz $(NAME)

clean:
	#ls -d [[:alnum:]]*/| xargs rm -rf
	rm -rf $(COOKIE)
	rm -rf $(NAME) $(NAME).cookiecutter $(NAME).COPY
