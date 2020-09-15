nasm -f win32 mandelbrot.asm -o start.obj
nlink start.obj -lmio -lio -lgfx -o mandelbrot.exe
