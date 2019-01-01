/*
** $Id: ltm.c,v 2.38 2016/12/22 13:08:50 roberto Exp $
** Tag methods
** See Copyright Notice in lua.h
*/

#define ltm_c
#define LUA_CORE

#include "lprefix.h"


#include <string.h>

#include "lua.h"

#include "ldebug.h"
#include "ldo.h"
#include "lobject.h"
#include "lstate.h"
#include "lstring.h"
#include "ltable.h"
#include "ltm.h"
#include "lvm.h"


static const char udatatypename[] = "userdata";

LUAI_DDEF const char *const luaT_typenames_[LUA_TOTALTAGS] = {
  "no value",
  "nil", "boolean", udatatypename, "number",
  "string", "table", "function", udatatypename, "thread",
  "proto" /* this last case is used for tests only */
};


void luaT_init (lua_State *L) {
  static const char *const luaT_eventname[] = {  /* ORDER TM */
    "__index", "__newindex",
    "__gc", "__mode", "__len", "__eq",
    "__add", "__sub", "__mul", "__mod", "__pow",
    "__div", "__idiv",
    "__band", "__bor", "__bxor", "__shl", "__shr",
    "__unm", "__bnot", "__lt", "__le",
    "__concat", "__call"
  };
  int i;
  for (i=0; i<TM_N; i++) {
    G(L)->tmname[i] = luaS_new(L, luaT_eventname[i]);
    luaC_fix(L, obj2gco(G(L)->tmname[i]));  /* never collect these names */
  }

  static const char *const luaT_eventname_cyr[] = {  /* ORDER TM */
    "__\xd0\xb8\xd0\xbd\xd0\xb4\xd0\xb5\xd0\xba\xd1\x81", "__\xd0\xbd\xd0\xbe\xd0\xb2\xd1\x8b\xd0\xb9",

    "__\xd1\x81\xd0\xb1", "__\xd1\x80\xd0\xb5\xd0\xb6\xd0\xb8\xd0\xbc", "__\xd1\x80\xd0\xb0\xd0\xb7\xd0\xbc\xd0\xb5\xd1\x80", "__\xd1\x80\xd0\xb0\xd0\xb2\xd0\xbd\xd0\xbe",

    "__\xd1\x81\xd0\xbb\xd0\xbe\xd0\xb6", "__\xd0\xb2\xd1\x8b\xd1\x87", "__\xd1\x83\xd0\xbc\xd0\xbd\xd0\xbe\xd0\xb6", "__\xd0\xbe\xd1\x81\xd1\x82", "__\xd1\x81\xd1\x82\xd0\xb5\xd0\xbf",

    "__\xd0\xb4\xd0\xb5\xd0\xbb", "__\xd1\x86\xd0\xb5\xd0\xbb\xd0\xb4\xd0\xb5\xd0\xbb",

    "__\xd0\xb8", "__\xd0\xb8\xd0\xbb\xd0\xb8", "__\xd0\xb8\xd0\xbb\xd0\xb8\xd0\xbd\xd0\xb5", "__\xd1\x81\xd0\xb4\xd0\xb2\xd0\xb8\xd0\xb3\xd0\xbb", "__\xd1\x81\xd0\xb4\xd0\xb2\xd0\xb8\xd0\xb3\xd0\xbf",

    "__\xd1\x83\xd0\xbd\xd0\xbc", "__\xd0\xbd\xd0\xb5", "__\xd0\xbc\xd0\xb5\xd0\xbd\xd1\x8c\xd1\x88\xd0\xb5", "__\xd0\xbd\xd0\xb5\xd0\xb1\xd0\xbe\xd0\xbb\xd0\xb5\xd0\xb5",

    "__\xd0\xba\xd0\xbe\xd0\xbd\xd0\xba\xd0\xb0\xd1\x82", "__\xd0\xb2\xd1\x8b\xd0\xb7\xd0\xbe\xd0\xb2"
  };
  for (i=0; i<TM_N; i++) {
 // printf("%s:%s\n", luaT_eventname_cyr[i], luaT_eventname[i]);
    G(L)->tmname_cyr[i] = luaS_new(L, luaT_eventname_cyr[i]);
    luaC_fix(L, obj2gco(G(L)->tmname_cyr[i]));  /* never collect these names */
  }


}


/*
** function to be used with macro "fasttm": optimized for absence of
** tag methods
*/
const TValue *luaT_gettm (Table *events, TMS event, TString *ename) {
  const TValue *tm = luaH_getshortstr(events, ename);
  lua_assert(event <= TM_EQ);
  if (ttisnil(tm)) {  /* no tag method? */
    events->flags |= cast_byte(1u<<event);  /* cache this fact */
    return NULL;
  }
  else return tm;
}

const TValue *luaT_gettm2 (Table *events, TMS event, TString *ename, TString *ename2) {
  const TValue *tm = luaH_getshortstr(events, ename);
  lua_assert(event <= TM_EQ);
  if (ttisnil(tm)) {  /* no tag method? */
		tm = luaH_getshortstr(events, ename2);
		if (!ttisnil(tm)) return tm;
    events->flags |= cast_byte(1u<<event);  /* cache this fact */
    return NULL;
  }
  else return tm;
}


const TValue *luaT_gettmbyobj (lua_State *L, const TValue *o, TMS event) {
  Table *mt;
  switch (ttnov(o)) {
    case LUA_TTABLE:
      mt = hvalue(o)->metatable;
      break;
    case LUA_TUSERDATA:
      mt = uvalue(o)->metatable;
      break;
    default:
      mt = G(L)->mt[ttnov(o)];
  }
	if(mt){
		const TValue * e = luaH_getshortstr(mt, G(L)->tmname_cyr[event]);
		if(ttisnil(e)) e = luaH_getshortstr(mt, G(L)->tmname[event]);
		return e;
	}
  return luaO_nilobject;
}


/*
** Return the name of the type of an object. For tables and userdata
** with metatable, use their '__name' metafield, if present.
*/
const char *luaT_objtypename (lua_State *L, const TValue *o) {
  Table *mt;
  if ((ttistable(o) && (mt = hvalue(o)->metatable) != NULL) ||
      (ttisfulluserdata(o) && (mt = uvalue(o)->metatable) != NULL)) {
    const TValue *name = luaH_getshortstr(mt, luaS_new(L, "__name"));
    if (ttisstring(name))  /* is '__name' a string? */
      return getstr(tsvalue(name));  /* use it as type name */
  }
  return ttypename(ttnov(o));  /* else use standard type name */
}


void luaT_callTM (lua_State *L, const TValue *f, const TValue *p1,
                  const TValue *p2, TValue *p3, int hasres) {
  ptrdiff_t result = savestack(L, p3);
  StkId func = L->top;
  setobj2s(L, func, f);  /* push function (assume EXTRA_STACK) */
  setobj2s(L, func + 1, p1);  /* 1st argument */
  setobj2s(L, func + 2, p2);  /* 2nd argument */
  L->top += 3;
  if (!hasres)  /* no result? 'p3' is third argument */
    setobj2s(L, L->top++, p3);  /* 3rd argument */
  /* metamethod may yield only when called from Lua code */
  if (isLua(L->ci))
    luaD_call(L, func, hasres);
  else
    luaD_callnoyield(L, func, hasres);
  if (hasres) {  /* if has result, move it to its place */
    p3 = restorestack(L, result);
    setobjs2s(L, p3, --L->top);
  }
}


int luaT_callbinTM (lua_State *L, const TValue *p1, const TValue *p2,
                    StkId res, TMS event) {
  const TValue *tm = luaT_gettmbyobj(L, p1, event);  /* try first operand */
  if (ttisnil(tm))
    tm = luaT_gettmbyobj(L, p2, event);  /* try second operand */
  if (ttisnil(tm)) return 0;
  luaT_callTM(L, tm, p1, p2, res, 1);
  return 1;
}


void luaT_trybinTM (lua_State *L, const TValue *p1, const TValue *p2,
                    StkId res, TMS event) {
  if (!luaT_callbinTM(L, p1, p2, res, event)) {
    switch (event) {
      case TM_CONCAT:
        luaG_concaterror(L, p1, p2);
      /* call never returns, but to avoid warnings: *//* FALLTHROUGH */
      case TM_BAND: case TM_BOR: case TM_BXOR:
      case TM_SHL: case TM_SHR: case TM_BNOT: {
        lua_Number dummy;
        if (tonumber(p1, &dummy) && tonumber(p2, &dummy))
          luaG_tointerror(L, p1, p2);
        else
          luaG_opinterror(L, p1, p2, "perform bitwise operation on");
      }
      /* calls never return, but to avoid warnings: *//* FALLTHROUGH */
      default:
        luaG_opinterror(L, p1, p2, "perform arithmetic on");
    }
  }
}


int luaT_callorderTM (lua_State *L, const TValue *p1, const TValue *p2,
                      TMS event) {
  if (!luaT_callbinTM(L, p1, p2, L->top, event))
    return -1;  /* no metamethod */
  else
    return !l_isfalse(L->top);
}

