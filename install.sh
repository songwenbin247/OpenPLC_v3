#!/bin/bash
if [ $# -eq 0 ]; then
    echo ""
    echo "Error: You must provide a platform name as argument"
    echo ""
    echo "Usage: ./install.sh [platform]   where [platform] can be"
    echo "  win           Install OpenPLC on Windows over Cygwin"
    echo "  linux         Install OpenPLC on a Debian-based Linux distribution"
    echo "  rpi           Install OpenPLC on a Raspberry Pi"
    echo "  custom        Skip all specific package installation and tries to install"
    echo "                OpenPLC assuming your system already has all dependencies met."
    echo "                This option can be useful if you're trying to install OpenPLC"
    echo "                on an unsuported Linux platform or had manually installed"
    echo "                all the dependency packages before."
    echo ""
    exit 1
fi

if [ "$1" == "win" ]; then
    echo "Installing OpenPLC on Windows"
    cp ./utils/apt-cyg/apt-cyg ./
    cp ./utils/apt-cyg/wget.exe /bin
    install apt-cyg /bin
    apt-cyg install lynx 
    rm -f /bin/wget.exe
    apt-cyg install wget gcc-core gcc-g++ git pkg-config automake autoconf libtool make python2 python2-pip sqlite3
    lynx -source https://bootstrap.pypa.io/get-pip.py > get-pip.py
    python get-pip.py
    pip install flask
    pip install flask-login
    
    echo ""
    echo "[MATIEC COMPILER]"
    cp ./utils/matiec_src/bin_win32/*.* ./webserver/
    if [ $? -ne 0 ]; then
        echo "Error compiling MatIEC"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    
    echo ""
    echo "[ST OPTIMIZER]"
    cd utils/st_optimizer_src
    g++ st_optimizer.cpp -o st_optimizer
    cp ./st_optimizer.exe ../../webserver/
    if [ $? -ne 0 ]; then
        echo "Error compiling ST Optimizer"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    cd ../..
    
    echo ""
    echo "[GLUE GENERATOR]"
    cd utils/glue_generator_src
    g++ glue_generator.cpp -o glue_generator
    cp ./glue_generator.exe ../../webserver/core
    if [ $? -ne 0 ]; then
        echo "Error compiling Glue Generator"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    cd ../..
    
    echo ""
    echo "[OPEN DNP3]"
    cd webserver/core
    mv dnp3.cpp dnp3.disabled
    if [ $? -ne 0 ]; then
        echo "Error disabling OpenDNP3"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    mv dnp3_dummy.disabled dnp3_dummy.cpp
    if [ $? -ne 0 ]; then
        echo "Error disabling OpenDNP3"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    cd ../..
    
    echo ""
    echo "[FINALIZING]"
    cd webserver/scripts
    ./change_hardware_layer.sh blank
    ./compile_program.sh blank_program.st
    cp ./start_openplc.sh ../../
    


elif [ "$1" == "linux" ]; then
    echo "Installing OpenPLC on Linux"
    sudo apt-get update
    sudo apt-get install build-essential pkg-config bison flex autoconf automake libtool make git python2.7 python-pip sqlite3 cmake
    pip install flask
    pip install flask-login
    #make sure that flask and flask-login are also installed for the super user
    sudo pip install flask
    sudo pip install flask-login

    echo ""
    echo "[MATIEC COMPILER]"
    cd utils/matiec_src
    autoreconf -i
    ./configure
    make
    cp ./iec2c ../../webserver/
    if [ $? -ne 0 ]; then
        echo "Error compiling MatIEC"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    cd ../..

    echo ""
    echo "[ST OPTIMIZER]"
    cd utils/st_optimizer_src
    g++ st_optimizer.cpp -o st_optimizer
    cp ./st_optimizer ../../webserver/
    if [ $? -ne 0 ]; then
        echo "Error compiling ST Optimizer"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    cd ../..
    
    echo ""
    echo "[GLUE GENERATOR]"
    cd utils/glue_generator_src
    g++ glue_generator.cpp -o glue_generator
    cp ./glue_generator ../../webserver/core
    if [ $? -ne 0 ]; then
        echo "Error compiling Glue Generator"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    cd ../..
    
    echo ""
    echo "[OPEN DNP3]"
    cd utils/dnp3_src
    echo "creating swapfile..."
    sudo dd if=/dev/zero of=swapfile bs=1M count=1000
    sudo mkswap swapfile
    sudo swapon swapfile
    cmake ../dnp3_src
    make
    sudo make install
    if [ $? -ne 0 ]; then
        echo "Error installing OpenDNP3"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    sudo ldconfig
    echo "removing swapfile..."
    sudo swapoff swapfile
    sudo rm -f ./swapfile
    cd ../..
    
    echo ""
    echo "[FINALIZING]"
    cd webserver/scripts
    ./change_hardware_layer.sh blank_linux
    ./compile_program.sh blank_program.st
    cp ./start_openplc.sh ../../
    
    

elif [ "$1" == "rpi" ]; then
    echo "Installing OpenPLC on Raspberry Pi"
    sudo apt-get update
    sudo apt-get install build-essential pkg-config bison flex autoconf automake libtool make git python2.7 python-pip sqlite3 cmake wiringpi
    pip install flask
    pip install flask-login
    #make sure that flask and flask-login are also installed for the super user
    sudo pip install flask
    sudo pip install flask-login
    
    echo ""
    echo "[MATIEC COMPILER]"
    cd utils/matiec_src
    autoreconf -i
    ./configure
    make
    cp ./iec2c ../../webserver/
    if [ $? -ne 0 ]; then
        echo "Error compiling MatIEC"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    cd ../..

    echo ""
    echo "[ST OPTIMIZER]"
    cd utils/st_optimizer_src
    g++ st_optimizer.cpp -o st_optimizer
    cp ./st_optimizer ../../webserver/
    if [ $? -ne 0 ]; then
        echo "Error compiling ST Optimizer"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    cd ../..
    
    echo ""
    echo "[GLUE GENERATOR]"
    cd utils/glue_generator_src
    g++ glue_generator.cpp -o glue_generator
    cp ./glue_generator ../../webserver/core
    if [ $? -ne 0 ]; then
        echo "Error compiling Glue Generator"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    cd ../..
    
    echo ""
    echo "[OPEN DNP3]"
    cd utils/dnp3_src
    echo "creating swapfile..."
    sudo dd if=/dev/zero of=swapfile bs=1M count=1000
    sudo mkswap swapfile
    sudo swapon swapfile
    cmake ../dnp3_src
    make
    sudo make install
    if [ $? -ne 0 ]; then
        echo "Error installing OpenDNP3"
        echo "OpenPLC was NOT installed!"
        exit 1
    fi
    sudo ldconfig
    echo "removing swapfile..."
    sudo swapoff swapfile
    sudo rm -f ./swapfile
    cd ../..
    
    echo ""
    echo "[FINALIZING]"
    cd webserver/scripts
    ./change_hardware_layer.sh blank_linux
    ./compile_program.sh blank_program.st
    cp ./start_openplc.sh ../../
    

else
    echo ""
    echo "Error: unrecognized platform"
    echo ""
    echo "Usage: ./install.sh [platform]   where [platform] can be"
    echo "  win           Install OpenPLC on Windows over Cygwin"
    echo "  linux         Install OpenPLC on a Debian-based Linux distribution"
    echo "  rpi           Install OpenPLC on a Raspberry Pi"
    echo "  custom        Skip all specific package installation and tries to install"
    echo "                OpenPLC assuming your system already has all dependencies met."
    echo "                This option can be useful if you're trying to install OpenPLC"
    echo "                on an unsuported Linux platform or had manually installed"
    echo "                all the dependency packages before."
    echo ""
    exit 1
fi


