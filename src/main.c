#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int main()
{
    lua_State *L = luaL_newstate();
    if(L == NULL)
    {
        fprintf(stderr, "Failed to create Lua state\n");
        return EXIT_FAILURE;
    }

    luaL_openlibs(L);

    if(luaL_dofile(L, "script.lua") != LUA_OK)
    {
        fprintf(stderr, "Error executing Lua script: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return EXIT_FAILURE;
    }

    lua_close(L);
    return EXIT_SUCCESS;
}