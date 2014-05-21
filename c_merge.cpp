#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/dir.h>

#define SUCCESS 1
#define READ_BUFFER_SIZE 8192

int main(int argc,char** argv)
{
        if(argc < 3)
        {
                printf("Input param error! exit...\nPls use ./%s src_s dst_file\n", argv[0]);
                exit(0);
        }

        char* read_buffer = new char[READ_BUFFER_SIZE];

        long fileSize = 0L;
        int nread = 0;

        int read_index = 1;
        int dst_index = argc - 1; /* 0 for program name, last for dst */

        while(read_index < dst_index)
        {
                FILE *fd;
                FILE *outFile;
                outFile = fopen(argv[dst_index],"a+");
                if(NULL == outFile)
                {
                        printf("open output file error!\n");
                }
                if((fd=fopen(argv[read_index],"r"))!=NULL)
                {
                        //printf("Combining %s now ...\n", argv[read_index]);
                        fseek(fd,0,SEEK_END);
                        fileSize = ftell(fd);
                        rewind(fd);

                        while((nread=fread(read_buffer,sizeof(char),READ_BUFFER_SIZE,fd))>0)
                        {
                                fwrite(read_buffer,sizeof(char),nread,outFile);
                        }
                        fclose(fd);
                        fclose(outFile);
                }
                read_index++;
        }
        delete[] read_buffer;
        return SUCCESS;
}
