HOST_CC = gcc
HOST_CFLAGS =
SPASM = spasm
SPASM_FLAGS =
EXE_SUFFIX =
PSXSDK_PREFIX = /usr/local/psxsdk


all: 
	mkdir -p cdimg
	$(SPASM) $(SPASM_CFLAGS) nes.asm nes.exe
	mkdir -p cd_root
	cp nes.exe cd_root/nes.exe
	cp saveicon.bmp cd_root/saveicon.bmp
	cp rombank.bin cd_root/rombank.bin
	systemcnf nes.exe > cd_root/system.cnf
	mkisofs -o imbnes.hsf -V IMBNES -sysid PLAYSTATION cd_root
	mkpsxiso imbnes.hsf cdimg/imbnes_e.bin \
	$(PSXSDK_PREFIX)/share/licenses/infoeur.dat
	mkpsxiso imbnes.hsf cdimg/imbnes_u.bin \
	$(PSXSDK_PREFIX)/share/licenses/infousa.dat
	mkpsxiso imbnes.hsf cdimg/imbnes_j.bin \
	$(PSXSDK_PREFIX)/share/licenses/infojap.dat
	rm -fr cd_root
	rm -f nes.hsf
clean:
	rm -fr cdimg cd_root
	rm -f nes.exe
	rm -f rombank$(EXE_SUFFIX)
	rm -f imbnes.hsf	

rombank:
	$(HOST_CC) $(HOST_CFLAGS) -o rombank$(EXE_SUFFIX) rombank.c
