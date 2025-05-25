#include "libeid.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc,char **argv){
    const char *csv = (argc>1)?argv[1]:"test/test_vectors.csv";
    FILE *f=fopen(csv,"r");
    if(!f){perror("open");return 1;}
    char line[128];
    fgets(line,sizeof line,f); // header
    eid_ctx_t ctx; eid_init(&ctx,0.2f,0.15f,0.0f,0.0f);
    int idx=0; int pass=1;
    while(fgets(line,sizeof line,f)){
        unsigned h,fv,o,dhdt_exp; int alarm_exp;
        if(sscanf(line,"0x%x,0x%x,0x%x,0x%x,%d",&h,&fv,&o,&dhdt_exp,&alarm_exp)!=5) continue;
        float H=*(float*)&h; float F=*(float*)&fv; float O=*(float*)&o;
        bool alarm=false; float d= eid_update(&ctx,H,F,O,&alarm);
        float ref=*(float*)&dhdt_exp;
        if(fabsf((d-ref)/ref)>1e-3 || alarm!=alarm_exp){
            printf("FAIL idx=%d\n",idx); pass=0; break;}
        idx++;}
    fclose(f); if(pass) printf("PASS\n");
    return pass?0:1;
}
