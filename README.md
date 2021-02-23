## x86http

An HTTP file server written in x86_64 Assembly.  Designed to be extremely simple, fast, and (relatively) readable.

By design, only supports 200 and 404 status codes over HTTP/1.1, effectively the bare minimum for serving files to a browser.

### Compiling and Running

`x86http` requires `nasm` to compile, and by default uses `ld.lld` for linking (the default linker for Clang) although this is not a requirement.  Compile with:

     $ make

And run with:

     $ ./x86http

This will start the server on port 5123.  Navigate to:

     http://localhost:5123/{any file in the current directory}
     (or)
     http://{your IP address}:5123/...

To view files in the current working directory.  There is currently no automatically-generated `index.html` containing a list of all possible files, meaning `index.html` will 404 if not present.
