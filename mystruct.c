#include "mystruct.h"
#include <string.h>
#include <stdio.h>

uint32_t num = 0;

void f(MyStruct* p) {
    char* buf = p->str;
    snprintf(buf, BUFLEN, "Hello visitor #%d", ++num);
    p->num = num;
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