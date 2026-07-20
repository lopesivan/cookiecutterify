NAME           = template-mono
GITHUB_USER    = lopesivan
TEMPLATE_MODEL = basic_mono
PLATAFORM      = linux
LANGUAGE       = csharp

# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------

REPONAME       = $(NAME)
COOKIE         = cookiecutter-$(PLATAFORM)-$(TEMPLATE_MODEL)-$(LANGUAGE)
PATCH          = $(wildcard *.patch)

CONFIG         = cookie.yml
SRC            = $(NAME).COPY
DST            = $(NAME).cookiecutter
OUT            = $(COOKIE)

all: init scan

all: init scan

init:
	./init.sh $(GITHUB_USER) $(REPONAME) $(PATCH)

scan:
	./scan.sh $(REPONAME) $(CONFIG) $(SRC) $(DST) $(OUT)
	cat README.md.conf | sed \
        -e 's/__PLATAFORM__/$(PLATAFORM)/g' \
        -e 's/__TEMPLATE_MODEL__/$(TEMPLATE_MODEL)/g' \
        -e 's/__LANGUAGE__/$(LANGUAGE)/g' >$(OUT)/README.md


dist: $(NAME)
	tar cvzf $(NAME).tar.gz $(NAME)

clean:
	#ls -d [[:alnum:]]*/| xargs rm -rf
	rm -rf \
	$(NAME) \
	$(NAME).COPY \
	$(NAME).cookiecutter \
	$(COOKIE)
