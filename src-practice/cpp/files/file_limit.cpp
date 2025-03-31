#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <thread>
#include <chrono>
#include <unistd.h>
#include <sys/resource.h>
#include <fcntl.h>

void check_file_limits() {
    struct rlimit rlim;
    if (getrlimit(RLIMIT_NOFILE, &rlim) == 0) {
        std::cout << "Current file descriptor limit: " << rlim.rlim_cur << "\n";
        std::cout << "Maximum file descriptor limit: " << rlim.rlim_max << "\n";
    }
}

int main() {
    std::vector<std::ofstream> files;
    const int total_files = 100000;
    const int batch_size = 1000;
    int opened_files = 0;
    
    check_file_limits();
    
    std::cout << "Attempting to open " << total_files << " files in batches of " << batch_size << "...\n";
    
    try {
        while (opened_files < total_files) {
            for (int i = 0; i < batch_size && opened_files < total_files; ++i) {
                std::string filename = "file_" + std::to_string(opened_files) + ".txt";
                std::ofstream file(filename);
                
                if (file.is_open()) {
                    files.push_back(std::move(file));
                    opened_files++;
                    if (opened_files % 1000 == 0) {
                        std::cout << "Opened " << opened_files << " files...\n";
                    }
                } else {
                    std::cerr << "Failed to open file: " << filename << " (file #" << opened_files << ")\n";
                    throw std::runtime_error("Failed to open file");
                }
            }
            
            std::cout << "Sleeping for 1 second...\n";
            std::this_thread::sleep_for(std::chrono::seconds(1));
        }
        
        std::cout << "\nSuccessfully opened " << files.size() << " files!\n";
        std::cout << "Process ID: " << getpid() << "\n";
        std::cout << "Press Enter to close all files and exit...\n";
        std::cin.get();
        
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << "\n";
        std::cerr << "Failed after opening " << files.size() << " files.\n";
    }
    
    std::cout << "Closing all files...\n";
    for (auto& file : files) {
        if (file.is_open()) {
            file.close();
        }
    }
    
    return 0;
} 