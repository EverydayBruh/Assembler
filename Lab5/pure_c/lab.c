#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#define STB_IMAGE_IMPLEMENTATION
#include "../stb_image/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../stb_image/stb_image_write.h"

int matrix [5][5] = 
{
 1, 4, 6 , 4 , 1,
 4, 16, 24, 16, 4,
 6, 24, 36, 24, 6,
 4, 16, 24, 16, 4,
 1, 4, 6 , 4 , 1
};

int gray(unsigned char *img, unsigned char *gray_img, size_t img_size){

    for(unsigned char *p = img, *pg = gray_img; p != img + img_size; p += 3, pg += 1) {
        *pg = (uint8_t)((*p + *(p + 1) + *(p + 2))/3.0);
    }
    return 0;
}

void blurpixel(unsigned char *img_pixel, unsigned char *blur_pixel, int width)
{
    float sum = 0;
    unsigned char *adress;
    for(int row = 0; row < 5; row++){
    for(int col = 0; col < 5; col++){
        adress = img_pixel + (col - 1)*3 + (row - 1)*width*3;
        sum+=(*(adress)) * matrix[row][col];
    }}
    sum/= 256;
    
    ;printf("Sum: %f\n", sum);
   *blur_pixel = (uint8_t)fmin(sum, 255.0);
}


int blur(unsigned char *img, unsigned char *blur_img, int width, int hight){
    int shift = 0;
    for(int row = 0; row < hight; row++){
    for(int col = 0; col < width; col++)
    {   
        shift = col + row*width;
        shift*=3;
        for(int i = 0; i < 3; i++){
            if(row >= 2 && col >= 2 && row < hight - 2 && col < width - 2){
                blurpixel(img + shift + i, blur_img + shift + i, width);
            }else{
                *(blur_img + shift + i) = *(img + shift + i);
            }
        }
    }}
    return 0;
}

int sepia(unsigned char *img, unsigned char *sepia_img, size_t img_size){
    for(unsigned char *p = img, *pg = sepia_img; p != img + img_size; p += 3, pg += 3) {
        *pg       = (uint8_t)fmin(0.393 * *p + 0.769 * *(p + 1) + 0.189 * *(p + 2), 255.0);         // red
        *(pg + 1) = (uint8_t)fmin(0.349 * *p + 0.686 * *(p + 1) + 0.168 * *(p + 2), 255.0);         // green
        *(pg + 2) = (uint8_t)fmin(0.272 * *p + 0.534 * *(p + 1) + 0.131 * *(p + 2), 255.0);         // blue        
    }
    return 0;
}


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

    // Convert the input image to gray
    size_t img_size = width * height * channels;
    size_t gray_img_size = width * height;

    unsigned char *gray_img = malloc(gray_img_size);
    if(gray_img == NULL) {
        printf("Unable to allocate memory for the gray image.\n");
        exit(1);
    }

    gray(img, gray_img, img_size);

    char GrayName[84]; 
    snprintf(GrayName, sizeof(GrayName), "%s%s%s", relativePath, name, "_gray.jpg");
    stbi_write_jpg(GrayName, width, height, 1, gray_img, 100);


    // Convert the input image to sepia
    unsigned char *sepia_img = malloc(img_size);
    if(sepia_img == NULL) {
        printf("Unable to allocate memory for the sepia image.\n");
        exit(1);
    }

    sepia(img, sepia_img, img_size);
    
    char SepiaName[84]; 
    snprintf(SepiaName, sizeof(SepiaName), "%s%s%s", relativePath, name, "_sepia.jpg");
    stbi_write_jpg(SepiaName, width, height, 3, sepia_img, 100);


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
    free(gray_img);
    free(sepia_img);
}