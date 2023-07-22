#include <iostream>

using namespace std;

extern "C" int asmfunc();

int main() {
	cout << "result is " << asmfunc();
	return 0;
}