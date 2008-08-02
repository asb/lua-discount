VERSION= 0.1

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
DEFS = -DHAVE_FOPENCOOKIE

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

.PHONY: clean test distr
clean:
	rm -f $(OBJS) $(SOS) core core.* a.out

