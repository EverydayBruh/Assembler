#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#define STB_IMAGE_IMPLEMENTATION
#include "../stb_image/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../stb_image/stb_image_write.h"


int blur(unsigned char *img, unsigned char *blur_img, int width, int hight);


int main(void) {
    const char *relativePath = "../img/";
    char *name = "0";
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

    blur(img, blur_img, width, height);
    
    char blurName[84]; 
    snprintf(blurName, sizeof(blurName), "%s%s%s", relativePath, name, "_blured.jpg");
    stbi_write_jpg(blurName, width, height, 3, blur_img, 100);

    stbi_image_free(img);
    free(blur_img);
}