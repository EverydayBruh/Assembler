#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

#define STB_IMAGE_IMPLEMENTATION
#include "../stb_image/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../stb_image/stb_image_write.h"


int blur(unsigned char *img, unsigned char *blur_img, int width, int hight);


int main(int argc, char* argv[]) {
    if (argc != 3) {
        printf("Usage: %s <string1> <string2>\n", argv[0]);
        return 1;
    }

    char* name = argv[1];
    const char *relativePath = "../img/";
    int width, height, channels;


    char fullPath[80]; 
    char fullName[40]; 
    snprintf(fullName, sizeof(fullName), "%s%s", name , ".jpg");
    snprintf(fullPath, sizeof(fullPath), "%s%s", relativePath, fullName);
    //unsigned char *img = stbi_load("sky.jpg", &width, &height, &channels, 0);
    unsigned char *img = stbi_load(fullPath, &width, &height, &channels, 0);
    if(img == NULL) {
        printf("Error in loading the image\n");
        exit(1);
    }
    printf("Loaded image with a width of %dpx, a height of %dpx and %d channels\n", width, height, channels);
    size_t img_size = width * height * channels;


    // Blur image
    unsigned char *blur_img = malloc(img_size);
    if(blur_img == NULL) {
        printf("Unable to allocate memory for the blur image.\n");
        exit(1);
    }

    clock_t start_time, end_time;
    start_time = clock(); 
    blur(img, blur_img, width, height);
    end_time = clock();
    double cpu_time_used = ((double) (end_time - start_time)) / CLOCKS_PER_SEC;
    printf("Process time: %fs\n", cpu_time_used);
    
    char blurName[84];
    //snprintf(blurName, sizeof(blurName), "%s%s%s", relativePath, name, "_blured.jpg");  
    name = argv[2];
    snprintf(blurName, sizeof(blurName), "%s%s%s", relativePath, name, ".jpg");  
    stbi_write_jpg(blurName, width, height, 3, blur_img, 100);

    stbi_image_free(img);
    free(blur_img);
}