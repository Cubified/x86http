## x86http

An HTTP file server written in x86_64 Assembly.  Designed to be extremely simple, fast, and (relatively) readable.

By design, only supports 200 and 404 status codes over HTTP/1.1, effectively the bare minimum for serving files to a browser.

### Benchmarks

Coming!

### Compiling and Running

`x86http` requires `nasm` to compile, and will use `ld.lld` (default linker with Clang) if you are running on musl and `ld` (the GNU linker) if you are not.  Compile with:

     $ make

And run with:

     $ ./x86http

This will start the server on port 5123.  Navigate to:

     http://localhost:5123/{any file in the current directory}
     (or)
     http://{your IP address}:5123/...

To view files in the current working directory.
