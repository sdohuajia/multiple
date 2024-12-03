#!/bin/bash

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "新建了一个电报群，方便大家交流：t.me/Sdohua"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装 Multiple"
        echo "2. 验证安装"
        echo "3. 退出"
        read -p "请输入选项号码: " choice
        
        case $choice in
            1)
                install_multiple
                ;;
            2)
                verify_installation
                ;;
            3)
                exit 0
                ;;
            *)
                echo "无效的选项，请重新选择。"
                sleep 2
                ;;
        esac
    done
}

# 安装Multiple的函数
function install_multiple() {
    # 下载程序
    wget https://cdn.app.multiple.cc/client/linux/x64/multipleforlinux.tar

    # 解压程序
    tar -xvf multipleforlinux.tar

    # 添加权限
    chmod +x ./multiple-cli
    chmod +x ./multiple-node

    # 配置环境变量
    echo "正在配置环境变量..."
    echo 'PATH=$PATH:/path/to/your/extracted/directory/multiple-cli' | sudo tee -a /etc/profile > /dev/null
    source /etc/profile

    # 修改解压目录的权限
    chmod -R 777 multipleforlinux

    # 启动multiple-node
    cd multipleforlinux  # 假设解压后的目录名为multipleforlinux
    nohup ./multiple-node > output.log 2>&1 &
    echo "Multiple 已安装并启动。"
}

# 验证安装的函数
function verify_installation() {
    echo "正在验证安装..."
    multiple-cli --version
    read -p "按任意键返回主菜单..." -n1 -s
}

# 启动主菜单
main_menu
