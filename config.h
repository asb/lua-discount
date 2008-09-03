#undef USE_AMALLOC

#define DL_TAG_EXTENSION 1
#define TABSTOP 4
#define COINTOSS() (random()&1)
#define INITRNG(x) srandom((unsigned int)x)
#define RELAXED_EMPHASIS 1
