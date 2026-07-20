NAME           = template-mono
PLATAFORM      = Linux
GITHUB_USER    = lopesivan
LANGUAGE       = csharp

REPONAME       = $(NAME)
TEMPLATE_MODEL = $(NAME)
COOKIE         = cookiecutter-$(PLATAFORM)-$(NAME)-$(LANGUAGE)
PATCH          = $(wildcard *.patch)

config         = cookie.yml
src            = $(NAME).COPY
dst            = $(NAME).cookiecutter
out            = $(COOKIE)

all: init scan

init:
	./init.sh $(GITHUB_USER) $(REPONAME) $(PATCH)

scan:
	./scan.sh $(config) $(src) $(dst) $(out)


dist: $(NAME)
	tar cvzf $(NAME).tar.gz $(NAME)

clean:
	#ls -d [[:alnum:]]*/| xargs rm -rf
	rm -rf $(NAME) \
	rm -rf \
	$(COOKIE) \
	$(NAME).cookiecutter \
	$(NAME).COPY \
