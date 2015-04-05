#include "cuda_runtime.h"

__global__  void bitonic_sort_step(float *dev_values, int j, int k)
{
	unsigned int i, ixj; /* Sorting partners: i and ixj */
	i = threadIdx.x + blockDim.x * blockIdx.x;
	ixj = i^j;

	/* The threads with the lowest ids sort the array. */
	if ((ixj) > i) 
	{
		if ((i&k) == 0) 
		{
			/* Sort ascending */
			if (dev_values[i]>dev_values[ixj]) 
			{
				/* exchange(i,ixj); */
				float temp = dev_values[i];
				dev_values[i] = dev_values[ixj];
				dev_values[ixj] = temp;
			}
		}
		if ((i&k) != 0) 
		{
			/* Sort descending */
			if (dev_values[i]<dev_values[ixj]) 
			{
				/* exchange(i,ixj); */
				float temp = dev_values[i];
				dev_values[i] = dev_values[ixj];
				dev_values[ixj] = temp;
			}
		}
	}
}

void bitonic_sort(float *values, int NUM_VALS, int BLOCKS, int THREADS)
{
	float *dev_values;
	size_t size = NUM_VALS * sizeof(float);

	// Allocate sapce for device copies of values
	cudaMalloc((void**) &dev_values, size);	
	cudaMemcpy(dev_values, values, size, cudaMemcpyHostToDevice);

	// задание параметров выполнения ядра
	dim3 blocks(BLOCKS, 1);    /* Number of blocks   */
	dim3 threads(THREADS, 1);  /* Number of threads  */

	int j, k;
	/* Major step */
	for (k = 2; k <= NUM_VALS; k <<= 1)
	{
		/* Minor step */
		for (j = k >> 1; j > 0; j >>= 1) 
		{
			// запуск ядра на выполнение
			bitonic_sort_step <<<blocks, threads>>>(dev_values, j, k);
		}
	}
	cudaMemcpy(values, dev_values, size, cudaMemcpyDeviceToHost);
	cudaFree(dev_values);
}
