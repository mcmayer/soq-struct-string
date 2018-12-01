#include "mystruct.h"
#include <string.h>
#include <stdio.h>

void f(MyStruct* p) {
    char* buf = p->str;
    strncpy(buf, "Hello", 64);
    p->num++;
}

/*
int main() {
    char buf[64];
    MyStruct m = { 1, buf } ;
    f(&m);
    printf("num=%d, str=%s\n", m.num, m.str);
    printf("sizeof(MyStruct) = %d\n", sizeof(MyStruct));
}
*/