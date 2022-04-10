# Distributed under the OSI-approved MIT License.  See accompanying
# file LICENSE or https://github.com/Crascit/DownloadProject for details.

cmake_minimum_required(VERSION 3.10)

project(pdfium-download NONE)

include(ExternalProject)
ExternalProject_Add(pdfium-download
                    URL;https://github.com/bblanchon/pdfium-binaries/releases/download/chromium/4706/pdfium-win-x64.tgz
                    SOURCE_DIR          "E:/demos/experiments/isar_demo/build/windows/pdfium-src"
                    BINARY_DIR          "E:/demos/experiments/isar_demo/build/windows/pdfium-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
)
