# bmp2coe

[![GitHub license](https://img.shields.io/github/license/davidxuang/bmp2coe.svg)](https://github.com/davidxuang/bmp2coe/blob/master/LICENSE)

**bmp2coe** is made for generating coefficient files for [Xilinx Vivado](https://www.xilinx.com/products/design-tools/vivado.html) from bitmap files.

## Usage

```powershell
ffmpeg -y -i input.png -pix_fmt {bgr24 | rgb444le} output.bmp
./bmp2coe.ps1 [-PixelFormat] {bgr24 | rgb444le}
```

The script will convert all .bmp files in the same folder. One of the following pixel formats must be specified (all formats use bottom-up row order and will append a padding pixel to each row if the image width is an odd number):

- **bgr24** as exported by [FFmpeg](https://ffmpeg.org/), which uses compact BGR pixel layout. The output file will use 8-bit wordlength.

- **rgb565le** as exported by FFmpeg, which uses 5R6G5B little-endian pixel layout. This may work for **rgb555le** (1A5R5G5B little-endian) as well. The output file will use 16-bit wordlength.

- **rgb444le** as exported by FFmpeg, which uses 4A4R4G4B little-endian pixel layout. The output file will use 12-bit wordlength.

Note that FFmpeg will apply dithering to the image when operates bit depth reduction by default.
