#include "string.h"
#include "memory_map.h"


int main(void) {
    csr_tohost(0);
    char str[10] = "Hll Wrld!";

    if (strcmp(str ,"Hll Wrld!") == 0) {
        // pass
        csr_tohost(1);
    } else {
        // fail code 2
        csr_tohost(2);
    }

    // spin
    for( ; ; ) {
        asm volatile ("nop");
    }
}
