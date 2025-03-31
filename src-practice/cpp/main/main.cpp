#include <iostream>
#include <fstream>
#include <thread>
#include <chrono>

int main(){
    const int iterations = 1000;

    std::ofstream file("test.txt");

    if (!file.is_open()) {
        std::cerr << "Failed to open file" << std::endl;
    }

    for(int i = 0; i < iterations; i++) {
        file << i << "line\n";
        std::flush(file);
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }

    file.close();
    return 0;
}