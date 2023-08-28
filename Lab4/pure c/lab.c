#include <math.h>
#include <stdio.h>


unsigned long long factorial(unsigned int n) {
    if (n == 0 || n == 1) {
        return 1;
    } else {
        return n * factorial(n - 1);
    }
}

double printsteps(float x, int mxn){
    double res = x;
    double step = -(1.0 /6) * pow(x, 3);
    res +=step;
    printf("Res: %f, Step: %f\n", res, step);
    for(int n = 2; n < mxn; n++)
    {
        step*=(-1)*(1 - 1.0/(2*(n))) * (2*n - 1.0) / (2*n + 1.0) * x*x;
        res+=step;
        printf("Res: %f, Step: %f\n", res, step);
    }
    return res;
}

float traditional(float x){
    float res = log( x + sqrt(1 + x*x));

    return res;
}

int main(){

    float x;
    scanf("%f", &x);
    printsteps(x, 20);
    printf("%f\n", traditional(x));
    return 0;
}