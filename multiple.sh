#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/multiple.sh"

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请以root权限运行此脚本"
    exit 1
fi

# 安装依赖函数
function install_dependencies() {
    apt-get update
    apt-get install -y curl wget tar
}

# 安装Multiple函数
function install_multiple() {
    echo "开始安装Multiple..."
    
    # 创建安装目录
    mkdir -p /root/multipleforlinux
    cd /root/multipleforlinux
    
    # 下载并解压
    wget -O multiple.tar.gz https://github.com/ferdie-jhovie/multiple/releases/download/v1.0.0/multiple.tar.gz
    tar -xzf multiple.tar.gz
    
    # 添加环境变量
    echo 'PATH=$PATH:/root/multipleforlinux' >> /etc/profile
    echo 'PATH=$PATH:/root/multipleforlinux' >> ~/.bashrc
    source /etc/profile
    source ~/.bashrc
    
    # 设置权限
    chmod +x /root/multipleforlinux/multiple-node
    
    echo "Multiple安装完成!"
}

# 验证安装函数
function verify_installation() {
    if [ -f "/root/multipleforlinux/multiple-node" ]; then
        echo "Multiple已正确安装!"
        read -p "按任意键返回主菜单..." -n1 -s
    else
        echo "Multiple未安装或安装不完整，请重新安装"
        read -p "按任意键返回主菜单..." -n1 -s
    fi
}

# 代理模式多开函数
function proxy_mode() {
    echo "请输入要启动的实例数量:"
    read instance_count
    
    for ((i=1; i<=instance_count; i++))
    do
        port=$((20000 + i))
        multiple-node --socks5 127.0.0.1:$port &
        echo "已启动实例 $i，代理端口: $port"
    done
    
    read -p "按任意键返回主菜单..." -n1 -s
}

# 删除Multiple函数
function uninstall_multiple() {
    echo "正在删除 Multiple..."
    # 停止 multiple-node 进程
    pkill -f multiple-node
    
    # 删除程序文件
    rm -rf ~/multipleforlinux
    rm -rf /root/multipleforlinux
    
    # 清理环境变量配置
    sed -i '/PATH=$PATH:\/root\/multipleforlinux/d' /etc/profile
    sed -i '/PATH=$PATH:\/root\/multipleforlinux/d' ~/.bashrc
    
    # 重新加载环境变量
    source /etc/profile
    source ~/.bashrc
    
    echo "Multiple 已成功删除"
    read -p "按任意键返回主菜单..." -n1 -s
}

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
        echo "3. 使用代理模式多开"
        echo "4. 删除 Multiple"
        echo "5. 退出"
        read -p "请输入选项号码: " choice
        
        case $choice in
            1)
                install_dependencies
                install_multiple
                ;;
            2)
                verify_installation
                ;;
            3)
                proxy_mode
                ;;
            4)
                uninstall_multiple
                ;;
            5)
                echo "退出脚本"
                exit 0
                ;;
            *)
                echo "无效选项，请重新选择"
                sleep 2
                ;;
        esac
    done
}

# 运行主菜单
main_menu
