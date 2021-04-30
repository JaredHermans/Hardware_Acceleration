#include <stdio.h>

int main()
{
	FILE *fp;

	fp = fopen("input_vectors.txt", "w+");
	for(int i = 0; i < 259200; i++) {
		fprintf(fp, "31a1 58f6\n");
		fprintf(fp, "7bdd d156\n");
		fprintf(fp, "fc17 59a7\n");
		fprintf(fp, "8b52 026a\n");
		fprintf(fp, "9ac3 eaec\n");
		fprintf(fp, "56af 95cd\n");
		fprintf(fp, "2fa7 91b8\n");
		fprintf(fp, "7956 ace2\n");
	}
	fclose(fp);
	return(0);
}
