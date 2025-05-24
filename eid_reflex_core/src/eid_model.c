#include "libeid.h"

float eid_update(eid_ctx_t *c,float H,float F,float O,bool *alarm){
    float dHdt = -c->alpha*H + c->beta*F - c->gamma*O + c->delta;
    *alarm = ((c->alpha/c->beta) < 1.0f);
    return dHdt;
}

/* TODO: valider précision µ sur 1 Ulp */
