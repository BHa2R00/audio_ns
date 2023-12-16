#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define fix16ash		10
#define multfix16(a,b)	((int)((((signed long long)(a))*((signed long long)(b)))>>fix16ash))
#define float2fix16(a)	((int)((a)*1.0*(1<<fix16ash)))
#define fix2float16(a)	((float)(a)/(1.0*(1<<fix16ash)))
#define fix2int16(a)	((int)((a)>>fix16ash))
#define int2fix16(a)	((int)((a)<<fix16ash))
#define divfix16(a,b)	((int)((((signed long long)(a)<<fix16ash)/(b))))
#define sqrtfix16(a)	(float2fix16(sqrt(fix2float16(a))))
#define absfix16(a)		abs(a)

int main(int argc, char** argv){
	int k;
	if(strcmp("float2fix16",argv[1]) == 0){
		float a;
		for(k = 2; k< argc; k++){
			sscanf(argv[k],"%f",&a);
			printf("%f, %d		", a, float2fix16(a));
		}
		printf("\n");
	}
	else if(strcmp("fix2float16",argv[1]) == 0){
		int a;
		for(k = 2; k< argc; k++){
			sscanf(argv[k],"%d",&a);
			printf("%f ", fix2float16(a));
		}
		printf("\n");
	}
	else{
		printf("float2fix16 <float numbers>\n");
		printf("fix2float16 <hex numbers>\n");
	}
	return 0;
}
