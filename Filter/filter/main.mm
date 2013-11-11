#import <Cocoa/Cocoa.h>

#include<sys/types.h>
#include<dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include<pthread.h>

#include<stdio.h>
#include<stdlib.h>
#include<string.h>

extern "C" {
    #include "libjpeg/jpeglib.h"
}

#define SRC_PATH "/Applications/MAMP/htdocs/Kupan.localized/picasa/db/photo/"
#define DES_PATH "/Applications/MAMP/htdocs/faces/"

#define HTTP_HOST_PATH "/Applications/MAMP/htdocs/"

//#define PROCESS_PHOTO

int encode(const unsigned char* data, int src_width, int src_height,
           const char* path, int x_pos, int y_pos, int width, int height) {
    FILE *fp = fopen(path,"wb");
    if (!fp || !data) {
        return 0;
    }
    int src_row_width = src_width*3;
    int dst_row_width = width*3;
    unsigned char* temp = (unsigned char*)malloc(dst_row_width*height);
    for (int y = 0; y < height; ++y) {
        memcpy(temp + dst_row_width*y,
               data + src_row_width*(y+y_pos) + x_pos*3,
               dst_row_width);
    }
    jpeg_compress_struct jcs;
    jpeg_error_mgr jem;
    
    JSAMPROW row_pointer[1];
    jcs.err = jpeg_std_error(&jem);
    jpeg_create_compress(&jcs);
    
    
    jpeg_stdio_dest(&jcs, fp);
    jcs.image_width = width; // 位图的宽和高，单位为像素
    jcs.image_height = height;
    jcs.input_components = 3; // 在此为1,表示灰度图， 如果是彩色位图，则为3
    jcs.in_color_space = JCS_RGB; //JCS_GRAYSCALE表示灰度图，JCS_RGB表示彩色图像
    jpeg_set_defaults(&jcs);
    jpeg_set_quality (&jcs, 80, TRUE);
    jpeg_start_compress(&jcs, TRUE);
    
    while (jcs.next_scanline < jcs.image_height) {
        row_pointer[0] = (JSAMPROW)&temp[jcs.next_scanline * width*3];
        jpeg_write_scanlines(&jcs, row_pointer, 1);
    }
    
    jpeg_finish_compress(&jcs);
    jpeg_destroy_compress(&jcs);
    fclose(fp);
    
    free(temp);
    
    return 1;
}

unsigned char* decode(const char *path, int *width, int *height) {
    unsigned char* data = 0;
    FILE *input_file = fopen(path, "rb");
    if (!input_file) {
        return 0;
    }
    
    unsigned char header[10] = {0};
    fread(header, 3, 1, input_file);
    
    if (!(header[0] == 0xff &&
		header[1] == 0xd8 &&
		header[2] == 0xff))
	{
        return 0;
		//iamgeType = IMAGE_JPG;
	}
    
    fseek(input_file, 0, SEEK_SET);
    
    jpeg_error_mgr jerr;
    jpeg_decompress_struct cinfo;
    JSAMPARRAY buffer;
    int row_width;
    
    cinfo.err = jpeg_std_error(&jerr);
    
    jpeg_create_decompress(&cinfo);
    
    jpeg_stdio_src(&cinfo, input_file);
    jpeg_read_header(&cinfo, TRUE);
    jpeg_start_decompress(&cinfo);
    
    *width = cinfo.output_width;
    *height = cinfo.output_height;
    
    row_width = cinfo.output_width * cinfo.output_components;
    
    buffer = (*cinfo.mem->alloc_sarray)((j_common_ptr) &cinfo, JPOOL_IMAGE, row_width, 1);
    
    data = (unsigned char *)malloc(row_width * cinfo.output_height);
    memset(data, 0, row_width * cinfo.output_height);
    unsigned char *tmp = data;
    
    while (cinfo.output_scanline < cinfo.output_height) {
        jpeg_read_scanlines(&cinfo, buffer, 1);
        
        memcpy(tmp, *buffer, row_width);
        tmp += row_width;
    }
    
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
    
    fclose(input_file);
    
    return data;
}

int process_photo(const unsigned char *data, int width, int height, const char *clip, const char *dst) {
    if (!data || width == 0 || height == 0)
        return 0;
    
    char _clip[100] = {0};
    strcpy(_clip, clip);
    int left = 0, top = 0, right = 0, bottom = 0;
    sscanf(_clip+12, "%x", &bottom);_clip[12] = 0;
    sscanf(_clip+8, "%x", &right);_clip[8] = 0;
    sscanf(_clip+4, "%x", &top);_clip[4] = 0;
    sscanf(_clip, "%x", &left);
    
    left   = left * width / 65536;
    top    = top * height / 65536;
    right  = right * width / 65536;
    bottom = bottom * height / 65536;
    
    return encode(data, width, height, dst, left, top, right-left, bottom-top);
}

typedef struct People
{
    char id[100];
    char name[100];
    char email[100];
    char srcPath[1400][200];
    int nCount;
}People;

People g_people[1000];
int g_count;

char g_photos[30000][200];
char g_faces[30000][5000];
int g_photo_count;

bool isRepeat(const char *id, const char *name) {
    for (int i = 0; i < g_count; ++i) {
        if (strcmp(g_people[i].id, id) == 0) {
            
           /* if (strcmp(g_people[i].name, name) != 0) {
                int a = 0;
                int b = 0;
                a = b;
                a = a/b;
            }*/
            
            return true;
        }
    }
    return false;
}

People *getInfo(const char *id) {
    for (int i = 0; i < g_count; ++i) {
        if (strcmp(g_people[i].id, id) == 0) {
            return &g_people[i];
        }
    }
    return 0;
}

bool isDirectory(char *pszName)
{
    struct stat S_stat;
    //取得文件状态
    if (lstat(pszName, &S_stat) < 0) {
        return false;
    }
    
    if (S_ISDIR(S_stat.st_mode)) {
        return true;
    }
    else {
        return false;
    }
}

#define MAX_PATH 10000

bool process_picasa_ini(const char *path) {
    printf("%s\n", path);
    if (strstr(path, ".picasa.ini") == 0) { //### not picasa.ini file
        return false;
    }
    
    FILE* fp = fopen(path, "rb");
    if (fp) {
        char data[MAX_PATH] = {0};
        fgets(data, MAX_PATH, fp);
        
        if (strcmp(data, "[Contacts2]\r\n") == 0) {
            while (1) {
                fgets(data, MAX_PATH, fp);
                if (data[0] == '[') {
                    break;
                }
                
                char *sep = strchr(data, ';');*sep = 0;
                sep = strchr(data, '=');sep++;
                
                strcpy(g_people[g_count].name, sep);
                sep--;*sep = 0;
                strcpy(g_people[g_count].id, data);
                
                if (!isRepeat(g_people[g_count].id, g_people[g_count].name)) {//### first disappear
                    char dir[1000] = DES_PATH;
                    strcat(dir, g_people[g_count].name);

                    if (!isDirectory(dir)) {
                        mkdir(dir, S_IRWXU);
                    }
                    else {
                        //int a = 0;
                    }
                    
                    g_count++;
                }
                else {
                    int a = 0;
                    int b = 0;
                    a = b;
                }
            }
        }
        else {
            //assert(0);
            int a = 0;
            int b = 0;
            a = b;
        }
        
        do {
            
            if (data[0] == '[' && data[strlen(data)-3] == ']') {
                //### get photo's path
                char dir[1000] = {0};
                strcpy(dir, path);
                char *_dir = strrchr(dir, '/');
                *(_dir+1) = 0;
                int len = (int)strlen(data);
                data[len-3] = 0;
                strcat(dir, data+1);
                
                //### get face infomation
                fgets(data, MAX_PATH, fp);
                while (strstr(data, "faces=") == 0) {
                    char *p = fgets(data, MAX_PATH, fp);
                    if (!p) {
                        break;
                    }
                    
                    if (data[0] == '[' && data[strlen(data)-3] == ']') {//### if is a photo path, cache new path
                        strcpy(dir, path);
                        char *_dir = strrchr(dir, '/');
                        *(_dir+1) = 0;
                        int len = (int)strlen(data);
                        data[len-3] = 0;
                        strcat(dir, data+1);
                    }
                }
                
                unsigned char *data2 = 0;
#ifdef PROCESS_PHOTO
                int width = 0, height = 0;
                data2 = decode(dir, &width, &height);
#endif
                char faces_output[5000] = {0};
                
                if (strstr(data, "faces=") != 0) {
                    int len_data = (int)strlen(data);
                    data[len_data-2] = ';';
                    char *face = data+6;
                    char *pFind = strchr(face, ';');
                    
                    while (pFind = strchr(face, ';'), pFind != 0) {
                        *pFind = 0;
                        
                        char rect[100] = {0}, id[100] = {0};
                        strcpy(rect, face+7);rect[16] = 0;

                        char *_rect = strchr(rect, ')');
                        if (_rect) {
                            *_rect = 0;
                            int nLen = (int)strlen(rect);
                            char temp[20] = {0};
                            for (int i = nLen; i < 16; ++i) {
                                temp[i-nLen] = '0';
                            }
                            strcpy(temp+16-nLen, rect);
                            strcpy(rect, temp);
                        }
                        
                        char *_id = strchr(face, ',');
                        strcpy(id, _id+1);//id[16] = 0;
                        
                        face = pFind+1;
                        
                        People *info = getInfo(id);
                        if (info != 0) {
                            
                            char dst[200] = DES_PATH;
                            strcat(dst, info->name);
                            strcat(dst, "/");
                            char count[10] = {0};
                            sprintf(count, "%d", info->nCount);
                            strcat(dst, count);
                            strcat(dst, ".jpg");
                            
                            strcat(faces_output, info->name);
                            strcat(faces_output, "=");
                            strcat(faces_output, rect);
                            strcat(faces_output, ";");
#ifdef PROCESS_PHOTO
                            int bResult = process_photo(data2, width, height, rect, dst);
                            if (bResult == 1) {
                                char *location = strstr(dir, "/htdocs/");
                                strcpy(info->srcPath[info->nCount], location+8);
                                strcat(info->srcPath[info->nCount], "\r");
                                info->nCount++;//### tag a face, add count
                            }
#endif

                        }

                    };
                }
                
                if (data2) {
                    free(data2);
                }
                
                if (strlen(faces_output) > 0) {
                    char *location = strstr(dir, "/htdocs/");
                    strcpy(g_photos[g_photo_count], location+8);
                    strcat(g_photos[g_photo_count], "\n");
                    strcpy(g_faces[g_photo_count], faces_output);
                    strcat(g_faces[g_photo_count], "\n");
                    g_photo_count++;
                }

            }

        } while (fgets(data, MAX_PATH, fp) != 0);
        
        fclose(fp);
    }
    
    return true;
}

void find_path(const char* path) {
    DIR *pDir = opendir(path);
    
    if (!pDir)
        return;
    
    dirent *pDirent;
    while ((pDirent = readdir(pDir)) != NULL) {
        if (strcmp(pDirent->d_name, ".") == 0 || strcmp(pDirent->d_name, "..") == 0)
        {
            continue;
        }
        
        char szTmpPath[1024] = {0};
        sprintf(szTmpPath, "%s%s", path, pDirent->d_name);
        
        if (isDirectory(szTmpPath)) {
            sprintf(szTmpPath, "%s%s/", path, pDirent->d_name);
            find_path(szTmpPath);
        }
        else {
            process_picasa_ini(szTmpPath);
        }
    }
}

void writeInfomation(void)
{
#ifdef PROCESS_PHOTO
    //### save people list
    FILE* fp = fopen("/Applications/MAMP/htdocs/hello.c", "wb");
    for (int i = 0; i < g_count; ++i) {
        char text[1000] = {0};
        strcpy(text, g_people[i].name);
        strcat(text, ";");
        char num[10] = {0};
        sprintf(num, "%d\r\n", g_people[i].nCount);
        strcat(text, num);
        fputs(text, fp);
    }
    fclose(fp);
    

    //### save detail infomation
    for (int i = 0; i < g_count; ++i) {
        
        char path[1000] = DES_PATH;
        strcat(path, g_people[i].name);
        strcat(path, "/info.ini");
        FILE* fp = fopen(path, "wb");
        
        for (int k = 0; k < g_people[i].nCount; ++k) {
            fputs(g_people[i].srcPath[k] , fp);
        }
        
        fclose(fp);
    }
#endif
    
    FILE* fp_photo = fopen("/Applications/MAMP/htdocs/photo.ini", "wb");
    for (int i = 0; i < g_photo_count; ++i) {
        fputs(g_photos[i], fp_photo);
        fputs(g_faces[i], fp_photo);
    }
    fclose(fp_photo);
}

int main(int argc, const char * argv[])
{
    find_path(SRC_PATH);
    writeInfomation();
    return 0;
}

