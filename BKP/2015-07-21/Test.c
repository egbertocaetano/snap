/*Compilador snap*/
#include <iostream>
#include <string.h>
#include <stdio.h>
using namespace std;

int main(void)
{
	int temp0;
	int temp1;
	int temp2;
	int temp3;
	int temp4;
	int temp5;
	int temp6;
	int temp7;
	int temp8;


	temp0 = 1;
	temp1 = temp0;


	temp2 = 0;
	temp3 = temp2;

	INICIO_LOOP_LABEL0:

	temp4 = 3;
	temp5 = temp3 < temp4;

	if(!temp5) goto FIM_LOOP_LABEL0;

	temp7 = 1;
	temp8 =  + temp7;
	temp1 = temp8;

	LABEL1:
	temp6 = 1;
	temp3 = temp3 + temp6;
	goto INICIO_LOOP_LABEL0;

	FIM_LOOP_LABEL0:
	return 0;
}
