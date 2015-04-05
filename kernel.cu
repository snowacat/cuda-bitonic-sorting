#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "iostream"

#include "bitonic.h"

#define THREADS 128
#define BLOCKS 32768
#define NUM_VALS THREADS*BLOCKS

using namespace std;

void array_fill(float *arr, int length)
{
	srand(time(NULL));
	for (int i = 0; i < length; ++i) 
	{
		arr[i] = (float) rand() / (float) RAND_MAX;
	}
}

void Print(float *arr)
{
	for (int i = 0; i < 1000000; i+=1000)
	{
		printf("%f ", arr[i]);
	}
}

int main(void)
{
	float *values = (float*) malloc(NUM_VALS * sizeof(float));	
	array_fill(values, NUM_VALS);

	clock_t start = clock();
	bitonic_sort(values, NUM_VALS, BLOCKS, THREADS);

	cout << "Time: " << ((double) (clock() - start)) / CLOCKS_PER_SEC << " seconds." << endl;
	//Print(values);
}