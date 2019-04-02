/*
** $Id: llex.c,v 2.96 2016/05/02 14:02:12 roberto Exp $
** Lexical Analyzer
** See Copyright Notice in lua.h
*/

#define llex_c
#define LUA_CORE

#include "lprefix.h"


#include <locale.h>
#include <string.h>

#include "lua.h"

#include "lctype.h"
#include "ldebug.h"
#include "ldo.h"
#include "lgc.h"
#include "llex.h"
#include "lobject.h"
#include "lparser.h"
#include "lstate.h"
#include "lstring.h"
#include "ltable.h"
#include "lzio.h"


#define MAXUNICODE	0x10FFFF

// int zutf8_decode (LexState *ls) {
//   static const unsigned int limits[] = {0xFF, 0x7F, 0x7FF, 0xFFFF};
//   int c = zgetc(ls->z);
//   unsigned int res = 0;  /* final result */
//   if (c < 0x80)  /* ascii? */
//     res = c;
//   else {
//     int count = 0;  /* to count number of continuation bytes */
//     while (c & 0x40) {  /* still have continuation bytes? */
//       int cc = zgetc(ls->z);  /* read next byte */
//       if ((cc & 0xC0) != 0x80)  /* not a continuation byte? */
//         return -1;  /* invalid byte sequence */
//       res = (res << 6) | (cc & 0x3F);  /* add lower 6 bits from cont. byte */
//       c <<= 1;  /* to test next bit */
//     }
//     res |= ((c & 0x7F) << (count * 5));  /* add first byte */
//     if (count > 3 || res > MAXUNICODE || res <= limits[count])
//       return -1;  /* invalid byte sequence */
//     // s += count;  /* skip continuation bytes read */
//   }
//   // if (val) *val = res;
// 	ls->current_utf = res;
//   return c;  /* +1 to include first byte */
// }


// #define next(ls) (ls->current = zutf8_decode(ls))
#define next(ls) (ls->previous = ls->current, ls->current = zgetc(ls->z))


#define MAXUNICODE	0x10FFFF

long next1 (LexState *ls) {
	struct Zio * z = ls->z;
  static const unsigned int limits[] = {0xFF, 0x7F, 0x7FF, 0xFFFF};
  // const unsigned char *s = (const unsigned char *)o;
  int c = zgetc(z);

  unsigned int res = 0;  /* final result */
  if (c < 0x80)  /* ascii? */
    res = c;
  else {
    int count = 0;  /* to count number of continuation bytes */
    while (c & 0x40) {  /* still have continuation bytes? */
      int cc = zgetc(z);  /* read next byte */
			count++;
      if ((cc & 0xC0) != 0x80)  /* not a continuation byte? */
        // return 0;  /* invalid byte sequence */
				luaX_syntaxerror(ls, "invalid byte sequence\n");
      res = (res << 6) | (cc & 0x3F);  /* add lower 6 bits from cont. byte */
      c <<= 1;  /* to test next bit */
    }
    res |= ((c & 0x7F) << (count * 5));  /* add first byte */
    if (count > 3 || res > MAXUNICODE || res <= limits[count])
      // return 0;  /* invalid byte sequence */
				luaX_syntaxerror(ls, "invalid byte sequence2\n");
    // s += count;  /* skip continuation bytes read */
  }
	ls->current = res;
  return res;
  // return (const char *)s + 1;  /* +1 to include first byte */
}


#define currIsNewline(ls)	(ls->current == '\n' || ls->current == '\r')


/* ORDER RESERVED */
static const char *const luaX_tokens [] = {
    "and", "break", "do", "else", "elseif",
    "end", "false", "for", "function", "goto", "if",
    "in", "local", "nil", "not", "or", "repeat",
    "return", "then", "true", "until", "while",
    "//", "..", "...", "==", ">=", "<=", "~=",
    "<<", ">>", "::", "<eof>",
    "<number>", "<integer>", "<name>", "<string>"
};
static const char *const luaX_tokens_cyr [] = {
    "и", "стоп", "начало", "иначе", "иначеесли",
    "конец", "ложь", "для", "функция", "идина", "если",
    "из", "локал", "нуль", "не", "или", "повторять",
    "возврат", "тогда", "истина", "покуда", "пока",
    "//", "..", "...", "==", ">=", "<=", "!=",

};
static const char *const luaX_tokens_cyr_utf8 [] = {
    "\xD0\xB8", "\xD1\x81\xD1\x82\xD0\xBE\xD0\xBF", "\xD0\xBD\xD0\xB0\xD1\x87\xD0\xB0\xD0\xBB\xD0\xBE", "\xD0\xB8\xD0\xBD\xD0\xB0\xD1\x87\xD0\xB5", "\xd0\xb8\xd0\xb5\xd1\x81\xd0\xbb\xd0\xb8",

    "\xD0\xBA\xD0\xBE\xD0\xBD\xD0\xB5\xD1\x86", "\xD0\xBB\xD0\xBE\xD0\xB6\xD1\x8C", "\xD0\xB4\xD0\xBB\xD1\x8F", "\xD1\x84\xD1\x83\xD0\xBD\xD0\xBA\xD1\x86\xD0\xB8\xD1\x8F", "\xd0\xb8\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb0", "\xD0\xB5\xD1\x81\xD0\xBB\xD0\xB8", 

    "\xd0\xb8\xd0\xb7", "\xD0\xBB\xD0\xBE\xD0\xBA\xD0\xB0\xD0\xBB", "\xd0\xbd\xd1\x83\xd0\xbb\xd1\x8c", "\xd0\xbd\xd0\xb5", "\xD0\xB8\xD0\xBB\xD0\xB8", "\xd0\xbf\xd0\xbe\xd0\xb2\xd1\x82\xd0\xbe\xd1\x80\xd1\x8f\xd1\x82\xd1\x8c",
    "\xD0\xB2\xD0\xBE\xD0\xB7\xD0\xB2\xD1\x80\xD0\xB0\xD1\x82", "\xD1\x82\xD0\xBE\xD0\xB3\xD0\xB4\xD0\xB0", "\xD0\xB8\xD1\x81\xD1\x82\xD0\xB8\xD0\xBD\xD0\xB0", "\xd0\xbf\xd0\xbe\xd0\xba\xd1\x83\xd0\xb4\xd0\xb0", "\xD0\xBF\xD0\xBE\xD0\xBA\xD0\xB0",

};


#define save_and_next(ls) (save(ls, ls->current), next(ls))


static l_noret lexerror (LexState *ls, const char *msg, int token);


static void save (LexState *ls, int c) {
  Mbuffer *b = ls->buff;
  if (luaZ_bufflen(b) + 1 > luaZ_sizebuffer(b)) {
    size_t newsize;
    if (luaZ_sizebuffer(b) >= MAX_SIZE/2)
      lexerror(ls, "lexical element too long", 0);
    newsize = luaZ_sizebuffer(b) * 2;
    luaZ_resizebuffer(ls->L, b, newsize);
  }
  b->buffer[luaZ_bufflen(b)++] = cast(char, c);
}


void luaX_init (lua_State *L) {
  size_t i;
  TString *e = luaS_newliteral(L, LUA_ENV);  /* create env name */
  luaC_fix(L, obj2gco(e));  /* never collect this name */
  for (i=0; i<NUM_RESERVED; i++) {
    TString *ts = luaS_new(L, luaX_tokens[i]);
    luaC_fix(L, obj2gco(ts));  /* reserved words are never collected */
    ts->extra = cast_byte(i+1);  /* reserved word */
  }

  TString *e2 = luaS_newliteral(L, "_ОКР");  /* create env name */
  luaC_fix(L, obj2gco(e2));  /* never collect this name */
  e2 = luaS_newliteral(L, "\x5F\xD0\x9E\xD0\x9A\xD0\xA0");  /* create env name */
  luaC_fix(L, obj2gco(e2));  /* never collect this name */


  for (i=0; i<sizeof(luaX_tokens_cyr_utf8)/sizeof(luaX_tokens_cyr_utf8[i]); i++) {
    TString *ts = luaS_new(L, luaX_tokens_cyr_utf8[i]);
    luaC_fix(L, obj2gco(ts));  /* reserved words are never collected */
    ts->extra = cast_byte(i+1);  /* reserved word */
  }


}


const char *luaX_token2str (LexState *ls, int token) {
  if (token < FIRST_RESERVED) {  /* single-byte symbols? */
    lua_assert(token == cast_uchar(token));
    return luaO_pushfstring(ls->L, "'%c'", token);
  }
  else {
    const char *s = luaX_tokens[token - FIRST_RESERVED];
    if (token < TK_EOS)  /* fixed format (symbols and reserved words)? */
      return luaO_pushfstring(ls->L, "'%s'", s);
    else  /* names, strings, and numerals */
      return s;
  }
}


static const char *txtToken (LexState *ls, int token) {
  switch (token) {
    case TK_NAME: case TK_STRING:
    case TK_FLT: case TK_INT:
      save(ls, '\0');
      return luaO_pushfstring(ls->L, "'%s'", luaZ_buffer(ls->buff));
    default:
      return luaX_token2str(ls, token);
  }
}


static l_noret lexerror (LexState *ls, const char *msg, int token) {
  msg = luaG_addinfo(ls->L, msg, ls->source, ls->linenumber);
  if (token)
    luaO_pushfstring(ls->L, "%s near %s", msg, txtToken(ls, token));
  luaD_throw(ls->L, LUA_ERRSYNTAX);
}


l_noret luaX_syntaxerror (LexState *ls, const char *msg) {
  lexerror(ls, msg, ls->t.token);
}


/*
** creates a new string and anchors it in scanner's table so that
** it will not be collected until the end of the compilation
** (by that time it should be anchored somewhere)
*/
TString *luaX_newstring (LexState *ls, const char *str, size_t l) {
  lua_State *L = ls->L;
  TValue *o;  /* entry for 'str' */
  TString *ts = luaS_newlstr(L, str, l);  /* create new string */
  setsvalue2s(L, L->top++, ts);  /* temporarily anchor it in stack */
  o = luaH_set(L, ls->h, L->top - 1);
  if (ttisnil(o)) {  /* not in use yet? */
    /* boolean value does not need GC barrier;
       table has no metatable, so it does not need to invalidate cache */
    setbvalue(o, 1);  /* t[string] = true */
    luaC_checkGC(L);
  }
  else {  /* string already present */
    ts = tsvalue(keyfromval(o));  /* re-use value previously stored */
  }
  L->top--;  /* remove string from stack */
  return ts;
}


/*
** increment line number and skips newline sequence (any of
** \n, \r, \n\r, or \r\n)
*/
static void inclinenumber (LexState *ls) {
  int old = ls->current;
  lua_assert(currIsNewline(ls));
  next(ls);  /* skip '\n' or '\r' */
  if (currIsNewline(ls) && ls->current != old)
    next(ls);  /* skip '\n\r' or '\r\n' */
  if (++ls->linenumber >= MAX_INT)
    lexerror(ls, "chunk has too many lines", 0);
}

void luaX_setinput (lua_State *L, LexState *ls, ZIO *z, TString *source,
                    int firstchar) {
  ls->t.token = 0;
  ls->L = L;
  ls->current = firstchar;
  ls->lookahead.token = TK_EOS;  /* no look-ahead token */
  ls->z = z;
  ls->fs = NULL;
  ls->linenumber = 1;
  ls->lastline = 1;
  ls->source = source;
  ls->envn = luaS_newliteral(L, LUA_ENV);  /* get env name */
  luaZ_resizebuffer(ls->L, ls->buff, LUA_MINBUFFER);  /* initialize buffer */
}



/*
** =======================================================
** LEXICAL ANALYZER
** =======================================================
*/


static int check_next1 (LexState *ls, int c) {
  if (ls->current == c) {
    next(ls);
    return 1;
  }
  else return 0;
}


/*
** Check whether current char is in set 'set' (with two chars) and
** saves it
*/
static int check_next2 (LexState *ls, const char *set) {
  lua_assert(set[2] == '\0');
  if (ls->current == set[0] || ls->current == set[1]) {
    save_and_next(ls);
    return 1;
  }
  else return 0;
}

// static int check_next4 (LexState *ls, const char *set) {
//   lua_assert(set[4] == '\0');
//   if (ls->current == set[0] || ls->current == set[1] || ls->current == set[2] || ls->current == set[3]) {
//     save_and_next(ls);
//     return 1;
//   }
//   else return 0;
// }
int zlookc(ZIO *z) {
	if(z->n-1>0){
		return (unsigned char)cast_uchar(*(z->p));
	}else{
	  size_t size;
	  lua_State *L = z->L;
	  const char *buff;
	  lua_unlock(L);
	  buff = z->reader(L, z->data, &size);
	  lua_lock(L);
	  if (buff == NULL || size == 0)
	    return EOZ;
	  z->n = size - 1;  /* discount char being returned */
	  z->p = buff;
	  return (unsigned char)cast_uchar(*(z->p));
	}
}


static int check_next2cyr (LexState *ls, const char *set1) {
  lua_assert(set1[5] == '\0');
	const unsigned char *set = (const unsigned char *)set1;
// printf("check_next2: 1 %lx %lx %lx\n", ls->previous, set[0] , set[0]);
  if (ls->current == set[0] || ls->current == set[2]) {
		int s = zlookc(ls->z);
	  // next(ls);
// printf("%s:%d: check_next2: 2 %lx %lx %lx\n", ls->source, ls->linenumber, s, set[1] , set[3]);
		if (s == set[1] || s == set[3]) {
			save(ls, set[4]);
	    next(ls);
	    next(ls);
	    return 1;
	  }
		// else lexerror(ls, "malformed utf8 symbol", TK_FLT);
  }
  return 0;
}

static int lisxdigit_cyr (LexState *ls) {
  if (ls->current != 0xd0) return 0;
	int s = zlookc(ls->z);
	if (s >= 0x90 && s <= 0x95) {
		save(ls, 0x90-s+'a');
    next(ls);
    next(ls);
    return 1;
  }else if(s >= 0xb0 && s <= 0xb5){
		save(ls, 0xb0-s+'a');
    next(ls);
    next(ls);
    return 1;
	}else return 0;
}

/* LUA_NUMBER */
/*
** this function is quite liberal in what it accepts, as 'luaO_str2num'
** will reject ill-formed numerals.
*/
static int read_numeral (LexState *ls, SemInfo *seminfo) {
  TValue obj;
  const char *expo = "Ee";
  const char *expo_cyr = "\xd0\xb5\xd0\x95\x65";
  int first = ls->current;
  int ishex = 0;
  lua_assert(lisdigit(ls->current));
  save_and_next(ls);
  if (first == '0' && (check_next2(ls, "xX") || check_next2cyr(ls, "\xd1\x88\xd0\xa8\x78"))){  /* hexadecimal? */
    expo = "\xd0\xa0\xd1\x80\x70";
		ishex = 1;
	}
  for (;;) {
    if (check_next2(ls, expo) || check_next2cyr(ls, expo_cyr)){  /* exponent part? */
			while(ls->current == ' ' || ls->current == '\t') next(ls);
      check_next2(ls, "-+");  /* optional exponent sign */
		}
//     if (ls->current == ' ' || ls->current == '\t'){
// 			next(ls);
// 			continue;
// 		}
    if (ishex ? lisxdigit(ls->current) : lisdigit(ls->current))
      save_and_next(ls);
    else if (ls->current == '.')
      save_and_next(ls);
    else if(!(ishex && lisxdigit_cyr(ls))) break;
  }
  save(ls, '\0');
  if (luaO_str2num(luaZ_buffer(ls->buff), &obj) == 0)  /* format error? */
    lexerror(ls, "malformed number", TK_FLT);
  if (ttisinteger(&obj)) {
    seminfo->i = ivalue(&obj);
    return TK_INT;
  }
  else {
    lua_assert(ttisfloat(&obj));
    seminfo->r = fltvalue(&obj);
    return TK_FLT;
  }
}


/*
** skip a sequence '[=*[' or ']=*]'; if sequence is well formed, return
** its number of '='s; otherwise, return a negative number (-1 iff there
** are no '='s after initial bracket)
*/
static int skip_sep (LexState *ls) {
  int count = 0;
  int s = ls->current;
  lua_assert(s == '[' || s == ']');
  save_and_next(ls);
  while (ls->current == '=') {
    save_and_next(ls);
    count++;
  }
  return (ls->current == s) ? count : (-count) - 1;
}


static void read_long_string (LexState *ls, SemInfo *seminfo, int sep) {
  int line = ls->linenumber;  /* initial line (for error message) */
  save_and_next(ls);  /* skip 2nd '[' */
  if (currIsNewline(ls))  /* string starts with a newline? */
    inclinenumber(ls);  /* skip it */
  for (;;) {
    switch (ls->current) {
      case EOZ: {  /* error */
        const char *what = (seminfo ? "string" : "comment");
        const char *msg = luaO_pushfstring(ls->L,
                     "unfinished long %s (starting at line %d)", what, line);
        lexerror(ls, msg, TK_EOS);
        break;  /* to avoid warnings */
      }
      case ']': {
        if (skip_sep(ls) == sep) {
          save_and_next(ls);  /* skip 2nd ']' */
          goto endloop;
        }
        break;
      }
      case '\n': case '\r': {
        save(ls, '\n');
        inclinenumber(ls);
        if (!seminfo) luaZ_resetbuffer(ls->buff);  /* avoid wasting space */
        break;
      }
      default: {
        if (seminfo) save_and_next(ls);
        else next(ls);
      }
    }
  } endloop:
  if (seminfo)
    seminfo->ts = luaX_newstring(ls, luaZ_buffer(ls->buff) + (2 + sep),
                                     luaZ_bufflen(ls->buff) - 2*(2 + sep));
}


static void esccheck (LexState *ls, int c, const char *msg) {
  if (!c) {
    if (ls->current != EOZ)
      save_and_next(ls);  /* add current to buffer for error message */
    lexerror(ls, msg, TK_STRING);
  }
}


static int gethexa (LexState *ls) {
  save_and_next(ls);
  esccheck (ls, lisxdigit(ls->current), "hexadecimal digit expected");
  return luaO_hexavalue(ls->current);
}


static int readhexaesc (LexState *ls) {
  int r = gethexa(ls);
  r = (r << 4) + gethexa(ls);
  luaZ_buffremove(ls->buff, 2);  /* remove saved chars from buffer */
  return r;
}


static unsigned long readutf8esc (LexState *ls) {
  unsigned long r;
  int i = 4;  /* chars to be removed: '\', 'u', '{', and first digit */
  save_and_next(ls);  /* skip 'u' */
  esccheck(ls, ls->current == '{', "missing '{'");
  r = gethexa(ls);  /* must have at least one digit */
  while ((save_and_next(ls), lisxdigit(ls->current))) {
    i++;
    r = (r << 4) + luaO_hexavalue(ls->current);
    esccheck(ls, r <= 0x10FFFF, "UTF-8 value too large");
  }
  esccheck(ls, ls->current == '}', "missing '}'");
  next(ls);  /* skip '}' */
  luaZ_buffremove(ls->buff, i);  /* remove saved chars from buffer */
  return r;
}


static void utf8esc (LexState *ls) {
  char buff[UTF8BUFFSZ];
  int n = luaO_utf8esc(buff, readutf8esc(ls));
  for (; n > 0; n--)  /* add 'buff' to string */
    save(ls, buff[UTF8BUFFSZ - n]);
}


static int readdecesc (LexState *ls) {
  int i;
  int r = 0;  /* result accumulator */
  for (i = 0; i < 3 && lisdigit(ls->current); i++) {  /* read up to 3 digits */
    r = 10*r + ls->current - '0';
    save_and_next(ls);
  }
  esccheck(ls, r <= UCHAR_MAX, "decimal escape too large");
  luaZ_buffremove(ls->buff, i);  /* remove read digits from buffer */
  return r;
}


static void read_string (LexState *ls, int del, SemInfo *seminfo) {
  save_and_next(ls);  /* keep delimiter (for error messages) */
  while (ls->current != del) {
    switch (ls->current) {
      case EOZ:
        lexerror(ls, "unfinished string", TK_EOS);
        break;  /* to avoid warnings */
      case '\n':
      case '\r':
        lexerror(ls, "unfinished string", TK_STRING);
        break;  /* to avoid warnings */
      case '\\': {  /* escape sequences */
        int c;  /* final character to be saved */
        save_and_next(ls);  /* keep '\\' for error messages */
        switch (ls->current) {
          case 0xd0:
						switch (zlookc(ls->z)) {
		          case 0xbd: next(ls); c = '\n'; goto read_save;
		          case 0xb2: next(ls); c = '\r'; goto read_save;
							default: lexerror(ls, "invalid escape sequence2", TK_STRING);break;
						}
						break;
          case 0xd1: 
						switch (zlookc(ls->z)) {
		          case 0x81: next(ls); c = '\b'; goto read_save;
		          case 0x82: next(ls); c = '\t'; goto read_save;
							default: lexerror(ls, "invalid escape sequence3", TK_STRING);break;
						}
						break;
          case 'a': c = '\a'; goto read_save;
          case 'b': c = '\b'; goto read_save;
          case 'f': c = '\f'; goto read_save;
          case 'n': c = '\n'; goto read_save;
          case 'r': c = '\r'; goto read_save;
          case 't': c = '\t'; goto read_save;
          case 'v': c = '\v'; goto read_save;
          case 'x': c = readhexaesc(ls); goto read_save;
          case 'u': utf8esc(ls);  goto no_save;
          case '\n': case '\r':
            inclinenumber(ls); c = '\n'; goto only_save;
          case '\\': case '\"': case '\'':
            c = ls->current; goto read_save;
          case EOZ: goto no_save;  /* will raise an error next loop */
          case 'z': {  /* zap following span of spaces */
            luaZ_buffremove(ls->buff, 1);  /* remove '\\' */
            next(ls);  /* skip the 'z' */
            while (lisspace(ls->current)) {
              if (currIsNewline(ls)) inclinenumber(ls);
              else next(ls);
            }
            goto no_save;
          }
          default: {
            esccheck(ls, lisdigit(ls->current), "invalid escape sequence");
            c = readdecesc(ls);  /* digital escape '\ddd' */
            goto only_save;
          }
        }
       read_save:
         next(ls);
         /* go through */
       only_save:
         luaZ_buffremove(ls->buff, 1);  /* remove '\\' */
         save(ls, c);
         /* go through */
       no_save: break;
      }
      default:
        save_and_next(ls);
    }
  }
  save_and_next(ls);  /* skip delimiter */
  seminfo->ts = luaX_newstring(ls, luaZ_buffer(ls->buff) + 1,
                                   luaZ_bufflen(ls->buff) - 2);
}


static int llex (LexState *ls, SemInfo *seminfo) {
  luaZ_resetbuffer(ls->buff);
  for (;;) {
    switch (ls->current) {
      case '\n': case '\r': {  /* line breaks */
        inclinenumber(ls);
        break;
      }
      case ' ': case '\f': case '\t': case '\v': {  /* spaces */
        next(ls);
        break;
      }
      case '-': {  /* '-' or '--' (comment) */
        next(ls);
        if (ls->current != '-') return '-';
        /* else is a comment */
        next(ls);
        if (ls->current == '[') {  /* long comment? */
          int sep = skip_sep(ls);
          luaZ_resetbuffer(ls->buff);  /* 'skip_sep' may dirty the buffer */
          if (sep >= 0) {
            read_long_string(ls, NULL, sep);  /* skip long comment */
            luaZ_resetbuffer(ls->buff);  /* previous call may dirty the buff. */
            break;
          }
        }
        /* else short comment */
        while (!currIsNewline(ls) && ls->current != EOZ)
          next(ls);  /* skip until end of line (or end of file) */
        break;
      }
      case '[': {  /* long string or simply '[' */
        int sep = skip_sep(ls);
        if (sep >= 0) {
          read_long_string(ls, seminfo, sep);
          return TK_STRING;
        }
        else if (sep != -1)  /* '[=...' missing second bracket */
          lexerror(ls, "invalid long string delimiter", TK_STRING);
        return '[';
      }
      case '=': {
        next(ls);
        if (check_next1(ls, '=')) return TK_EQ;
        else return '=';
      }
      case '<': {
        next(ls);
        if (check_next1(ls, '=')) return TK_LE;
        else if (check_next1(ls, '<')) return TK_SHL;
        else return '<';
      }
      case '>': {
        next(ls);
        if (check_next1(ls, '=')) return TK_GE;
        else if (check_next1(ls, '>')) return TK_SHR;
        else return '>';
      }
      case '/': {
        next(ls);
        if (check_next1(ls, '/')) return TK_IDIV;
        else return '/';
      }
      case '~': {
        next(ls);
        if (check_next1(ls, '=')) return TK_NE;
        else return '~';
      }
      case '!': {
        next(ls);
        if (check_next1(ls, '=')) return TK_NE;
        else return '~';
      }
      case ':': {
        next(ls);
        if (check_next1(ls, ':')) return TK_DBCOLON;
        else return ':';
      }
      case '"': case '\'': {  /* short literal strings */
        read_string(ls, ls->current, seminfo);
        return TK_STRING;
      }
      case '.': {  /* '.', '..', '...', or number */
        save_and_next(ls);
        if (check_next1(ls, '.')) {
          if (check_next1(ls, '.'))
            return TK_DOTS;   /* '...' */
          else return TK_CONCAT;   /* '..' */
        }
        else if (!lisdigit(ls->current)) return '.';
        else return read_numeral(ls, seminfo);
      }
      case 226: {  /* '.', '..', '...', or number */
        next(ls);
        if (check_next1(ls, 0x84) && check_next1(ls, 0x96))
					return '#';   /* '...' */

        //else return '\xE2';
      }
      case '0': case '1': case '2': case '3': case '4':
      case '5': case '6': case '7': case '8': case '9': {
        return read_numeral(ls, seminfo);
      }
      case EOZ: {
        return TK_EOS;
      }
      default: {
        if (lislalpha(ls->current)) {  /* identifier or reserved word? */
          TString *ts;
          do {
            save_and_next(ls);
          } while (lislalnum(ls->current));
			// printf("\nluaX_newstring: \"%.*s\"\n", luaZ_bufflen(ls->buff), luaZ_buffer(ls->buff));
          ts = luaX_newstring(ls, luaZ_buffer(ls->buff),
                                  luaZ_bufflen(ls->buff));
          seminfo->ts = ts;
          if (isreserved(ts))  /* reserved word? */
            return ts->extra - 1 + FIRST_RESERVED;
          else {
            return TK_NAME;
          }
        }
        else {  /* single-char tokens (+ - / ...) */
          int c = ls->current;
          next(ls);
          return c;
        }
      }
    }
  }
}


void luaX_next (LexState *ls) {
  ls->lastline = ls->linenumber;
  if (ls->lookahead.token != TK_EOS) {  /* is there a look-ahead token? */
    ls->t = ls->lookahead;  /* use this one */
    ls->lookahead.token = TK_EOS;  /* and discharge it */
  }
  else
    ls->t.token = llex(ls, &ls->t.seminfo);  /* read next token */
}


int luaX_lookahead (LexState *ls) {
  lua_assert(ls->lookahead.token == TK_EOS);
  ls->lookahead.token = llex(ls, &ls->lookahead.seminfo);
  return ls->lookahead.token;
}

