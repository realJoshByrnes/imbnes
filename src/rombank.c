#include <stdio.h>
#include <stdlib.h>
#include <libgen.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>

struct
{
	char name[0x1C];
	unsigned short offset;
	unsigned short size;
}gameList[4096];

int gameNum;

unsigned char supportedMappers[] =
{
	0, 1, 2, 3, 4, 7, 9, 10, 11, 33, 34, 38, 66, 70, 71, 79,
	87, 140, 180, 185
};

int mapper_is_supported(int number)
{
	int x;
	
	for(x = 0; x < sizeof(supportedMappers); x++)
	{
		if(supportedMappers[x] == number)
			return 1;
	}
	
	return 0;
}
	
void make_and_output_header(FILE *out)
{
	int i,k;
	
	gameList[0].offset = (((gameNum+1)*0x20)/2048)+1;
	
	for(i = 1; i < gameNum; i++)
		gameList[i].offset = gameList[i-1].offset + (gameList[i-1].size / 0x10);
	
	gameList[gameNum].offset = gameList[gameNum-1].offset;
	gameList[gameNum].size = gameList[gameNum-1].size;
	
	gameList[gameNum].name[0] = 0xFF;
	
	for(k = 1; k < 0x1C; k++) 
		gameList[gameNum].name[k] = ' ';
	
	for(i = 0; i <= gameNum; i++)
	{
		for(k = 0; k < 0x1C; k++)
			fputc(gameList[i].name[k], out);
		
		fputc(gameList[i].offset & 0xFF, out);
		fputc(gameList[i].offset >> 8, out);
		
		fputc(gameList[i].size & 0xFF, out);
		fputc(gameList[i].size >> 8, out);
	}

	fseek(out, gameList[0].offset*2048, SEEK_SET);
}
	
int main(int argc, char *argv[])
{
	int i,k,t;
	char *p,*tok[2];
	int list = 0;
	char linebuf[8192];
	int mapperNumber;
	FILE *listFile;
	
	while((k = getopt(argc, argv, "l")) != -1)
	{
		switch(k)
		{
			case 'l':
				list = 1;
			break;
		}
	}
	
	argc -= optind;
	argv += optind;
	
	if(argc < 2)
	{
		printf("usage: rombank [output] [roms ...]\n");
		printf("       rombank -l [output] [list]\n");
		
		return EXIT_FAILURE;
	}
		
	FILE *out = fopen(argv[0], "wb");
	
	if(!out)
	{
		printf("Cannot open output file.\n");
		return EXIT_FAILURE;
	}
	
	gameNum = 0;
	
	if(!list)
	{
		for(i = 1; i < argc && gameNum < 4095; i++)
		{
			FILE *f = fopen(argv[i], "rb");
		
			if(!f)
			{
				printf("Cannot open file %s\n", argv[i]);
				fclose(out);
				
				remove(argv[0]);
				
				return EXIT_FAILURE;
			}
		
			fseek(f,0,SEEK_END);
			t = ftell(f);
			
			fseek(f,6,SEEK_SET);
			
			mapperNumber = (fgetc(f) & 0xF0) >> 4;
			mapperNumber |= fgetc(f) & 0xF0;
			
			for(k = 0; k < 0x1C; k++) 
				gameList[gameNum].name[k] = ' ';
		
			char *bn = basename(argv[i]);
		
			strncpy(gameList[gameNum].name, bn,
				(strlen(bn) < 0x1C) ? strlen(bn) : 0x1C);
		
			if(!mapper_is_supported(mapperNumber))
			{
				printf("Game \"%s\" uses an unsupported mapper number (%d)\n", 
					gameList[gameNum].name, mapperNumber);
				fclose(out);
				remove(argv[0]);
				
				return EXIT_FAILURE;
			}
			
			if(t & 2047)
				t = (t|2047)+1;
		
			gameList[gameNum].size = t / 0x80;
		
			gameNum++;
			fclose(f);
		}
	}
	else
	{
		listFile = fopen(argv[1], "rb");
		
		if(!listFile)
		{
			printf("Could not open list file.\n");
			fclose(out);
			remove(argv[0]);
			
			return EXIT_FAILURE;
		}
		
		for(i = 0; fgets(linebuf, 8192, listFile); i++)
		{
			while((p = strchr(linebuf, '\n')))
				*p = '\0';
		
			while((p = strchr(linebuf, '\r')))
				*p = '\0';
			
			// ckeck if it is only whitespace
			for(k = 0, t = 0; linebuf[k]; k++)
			{
				if(!isspace((int)linebuf[k]))
				{
					t = 1;
					break;
				}
			}

			if(!t)
				continue;
			
			for(p = linebuf, k = 0; (tok[k] = strtok(p, "=")) && k<2;
				p = NULL, k++);
		
			if(tok[0] == NULL)
			{
				printf("Error at line %d: line is invalid\n", i+1);
				fclose(out);
				remove(argv[0]);
			}
			
			FILE *f = fopen(tok[0], "rb");
			
			fseek(f,0,SEEK_END);
			t = ftell(f);
			fseek(f,6,SEEK_SET);
			mapperNumber = (fgetc(f) & 0xF0) >> 4;
			mapperNumber |= fgetc(f) & 0xF0;
				
			if(!f)
			{
				printf("Cannot open file %s\n", tok[0]);
				fclose(out);
				
				remove(argv[0]);
				
				return EXIT_FAILURE;
			}
			
			for(k = 0; k < 0x1C; k++) 
				gameList[gameNum].name[k] = ' ';
		
			char *bn = tok[1] ? tok[1] : basename(tok[0]);
		
			strncpy(gameList[gameNum].name, bn,
				(strlen(bn) < 0x1C) ? strlen(bn) : 0x1C);
			
			if(!mapper_is_supported(mapperNumber))
			{
				printf("Error at line %d: game \"%s\" uses an unsupported mapper number (%d)\n", i+1, 
					gameList[gameNum].name, mapperNumber);
				fclose(out);
				remove(argv[0]);
				
				return EXIT_FAILURE;
			}
		
			if(t & 2047)
				t = (t|2047)+1;
		
			gameList[gameNum].size = t / 0x80;
		
			gameNum++;
			fclose(f);
		}
			
		fclose(listFile);
	}	
		
	make_and_output_header(out);
	
	if(!list)
	{
		for(i = 0; i < gameNum; i++)
		{
			FILE *f = fopen(argv[i+1], "rb");
		
			//fseek(f, gameList[i].offset * 2048, SEEK_SET);
		
			fseek(f,0,SEEK_END);
			t = ftell(f);
			fseek(f,0,SEEK_SET);
			
			for(k = 0; k < t; k++)
				fputc(fgetc(f), out);
		
			fclose(f);
		
			for(; k & 2047; k++)
				fputc(0, out);
		}
	}
	else
	{
		fclose(listFile);
		listFile = fopen(argv[1], "rb");
		
		for(i = 0; fgets(linebuf, 8192, listFile); i++)
		{			
			while((p = strchr(linebuf, '\n')))
				*p = '\0';
		
			while((p = strchr(linebuf, '\r')))
				*p = '\0';
			
			// ckeck if it is only whitespace
			for(k = 0, t = 0; linebuf[k]; k++)
			{
				if(!isspace((int)linebuf[k]))
				{
					t = 1;
					break;
				}
			}

			if(!t)
				continue;
			
			for(p = linebuf, k = 0; (tok[k] = strtok(p, "=")) && k<2;
				p = NULL, k++);
		
			FILE *f = fopen(tok[0], "rb");
			
			fseek(f,0,SEEK_END);
			t = ftell(f);
			fseek(f,0,SEEK_SET);
			
			for(k = 0; k < t; k++)
			fputc(fgetc(f), out);
		
			fclose(f);
		
			for(; k & 2047; k++)
				fputc(0, out);
		
			gameNum++;
			fclose(f);
		}
	}
	
	fclose(out);
		
	return EXIT_SUCCESS;
}
