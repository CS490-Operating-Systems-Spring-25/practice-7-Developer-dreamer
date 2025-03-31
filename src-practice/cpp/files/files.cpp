#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <thread>
#include <chrono>

int main() {
    std::vector<std::ofstream> files;
    const int num_files = 100;  // Number of files to open
    
    std::cout << "Opening " << num_files << " files...\n";
    
    // Open multiple files
    for (int i = 0; i < num_files; ++i) {
        std::string filename = "file_" + std::to_string(i) + ".txt";
        std::ofstream file(filename);
        
        if (file.is_open()) {
            files.push_back(std::move(file));
            std::cout << "Opened file: " << filename << "\n";
        } else {
            std::cerr << "Failed to open file: " << filename << "\n";
        }
    }
    
    std::cout << "\nSuccessfully opened " << files.size() << " files.\n";
    std::cout << "Process ID: " << getpid() << "\n";
    std::cout << "Press Enter to close all files and exit...\n";
    std::cin.get();
    
    for (auto& file : files) {
        if (file.is_open()) {
            file.close();
        }
    }
    
    return 0;
} 