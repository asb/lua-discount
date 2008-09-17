#undef USE_AMALLOC

#ifdef WINDOWS
  #define strcasecmp stricmp
  #define strncasecmp strnicmp
#endif

#define DL_TAG_EXTENSION 1
#define TABSTOP 4
#define COINTOSS() (rand()&1)
#define INITRNG(x) srand((unsigned int)x)
#define RELAXED_EMPHASIS 1
