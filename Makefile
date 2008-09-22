LIB_NAME= lua-discount
VERSION= 1.2.10.1

# change these to reflect your Lua installation
LUA= /usr
LUAINC= $(LUA)/include
LUALIB= $(LUA)/lib
LUABIN= $(LUA)/bin

# probably no need to change anything below here
CC= gcc
CFLAGS= $(INCS) $(WARN) -O2 -fPIC ${DEFS}
WARN= -Wall
INCS= -I$(LUAINC)
DEFS = 

DISCOUNT_OBJS = docheader.o \
	dumptree.o \
	generate.o \
	markdown.o \
	mkdio.o \
	resource.o
OBJS=  $(DISCOUNT_OBJS) ldiscount.o
SOS= discount.so

all: $(SOS)

$(SOS): $(OBJS)
	$(CC) -o $@ -shared $(OBJS) $(LIBS)

.PHONY: clean tar
clean:
	rm -f $(OBJS) $(SOS) core core.* a.out

tar: clean
	git archive --format=tar --prefix=$(LIB_NAME)-$(VERSION)/ $(VERSION) | gzip > $(LIB_NAME)-$(VERSION).tar.gz

