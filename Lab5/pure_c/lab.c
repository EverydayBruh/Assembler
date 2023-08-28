#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

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

void blurpixel(unsigned char *img_pixel, unsigned char *blur_pixel, int width)
{
    float sum = 0;
    unsigned char *adress;
    for(int row = 0; row < 5; row++){
    for(int col = 0; col < 5; col++){
        adress = img_pixel + (col - 2)*3 + (row - 2)*width*3;
        sum+=(*(adress)) * matrix[row][col];
    }}
    sum/= 256;
    
    //printf("Sum: %f\n", sum);
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