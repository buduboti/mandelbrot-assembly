nasm -f win32 mandelbrot.asm
nlink mandelbrot.obj -lmio -lio -lgfx -o mandelbrot.exe
