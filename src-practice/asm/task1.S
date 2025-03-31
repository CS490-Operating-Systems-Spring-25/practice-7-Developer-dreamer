.section .data
    buffer:
        .fill 256, 1, 0     // Allocate 256-byte buffer initialized with zeros
    
    file_path:
        .asciz "test_file.txt"   // File to create and manipulate
    
    file_content:
        .asciz "Hello from AArch64 assembly!\n"
    
    file_read_buffer:
        .fill 100, 1, 0     // Buffer for reading file content
    
    newline:
        .asciz "\n"
    
    error_msg:
        .asciz "Error opening file! Error code: "
    
    success_msg:
        .asciz "All file operations completed successfully!\n"

    write_msg:
        .asciz "Written to file\n"
        
    read_msg:
        .asciz "Read from file: "
        
    chmod_msg:
        .asciz "Changed file permissions\n"

.section .text
    .global _start

_start:
    // 1. Get current working directory using getcwd (syscall 17)
    ldr x0, =buffer        // buffer pointer
    mov x1, #256           // buffer size
    mov x8, #17            // getcwd syscall number
    svc #0                 // make the syscall
    
    // 2. Print the current directory using write (syscall 64)
    mov x0, #1             // file descriptor: stdout
    ldr x1, =buffer        // buffer with the path
    
    // Calculate actual string length (find null terminator)
    mov x3, x1             // Copy buffer address to x3
    mov x4, #0             // Counter for length
count_loop:
    ldrb w5, [x3], #1      // Load byte and increment pointer
    cbz w5, count_done     // If zero, end of string
    add x4, x4, #1         // Increment length counter
    b count_loop
count_done:
    mov x2, x4             // Actual string length
    
    mov x8, #64            // write syscall number
    svc #0                 // make the syscall
    
    // Print a newline
    mov x0, #1             // file descriptor: stdout
    ldr x1, =newline       // newline string
    mov x2, #1             // length
    mov x8, #64            // write syscall
    svc #0
    
    // 3. Create/open a file - using the openat syscall
    mov x0, #-100          // AT_FDCWD - current directory
    ldr x1, =file_path     // Filename
    mov x2, #577           // O_WRONLY | O_CREAT | O_TRUNC (0x1 | 0x40 | 0x200 = 577)
    mov x3, #0666          // Permissions (octal)
    mov x8, #56            // openat syscall
    svc #0
    
    // Check for errors
    cmp x0, #0
    b.lt open_error
    
    // 4. Save file descriptor
    mov x19, x0
    
    // Print that we're writing to file
    mov x0, #1                // stdout
    ldr x1, =write_msg        // message
    mov x2, #15               // length
    mov x8, #64               // write syscall
    svc #0
    
    // 5. Write to file
    mov x0, x19            // File descriptor
    ldr x1, =file_content  // Content
    
    // Calculate content length
    mov x3, x1             // Copy content address to x3
    mov x4, #0             // Counter for length
content_loop:
    ldrb w5, [x3], #1      // Load byte and increment pointer
    cbz w5, content_done   // If zero, end of string
    add x4, x4, #1         // Increment length counter
    b content_loop
content_done:
    mov x2, x4             // Actual string length
    
    mov x8, #64            // write syscall
    svc #0
    
    // 6. Close the file
    mov x0, x19
    mov x8, #57            // close syscall
    svc #0
    
    // 7. Change file permissions using chmod
    mov x0, #-100           // AT_FDCWD - current directory
    ldr x1, =file_path      // Filename
    mov x2, #493            // 0755 in decimal (493)
    mov x8, #268            // fchmodat syscall 
    svc #0
    
    // Print that we've changed permissions
    mov x0, #1                // stdout
    ldr x1, =chmod_msg        // message
    mov x2, #24               // length
    mov x8, #64               // write syscall
    svc #0
    
    // 8. Open file for reading
    mov x0, #-100           // AT_FDCWD - current directory
    ldr x1, =file_path      // Filename
    mov x2, #0              // O_RDONLY
    mov x3, #0              // No permissions needed for read-only
    mov x8, #56             // openat syscall
    svc #0
    
    // Check for errors
    cmp x0, #0
    b.lt open_error
    
    // Save file descriptor
    mov x19, x0
    
    // 9. Read from file
    mov x0, x19              // File descriptor
    ldr x1, =file_read_buffer // Read buffer
    mov x2, #100             // Max bytes to read
    mov x8, #63              // read syscall
    svc #0
    
    // Save bytes read
    mov x20, x0
    
    // Print read message
    mov x0, #1               // stdout
    ldr x1, =read_msg        // message
    mov x2, #15              // length
    mov x8, #64              // write syscall
    svc #0
    
    // Print file content
    mov x0, #1               // stdout
    ldr x1, =file_read_buffer // buffer with content
    mov x2, x20              // bytes read
    mov x8, #64              // write syscall
    svc #0
    
    // Print a newline
    mov x0, #1             // file descriptor: stdout
    ldr x1, =newline       // newline string
    mov x2, #1             // length
    mov x8, #64            // write syscall
    svc #0
    
    // Close the file
    mov x0, x19
    mov x8, #57             // close syscall
    svc #0
    
    // 10. Print success message
    mov x0, #1                // stdout
    ldr x1, =success_msg      // success message
    mov x2, #44               // length
    mov x8, #64               // write syscall
    svc #0
    
    // Exit with code 1 (as required in the task)
    mov x0, #1             // exit code 1
    mov x8, #93            // exit syscall number
    svc #0                 // make the syscall

open_error:
    // Print error message
    mov x0, #1                // stdout
    ldr x1, =error_msg        // error message
    mov x2, #30               // length
    mov x8, #64               // write syscall
    svc #0
    
    mov x0, #2             // exit with code 2
    mov x8, #93            // exit syscall
    svc #0 