SHELL = /bin/bash
COLOR_VARIANTS = '' '-dark' '-light'
SIZE_VARIANTS = '' '-slim'
VERSIONS = '3.18' '3.26' '3.28' '3.30' '3.32'
SASSC_OPT=-M -t expanded
BASE_DIR=/usr/share/themes
REPODIR=$(CURDIR)
SRCDIR=$(REPODIR)/build
GNOMEVER=$(shell gnome-shell --version | cut -d ' ' -f3 | cut -d '.' -f1,2)
DEBIAN=0

all: gnome-shell

clean:
	-rm -rf ./src/**/*.css
	-rm -rf ./src/**/*.tmp
	-rm -rf build

uninstall:
	for color in $(COLOR_VARIANTS); do \
	  for size in $(SIZE_VARIANTS); do \
	    rm -rf /usr/share/themes/PopBlood$$color$$size/gnome-shell \
	           /usr/local/share/themesPopBlood$$color$$size/gnome-shell; \
	  done; \
	done

	-rm -rf /usr/share/gnome-shell/theme/pop-blood.css

install:
	@echo "** Installing the theme for GNOME version $(GNOMEVER)..."

	# Install GNOME Shell Theme
	for color in $(COLOR_VARIANTS); do \
	  for size in $(SIZE_VARIANTS); do \
	    export themedir=$(DESTDIR)$(BASE_DIR)/PopBlood$$color$$size; \
	    install -d $$themedir/gnome-shell; \
	    cd $(SRCDIR)/$(GNOMEVER); \
	    cp -ur \
	      *.svg \
	      $$themedir/gnome-shell; \
	    cp -urL \
	      extensions \
	      pad-osd.css \
	      $$themedir/gnome-shell; \
	    if [ "$$color" != '-dark' ]; then \
	      cp -urL \
	        assets \
	        $$themedir/gnome-shell; \
	    else \
	      cp -urL \
	        assets-dark \
	        $$themedir/gnome-shell/assets; \
	    fi; \
	    cp -ur \
	      gnome-shell$$color$$size.css \
	      $$themedir/gnome-shell/gnome-shell.css; \
	    cp -ur \
	      gnome-shell$$color$$size.css \
	      $$themedir/gnome-shell/pop-blood.css; \
	    glib-compile-resources \
	      --sourcedir=$$themedir/gnome-shell \
	      --target=$$themedir/gnome-shell/gnome-shell-thememe.gresource \
	      gnome-shell-theme.gresource.xml; \
	  done; \
	done

	install -D $(DESTDIR)/usr/share/themes/PopBlood/gnome-shell/pop-blood.css \
	           $(DESTDIR)/usr/share/gnome-shell/theme/pop-blood.css
	cp -r $(DESTDIR)/usr/share/themes/PopBlood/gnome-shell/assets \
	      $(DESTDIR)/usr/share/gnome-shell/theme/

recolor:
	@echo "** Matching Colors"

	cd ./src/gtk-3.0/gtk-common/ && ./recolor-assets.sh > /dev/null
	cd ./src/gtk-2.0/ && ./recolor-assets.sh > /dev/null

sass: gnome-shell
	@echo "** Generating the CSS..."

gnome-shell:
	@echo "** Generating GNOME Shell..."

	-mkdir -p build

	for version in $(VERSIONS); do \
	  mkdir -p src/$$version; \
	  cp -r src/common/ build/$$version; \
	  cp -r src/$$version/ build/; \
	done

	for color in $(COLOR_VARIANTS); do \
	  for size in $(SIZE_VARIANTS); do \
	    for version in $(VERSIONS); do \
	      sassc $(SASSC_OPT) build/$$version/gnome-shell$$color$$size.{scss,css}; \
	      sassc $(SASSC_OPT) build/$$version/extensions/workspaces-to-dock/workspaces-to-dock.{scss,css}; \
	      sassc $(SASSC_OPT) build/$$version/pad-osd.{scss,css}; \
	    done; \
	  done; \
	done

.PHONY: all install uninstall clean gnome-shell
