# Makefile for PenguineInc sounds
#
# If you have KSP in a non-standard directory, be sure to set the environment variable
# $XDG_DATA_HOME (if different from usual), or $KSPDIR to the directory of KSP (if using
# a Steam library in a non-standard location).
#
# Example: if you have a Steam library in the directory /media/partition3, do something like:
# export KSPDIR="/media/partition3/SteamLibrary/SteamApps/common/Kerbal Space Program"
# then, run make as normal.

ifeq ($(OS),Windows_NT)
	# It's unlikely that a windows user will use a makefile to compile PenguineInc
	# Visual studio is free, after all.
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		ifndef XDG_DATA_HOME
			XDG_DATA_HOME := ${HOME}/.local/share
		endif
		ifndef KSPDIR
			KSPDIR := ${XDG_DATA_HOME}/Steam/SteamApps/common/Kerbal\ Space\ Program
		endif
		MANAGED := ${KSPDIR}/KSP_Data/Managed/
	endif
	ifeq ($(UNAME_S),Darwin)
		ifndef KSPDIR
			KSPDIR := ${HOME}/Library/Application\ Support/Steam/SteamApps/common/Kerbal\ Space\ Program/
		endif
		MANAGED := ${KSPDIR}/KSP.app/Contents/Data/Managed/
	endif
endif

PenguineIncFILES := $(wildcard Plugins/Source/*.cs) \
	$(wildcard Plugins/Source/Properties/*.cs) 

RESGEN2 := resgen2
GMCS := gmcs
GIT := git
TAR := tar
ZIP := zip

VERSION := $(shell ${GIT} describe --tags --always)

all: build

info:
	@echo "== PenguineInc Build Information =="
	@echo " resgen2: ${RESGEN2}"
	@echo " gmcs: ${GMCS}"
	@echo " git: ${GIT}"
	@echo " tar: ${TAR}"
	@echo " zip: ${ZIP}"
	@echo " KSP Data: ${KSPDIR}"
	@echo " PenguineInc Files: ${PenguineIncFILES}"
	@echo "================================"

build: build/PenguineInc.dll
	
build/%.dll: ${PenguineIncFILES}
	mkdir -p build
	${GMCS} -t:library -lib:"${MANAGED}" \
		-r:Assembly-CSharp,Assembly-CSharp-firstpass,UnityEngine \
		-out:$@ \
		${PenguineIncFILES}

package: build ${PenguineIncFILES}
	mkdir -p package/PenguineInc/Plugins
	cp -r Parts package/PenguineInc/
	cp -r Sounds package/PenguineInc/
	cp -r Textures package/PenguineInc/
	cp build/PenguineInc.dll package/PenguineInc/Plugins/
	cp LICENSE.md README.md package/PenguineInc/

%.tar.gz:
	${TAR} zcf $@ package/PenguineInc

tar.gz: package PenguineInc-${VERSION}.tar.gz

%.zip:
	${ZIP} -9 -r $@ package/PenguineInc

zip: package PenguineInc-${VERSION}.zip

clean:
	@echo "Cleaning up build and package directories..."
	rm -rf build/ package/

install: build
	mkdir -p ${KSPDIR}/GameData/PenguineInc/Plugins
	cp -r Parts ${KSPDIR}/GameData/PenguineInc/
	cp -r Sounds ${KSPDIR}/GameData/PenguineInc/
	cp -r Textures ${KSPDIR}/GameData/PenguineInc/
	cp build/PenguineInc.dll ${KSPDIR}/GameData/PenguineInc/Plugins/

uninstall: info
	rm -rf ${KSPDIR}/GameData/PenguineInc/Plugins
	rm -rf ${KSPDIR}/GameData/PenguineInc/Parts

.PHONY : all info build package tar.gz zip clean install uninstall)
