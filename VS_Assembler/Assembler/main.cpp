// main.cpp
#include <iostream>

// Прототип функции на ассемблере с использованием extern "C"
// Ваш C++ код
extern "C" {
    int* processMatrix(int* matrix, int rows, int cols);
}
int main() {
    int matrix[3][3] = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    };

    int* result = processMatrix(&matrix[0][0], 3, 3);

    std::cout << "\nResult Matrix (After multiplying by 2):" << std::endl;
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j) {
            std::cout << result[i * 3 + j] << " ";
        }
        std::cout << std::endl;
    }

    return 0;
}

