//##lang C:\Projects\mlang\skins\en.lua
#include <stdlib.h>
// #include "lexer.h"

size_t utf8_decode(const char *s, const char *e, unsigned *pch);

static const char *utf8_next(const char *s, const char *e);

static const char *utf8_prev(const char *s, const char *e);

