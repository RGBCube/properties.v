<div align="center">

<h1>properties.v</h1>

[Docs](https://rgbcube.github.io/docs/properties)

Parse properties files in V.

</div>

## Installation

After doing these, you can use the module in your V programs by importing `rgbcube.properties`.

### Via VPM

```bash
v install RGBCube.properties
```

### Via Git

```bash
git clone https://github.com/RGBCube/properties.v ~/.vmodules/rgbcube/properties
```

## Example

```v
import rgbcube.properties

props := properties.parse_file('example.properties') or {
    panic(err)
}

println(props['my.key.here'])
```

## License

```
MIT License

Copyright (c) 2022-present RGBCube

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
