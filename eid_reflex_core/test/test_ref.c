#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include "../src/libeid.h"

int main(void){
    FILE *f=fopen("test/test_vectors.hex","r");
    if(!f){perror("open"); return EXIT_FAILURE;}
    eid_ctx_t ctx={1.2f,1.0f,0.05f,0.0f};
    unsigned H,F,O,exp_dhdt,exp_alarm; 
    bool alarm; float dhdt; int pass=1; 
    char line[128];
    fgets(line,sizeof(line),f); // skip header
    while(fscanf(f,"%x %x %x %x %x",&H,&F,&O,&exp_dhdt,&exp_alarm)==5){
        dhdt=eid_update(&ctx,*(float*)&H,*(float*)&F,*(float*)&O,&alarm);
        unsigned got=*(unsigned*)&dhdt;
        if(fabsf(dhdt-*(float*)&exp_dhdt)>1e-4 || alarm!=exp_alarm){
            pass=0; break;
        }
    }
    fclose(f);
    if(pass){
        printf("C-MODEL PASS\n");
        return EXIT_SUCCESS;
    }else{
        printf("C-MODEL FAIL\n");
        return EXIT_FAILURE;
    }
}
